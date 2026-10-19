metadata name = 'Azure Red Hat OpenShift (ARO) Clusters'
metadata description = 'This module deploys an Azure Red Hat OpenShift (ARO) cluster.'

// ============== //
//   Parameters   //
// ============== //

@description('Required. The name of the ARO cluster.')
@minLength(1)
@maxLength(54)
param name string

@description('Optional. Location for all resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags resourceInput<'Microsoft.RedHatOpenShift/openShiftClusters@2025-07-25'>.tags?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// ---------- Cluster profile ---------- //

@description('Required. The OpenShift version of the cluster (e.g. `4.17.27`). Create-only: after an in-cluster upgrade, pass the version the cluster currently runs.')
param version string

@description('Optional. The domain for the cluster. Either a prefix (results in `<prefix>.<location>.aroapp.io`) or a fully qualified domain name, in which case you must create the API and ingress DNS A records yourself. Defaults to a generated 8-character prefix.')
param domain string = take('a${uniqueString(resourceGroup().id, name)}', 8)

@description('Optional. Name of the cluster (managed) resource group that ARO creates and locks. Must not exist yet. Only used at creation time.')
param clusterResourceGroupName string = 'aro-${name}'

@description('Optional. Whether FIPS validated crypto modules are used.')
param fipsValidatedModules ('Enabled' | 'Disabled') = 'Disabled'

@secure()
@description('Optional. The Red Hat pull secret for the cluster. Gives access to Red Hat registries and OperatorHub content.')
param pullSecret string?

// ---------- Identity ---------- //

import { managedIdentityOnlyUserAssignedType } from 'br/public:avm/utl/types/avm-common-types:0.7.0'
@description('Conditional. The cluster managed identity. Exactly one user-assigned identity must be provided. Required if `servicePrincipalProfile` is not provided. When set, `platformWorkloadIdentities` is required too.')
param managedIdentities managedIdentityOnlyUserAssignedType?

@description('Conditional. The platform workload (operator) identities, keyed by operator name (e.g. `cloud-controller-manager`, `ingress`, `machine-api`, `disk-csi-driver`, `file-csi-driver`, `cloud-network-config`, `image-registry`, `aro-operator`). Required if `managedIdentities` is provided.')
param platformWorkloadIdentities resourceInput<'Microsoft.RedHatOpenShift/openShiftClusters@2025-07-25'>.properties.platformWorkloadIdentityProfile.platformWorkloadIdentities?

@description('Optional. A single OpenShift version a workload identity cluster can be upgraded to. Only applicable when `managedIdentities` is provided.')
param upgradeableTo string?

@description('Conditional. The service principal the cluster uses to manage Azure resources. Required if `managedIdentities` is not provided.')
param servicePrincipalProfile servicePrincipalProfileType?

// ---------- Networking ---------- //

@description('Required. The resource ID of the master (control plane) subnet.')
param masterSubnetResourceId string

@description('Optional. API server visibility.')
param apiServerVisibility ('Private' | 'Public') = 'Private'

@description('Optional. Ingress (default router) visibility.')
param ingressVisibility ('Private' | 'Public') = 'Private'

@description('Optional. The outbound type used for egress traffic. `UserDefinedRouting` requires a private API server and ingress and a route table on the subnets.')
param outboundType ('Loadbalancer' | 'UserDefinedRouting') = 'Loadbalancer'

@minValue(1)
@maxValue(20)
@description('Optional. The number of IPv4 outbound IPs managed by Azure for the cluster public load balancer. Only applicable when `outboundType` is `Loadbalancer`.')
param managedOutboundIpCount int?

@description('Optional. The CIDR used for pods. Must not overlap with the virtual network or `100.64.0.0/16` / `100.88.0.0/16` (OVN-Kubernetes).')
param podCidr string = '10.128.0.0/14'

@description('Optional. The CIDR used for services.')
param serviceCidr string = '172.30.0.0/16'

@description('Optional. Whether the subnets are pre-attached with your own network security group. If `Disabled`, ARO creates and manages its own NSG.')
param preconfiguredNSG ('Enabled' | 'Disabled') = 'Disabled'

// ---------- Compute ---------- //

@description('Optional. The VM size of the master (control plane) nodes.')
param masterVmSize string = 'Standard_D8s_v5'

@description('Optional. Whether the master VMs are encrypted at host.')
param masterEncryptionAtHost ('Enabled' | 'Disabled') = 'Disabled'

@description('Optional. The resource ID of a disk encryption set used for the master VM disks.')
param masterDiskEncryptionSetResourceId string?

@description('Required. The worker profiles. ARO currently supports exactly one worker profile at creation; additional pools are created in-cluster via MachineSets.')
@minLength(1)
@maxLength(1)
param workerProfiles workerProfileType[]

// ---------- AVM interfaces ---------- //

import { lockType } from 'br/public:avm/utl/types/avm-common-types:0.7.0'
@description('Optional. The lock settings of the service.')
param lock lockType?

import { roleAssignmentType } from 'br/public:avm/utl/types/avm-common-types:0.7.0'
@description('Optional. Array of role assignments to create on the cluster resource.')
param roleAssignments roleAssignmentType[]?

// ============= //
//   Variables   //
// ============= //

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var isManagedIdentityCluster = !empty(formattedUserAssignedIdentities)

var identity = isManagedIdentityCluster
  ? {
      type: 'UserAssigned'
      userAssignedIdentities: formattedUserAssignedIdentities
    }
  : null

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
}

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

// ============ //
// Dependencies //
// ============ //

var telemetryIdPrefix = loadJsonContent('metadata.json', 'telemetryIdPrefix')

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2025-04-01' = if (enableTelemetry) {
  name: '${telemetryIdPrefix}.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

// ============== //
// Main Resources //
// ============== //

resource openShiftCluster 'Microsoft.RedHatOpenShift/openShiftClusters@2025-07-25' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    apiserverProfile: {
      visibility: apiServerVisibility
    }
    clusterProfile: {
      domain: domain
      fipsValidatedModules: fipsValidatedModules
      pullSecret: pullSecret
      resourceGroupId: '${subscription().id}/resourceGroups/${clusterResourceGroupName}'
      version: version
    }
    ingressProfiles: [
      {
        name: 'default'
        visibility: ingressVisibility
      }
    ]
    masterProfile: {
      subnetId: masterSubnetResourceId
      vmSize: masterVmSize
      encryptionAtHost: masterEncryptionAtHost
      diskEncryptionSetId: masterDiskEncryptionSetResourceId
    }
    networkProfile: {
      outboundType: outboundType
      podCidr: podCidr
      serviceCidr: serviceCidr
      preconfiguredNSG: preconfiguredNSG
      loadBalancerProfile: outboundType == 'Loadbalancer' && managedOutboundIpCount != null
        ? {
            managedOutboundIps: {
              count: managedOutboundIpCount!
            }
          }
        : null
    }
    workerProfiles: map(workerProfiles, profile => {
      name: profile.?name ?? 'worker'
      subnetId: profile.subnetResourceId
      vmSize: profile.?vmSize ?? 'Standard_D4s_v5'
      count: profile.?count ?? 3
      diskSizeGB: profile.?diskSizeGB ?? 128
      encryptionAtHost: profile.?encryptionAtHost ?? 'Disabled'
      diskEncryptionSetId: profile.?diskEncryptionSetResourceId
    })
    platformWorkloadIdentityProfile: isManagedIdentityCluster
      ? {
          platformWorkloadIdentities: platformWorkloadIdentities
          upgradeableTo: upgradeableTo
        }
      : null
    servicePrincipalProfile: isManagedIdentityCluster ? null : servicePrincipalProfile
  }
}

resource openShiftCluster_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: openShiftCluster
}

resource openShiftCluster_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(openShiftCluster.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: openShiftCluster
  }
]

// =========== //
//   Outputs   //
// =========== //

@description('The resource ID of the ARO cluster.')
output resourceId string = openShiftCluster.id

@description('The name of the ARO cluster.')
output name string = openShiftCluster.name

@description('The resource group the ARO cluster was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = openShiftCluster.location

@description('The resource ID of the cluster (managed) resource group.')
output clusterResourceGroupId string = openShiftCluster.properties.clusterProfile.resourceGroupId

@description('The URL of the OpenShift API server.')
output apiServerUrl string? = openShiftCluster.properties.?apiserverProfile.?url

@description('The IP address of the OpenShift API server.')
output apiServerIp string? = openShiftCluster.properties.?apiserverProfile.?ip

@description('The URL of the OpenShift web console.')
output consoleUrl string? = openShiftCluster.properties.?consoleProfile.?url

@description('The IP address of the default ingress controller.')
output ingressIp string? = openShiftCluster.properties.?ingressProfiles[?0].?ip

@description('The OIDC issuer URL. Only set for managed (workload) identity clusters.')
output oidcIssuer string? = openShiftCluster.properties.clusterProfile.?oidcIssuer

// =============== //
//   Definitions   //
// =============== //

@export()
@description('The type for a worker profile.')
type workerProfileType = {
  @description('Optional. The worker profile name. Defaults to `worker`.')
  name: string?

  @description('Required. The resource ID of the worker subnet.')
  subnetResourceId: string

  @description('Optional. The VM size of the worker nodes. Defaults to `Standard_D4s_v5`.')
  vmSize: string?

  @minValue(3)
  @description('Optional. The number of worker nodes. Defaults to 3.')
  count: int?

  @minValue(128)
  @description('Optional. The OS disk size of the worker nodes in GB. Defaults to 128.')
  diskSizeGB: int?

  @description('Optional. Whether the worker VMs are encrypted at host. Defaults to `Disabled`.')
  encryptionAtHost: ('Enabled' | 'Disabled')?

  @description('Optional. The resource ID of a disk encryption set used for the worker VM disks.')
  diskEncryptionSetResourceId: string?
}

@export()
@description('The type for a service principal profile.')
type servicePrincipalProfileType = {
  @description('Required. The client ID of the service principal.')
  clientId: string

  @secure()
  @description('Required. The client secret of the service principal.')
  clientSecret: string
}

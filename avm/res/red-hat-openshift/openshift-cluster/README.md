# Azure Red Hat OpenShift (ARO) Clusters `[Microsoft.RedHatOpenShift/openShiftClusters]`

This module deploys an Azure Red Hat OpenShift (ARO) cluster.

You can reference the module as follows:
```bicep
module openshiftCluster 'br/public:avm/res/red-hat-openshift/openshift-cluster:<version>' = {
  params: { (...) }
}
```
For examples, please refer to the [Usage Examples](#usage-examples) section.

## Navigation

- [Resource Types](#Resource-Types)
- [Usage examples](#Usage-examples)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Data Collection](#Data-Collection)

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates)</li></ul> |
| `Microsoft.RedHatOpenShift/openShiftClusters` | 2025-07-25 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.redhatopenshift_openshiftclusters.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/public:avm/res/red-hat-openshift/openshift-cluster:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Using a service principal](#example-2-using-a-service-principal)
- [WAF-aligned](#example-3-waf-aligned)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters, using managed (workload) identities.

You can find the full example and the setup of its dependencies in the deployment test folder path [/tests/e2e/defaults]


<details>

<summary>via Bicep module</summary>

```bicep
module openshiftCluster 'br/public:avm/res/red-hat-openshift/openshift-cluster:<version>' = {
  params: {
    // Required parameters
    masterSubnetResourceId: '<masterSubnetResourceId>'
    name: 'rhocmin001'
    version: '4.17.27'
    workerProfiles: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    location: '<location>'
    managedIdentities: {
      userAssignedResourceIds: [
        '<clusterIdentityResourceId>'
      ]
    }
    platformWorkloadIdentities: '<platformWorkloadIdentities>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON parameters file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "masterSubnetResourceId": {
      "value": "<masterSubnetResourceId>"
    },
    "name": {
      "value": "rhocmin001"
    },
    "version": {
      "value": "4.17.27"
    },
    "workerProfiles": {
      "value": [
        {
          "subnetResourceId": "<subnetResourceId>"
        }
      ]
    },
    // Non-required parameters
    "location": {
      "value": "<location>"
    },
    "managedIdentities": {
      "value": {
        "userAssignedResourceIds": [
          "<clusterIdentityResourceId>"
        ]
      }
    },
    "platformWorkloadIdentities": {
      "value": "<platformWorkloadIdentities>"
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:avm/res/red-hat-openshift/openshift-cluster:<version>'

// Required parameters
param masterSubnetResourceId = '<masterSubnetResourceId>'
param name = 'rhocmin001'
param version = '4.17.27'
param workerProfiles = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param location = '<location>'
param managedIdentities = {
  userAssignedResourceIds: [
    '<clusterIdentityResourceId>'
  ]
}
param platformWorkloadIdentities = '<platformWorkloadIdentities>'
```

</details>
<p>

### Example 2: _Using a service principal_

This instance deploys the module with a service principal instead of managed identities, and a public API server and ingress.

You can find the full example and the setup of its dependencies in the deployment test folder path [/tests/e2e/service-principal]


<details>

<summary>via Bicep module</summary>

```bicep
module openshiftCluster 'br/public:avm/res/red-hat-openshift/openshift-cluster:<version>' = {
  params: {
    // Required parameters
    masterSubnetResourceId: '<masterSubnetResourceId>'
    name: 'rhocsp001'
    version: '4.17.27'
    workerProfiles: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    apiServerVisibility: 'Public'
    ingressVisibility: 'Public'
    location: '<location>'
    servicePrincipalProfile: {
      clientId: '<clientId>'
      clientSecret: '<clientSecret>'
    }
  }
}
```

</details>
<p>

<details>

<summary>via JSON parameters file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "masterSubnetResourceId": {
      "value": "<masterSubnetResourceId>"
    },
    "name": {
      "value": "rhocsp001"
    },
    "version": {
      "value": "4.17.27"
    },
    "workerProfiles": {
      "value": [
        {
          "subnetResourceId": "<subnetResourceId>"
        }
      ]
    },
    // Non-required parameters
    "apiServerVisibility": {
      "value": "Public"
    },
    "ingressVisibility": {
      "value": "Public"
    },
    "location": {
      "value": "<location>"
    },
    "servicePrincipalProfile": {
      "value": {
        "clientId": "<clientId>",
        "clientSecret": "<clientSecret>"
      }
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:avm/res/red-hat-openshift/openshift-cluster:<version>'

// Required parameters
param masterSubnetResourceId = '<masterSubnetResourceId>'
param name = 'rhocsp001'
param version = '4.17.27'
param workerProfiles = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param apiServerVisibility = 'Public'
param ingressVisibility = 'Public'
param location = '<location>'
param servicePrincipalProfile = {
  clientId: '<clientId>'
  clientSecret: '<clientSecret>'
}
```

</details>
<p>

### Example 3: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework: a private API server and ingress, using managed (workload) identities.

You can find the full example and the setup of its dependencies in the deployment test folder path [/tests/e2e/waf-aligned]


<details>

<summary>via Bicep module</summary>

```bicep
module openshiftCluster 'br/public:avm/res/red-hat-openshift/openshift-cluster:<version>' = {
  params: {
    // Required parameters
    masterSubnetResourceId: '<masterSubnetResourceId>'
    name: 'rhocwaf001'
    version: '4.17.27'
    workerProfiles: [
      {
        count: 3
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    apiServerVisibility: 'Private'
    ingressVisibility: 'Private'
    location: '<location>'
    managedIdentities: {
      userAssignedResourceIds: [
        '<clusterIdentityResourceId>'
      ]
    }
    platformWorkloadIdentities: '<platformWorkloadIdentities>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
```

</details>
<p>

<details>

<summary>via JSON parameters file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "masterSubnetResourceId": {
      "value": "<masterSubnetResourceId>"
    },
    "name": {
      "value": "rhocwaf001"
    },
    "version": {
      "value": "4.17.27"
    },
    "workerProfiles": {
      "value": [
        {
          "count": 3,
          "subnetResourceId": "<subnetResourceId>"
        }
      ]
    },
    // Non-required parameters
    "apiServerVisibility": {
      "value": "Private"
    },
    "ingressVisibility": {
      "value": "Private"
    },
    "location": {
      "value": "<location>"
    },
    "managedIdentities": {
      "value": {
        "userAssignedResourceIds": [
          "<clusterIdentityResourceId>"
        ]
      }
    },
    "platformWorkloadIdentities": {
      "value": "<platformWorkloadIdentities>"
    },
    "tags": {
      "value": {
        "Environment": "Non-Prod",
        "hidden-title": "This is visible in the resource name",
        "Role": "DeploymentValidation"
      }
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:avm/res/red-hat-openshift/openshift-cluster:<version>'

// Required parameters
param masterSubnetResourceId = '<masterSubnetResourceId>'
param name = 'rhocwaf001'
param version = '4.17.27'
param workerProfiles = [
  {
    count: 3
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param apiServerVisibility = 'Private'
param ingressVisibility = 'Private'
param location = '<location>'
param managedIdentities = {
  userAssignedResourceIds: [
    '<clusterIdentityResourceId>'
  ]
}
param platformWorkloadIdentities = '<platformWorkloadIdentities>'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`masterSubnetResourceId`](#parameter-mastersubnetresourceid) | string | The resource ID of the master (control plane) subnet. |
| [`name`](#parameter-name) | string | The name of the ARO cluster. |
| [`version`](#parameter-version) | string | The OpenShift version of the cluster (e.g. `4.17.27`). Create-only: after an in-cluster upgrade, pass the version the cluster currently runs. |
| [`workerProfiles`](#parameter-workerprofiles) | array | The worker profiles. ARO currently supports exactly one worker profile at creation; additional pools are created in-cluster via MachineSets. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`managedIdentities`](#parameter-managedidentities) | object | The cluster managed identity. Exactly one user-assigned identity must be provided. Required if `servicePrincipalProfile` is not provided. When set, `platformWorkloadIdentities` is required too. |
| [`platformWorkloadIdentities`](#parameter-platformworkloadidentities) | object | The platform workload (operator) identities, keyed by operator name (e.g. `cloud-controller-manager`, `ingress`, `machine-api`, `disk-csi-driver`, `file-csi-driver`, `cloud-network-config`, `image-registry`, `aro-operator`). Required if `managedIdentities` is provided. |
| [`servicePrincipalProfile`](#parameter-serviceprincipalprofile) | object | The service principal the cluster uses to manage Azure resources. Required if `managedIdentities` is not provided. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`apiServerVisibility`](#parameter-apiservervisibility) | string | API server visibility. |
| [`clusterResourceGroupName`](#parameter-clusterresourcegroupname) | string | Name of the cluster (managed) resource group that ARO creates and locks. Must not exist yet. Only used at creation time. |
| [`domain`](#parameter-domain) | string | The domain for the cluster. Either a prefix (results in `<prefix>.<location>.aroapp.io`) or a fully qualified domain name, in which case you must create the API and ingress DNS A records yourself. Defaults to a generated 8-character prefix. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`fipsValidatedModules`](#parameter-fipsvalidatedmodules) | string | Whether FIPS validated crypto modules are used. |
| [`ingressVisibility`](#parameter-ingressvisibility) | string | Ingress (default router) visibility. |
| [`location`](#parameter-location) | string | Location for all resources. Defaults to the resource group location. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`managedOutboundIpCount`](#parameter-managedoutboundipcount) | int | The number of IPv4 outbound IPs managed by Azure for the cluster public load balancer. Only applicable when `outboundType` is `Loadbalancer`. |
| [`masterDiskEncryptionSetResourceId`](#parameter-masterdiskencryptionsetresourceid) | string | The resource ID of a disk encryption set used for the master VM disks. |
| [`masterEncryptionAtHost`](#parameter-masterencryptionathost) | string | Whether the master VMs are encrypted at host. |
| [`masterVmSize`](#parameter-mastervmsize) | string | The VM size of the master (control plane) nodes. |
| [`outboundType`](#parameter-outboundtype) | string | The outbound type used for egress traffic. `UserDefinedRouting` requires a private API server and ingress and a route table on the subnets. |
| [`podCidr`](#parameter-podcidr) | string | The CIDR used for pods. Must not overlap with the virtual network or `100.64.0.0/16` / `100.88.0.0/16` (OVN-Kubernetes). |
| [`preconfiguredNSG`](#parameter-preconfigurednsg) | string | Whether the subnets are pre-attached with your own network security group. If `Disabled`, ARO creates and manages its own NSG. |
| [`pullSecret`](#parameter-pullsecret) | securestring | The Red Hat pull secret for the cluster. Gives access to Red Hat registries and OperatorHub content. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create on the cluster resource. |
| [`serviceCidr`](#parameter-servicecidr) | string | The CIDR used for services. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`upgradeableTo`](#parameter-upgradeableto) | string | A single OpenShift version a workload identity cluster can be upgraded to. Only applicable when `managedIdentities` is provided. |

### Parameter: `masterSubnetResourceId`

The resource ID of the master (control plane) subnet.

- Required: Yes
- Type: string

### Parameter: `name`

The name of the ARO cluster.

- Required: Yes
- Type: string

### Parameter: `version`

The OpenShift version of the cluster (e.g. `4.17.27`). Create-only: after an in-cluster upgrade, pass the version the cluster currently runs.

- Required: Yes
- Type: string

### Parameter: `workerProfiles`

The worker profiles. ARO currently supports exactly one worker profile at creation; additional pools are created in-cluster via MachineSets.

- Required: Yes
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnetResourceId`](#parameter-workerprofilessubnetresourceid) | string | The resource ID of the worker subnet. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`count`](#parameter-workerprofilescount) | int | The number of worker nodes. Defaults to 3. |
| [`diskEncryptionSetResourceId`](#parameter-workerprofilesdiskencryptionsetresourceid) | string | The resource ID of a disk encryption set used for the worker VM disks. |
| [`diskSizeGB`](#parameter-workerprofilesdisksizegb) | int | The OS disk size of the worker nodes in GB. Defaults to 128. |
| [`encryptionAtHost`](#parameter-workerprofilesencryptionathost) | string | Whether the worker VMs are encrypted at host. Defaults to `Disabled`. |
| [`name`](#parameter-workerprofilesname) | string | The worker profile name. Defaults to `worker`. |
| [`vmSize`](#parameter-workerprofilesvmsize) | string | The VM size of the worker nodes. Defaults to `Standard_D4s_v5`. |

### Parameter: `workerProfiles.subnetResourceId`

The resource ID of the worker subnet.

- Required: Yes
- Type: string

### Parameter: `workerProfiles.count`

The number of worker nodes. Defaults to 3.

- Required: No
- Type: int
- MinValue: 3

### Parameter: `workerProfiles.diskEncryptionSetResourceId`

The resource ID of a disk encryption set used for the worker VM disks.

- Required: No
- Type: string

### Parameter: `workerProfiles.diskSizeGB`

The OS disk size of the worker nodes in GB. Defaults to 128.

- Required: No
- Type: int
- MinValue: 128

### Parameter: `workerProfiles.encryptionAtHost`

Whether the worker VMs are encrypted at host. Defaults to `Disabled`.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `workerProfiles.name`

The worker profile name. Defaults to `worker`.

- Required: No
- Type: string

### Parameter: `workerProfiles.vmSize`

The VM size of the worker nodes. Defaults to `Standard_D4s_v5`.

- Required: No
- Type: string

### Parameter: `managedIdentities`

The cluster managed identity. Exactly one user-assigned identity must be provided. Required if `servicePrincipalProfile` is not provided. When set, `platformWorkloadIdentities` is required too.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`userAssignedResourceIds`](#parameter-managedidentitiesuserassignedresourceids) | array | The resource ID(s) to assign to the resource. Required if a user assigned identity is used for encryption. |

### Parameter: `managedIdentities.userAssignedResourceIds`

The resource ID(s) to assign to the resource. Required if a user assigned identity is used for encryption.

- Required: No
- Type: array

### Parameter: `platformWorkloadIdentities`

The platform workload (operator) identities, keyed by operator name (e.g. `cloud-controller-manager`, `ingress`, `machine-api`, `disk-csi-driver`, `file-csi-driver`, `cloud-network-config`, `image-registry`, `aro-operator`). Required if `managedIdentities` is provided.

- Required: No
- Type: object

### Parameter: `servicePrincipalProfile`

The service principal the cluster uses to manage Azure resources. Required if `managedIdentities` is not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`clientId`](#parameter-serviceprincipalprofileclientid) | string | The client ID of the service principal. |
| [`clientSecret`](#parameter-serviceprincipalprofileclientsecret) | securestring | The client secret of the service principal. |

### Parameter: `servicePrincipalProfile.clientId`

The client ID of the service principal.

- Required: Yes
- Type: string

### Parameter: `servicePrincipalProfile.clientSecret`

The client secret of the service principal.

- Required: Yes
- Type: securestring

### Parameter: `apiServerVisibility`

API server visibility.

- Required: No
- Type: string
- Default: `'Private'`
- Allowed:
  ```Bicep
  [
    'Private'
    'Public'
  ]
  ```

### Parameter: `clusterResourceGroupName`

Name of the cluster (managed) resource group that ARO creates and locks. Must not exist yet. Only used at creation time.

- Required: No
- Type: string
- Default: `[format('aro-{0}', parameters('name'))]`

### Parameter: `domain`

The domain for the cluster. Either a prefix (results in `<prefix>.<location>.aroapp.io`) or a fully qualified domain name, in which case you must create the API and ingress DNS A records yourself. Defaults to a generated 8-character prefix.

- Required: No
- Type: string
- Default: `[take(format('a{0}', uniqueString(resourceGroup().id, parameters('name'))), 8)]`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `fipsValidatedModules`

Whether FIPS validated crypto modules are used.

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `ingressVisibility`

Ingress (default router) visibility.

- Required: No
- Type: string
- Default: `'Private'`
- Allowed:
  ```Bicep
  [
    'Private'
    'Public'
  ]
  ```

### Parameter: `location`

Location for all resources. Defaults to the resource group location.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `lock`

The lock settings of the service.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-lockkind) | string | Specify the type of lock. |
| [`name`](#parameter-lockname) | string | Specify the name of lock. |
| [`notes`](#parameter-locknotes) | string | Specify the notes of the lock. |

### Parameter: `lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `lock.notes`

Specify the notes of the lock.

- Required: No
- Type: string

### Parameter: `managedOutboundIpCount`

The number of IPv4 outbound IPs managed by Azure for the cluster public load balancer. Only applicable when `outboundType` is `Loadbalancer`.

- Required: No
- Type: int
- MinValue: 1
- MaxValue: 20

### Parameter: `masterDiskEncryptionSetResourceId`

The resource ID of a disk encryption set used for the master VM disks.

- Required: No
- Type: string

### Parameter: `masterEncryptionAtHost`

Whether the master VMs are encrypted at host.

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `masterVmSize`

The VM size of the master (control plane) nodes.

- Required: No
- Type: string
- Default: `'Standard_D8s_v5'`

### Parameter: `outboundType`

The outbound type used for egress traffic. `UserDefinedRouting` requires a private API server and ingress and a route table on the subnets.

- Required: No
- Type: string
- Default: `'Loadbalancer'`
- Allowed:
  ```Bicep
  [
    'Loadbalancer'
    'UserDefinedRouting'
  ]
  ```

### Parameter: `podCidr`

The CIDR used for pods. Must not overlap with the virtual network or `100.64.0.0/16` / `100.88.0.0/16` (OVN-Kubernetes).

- Required: No
- Type: string
- Default: `'10.128.0.0/14'`

### Parameter: `preconfiguredNSG`

Whether the subnets are pre-attached with your own network security group. If `Disabled`, ARO creates and manages its own NSG.

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `pullSecret`

The Red Hat pull secret for the cluster. Gives access to Red Hat registries and OperatorHub content.

- Required: No
- Type: securestring

### Parameter: `roleAssignments`

Array of role assignments to create on the cluster resource.

- Required: No
- Type: array
- Roles configurable by name:
  - `'Contributor'`
  - `'Owner'`
  - `'Reader'`
  - `'Role Based Access Control Administrator'`
  - `'User Access Administrator'`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-roleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-roleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-roleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-roleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-roleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-roleassignmentsdescription) | string | The description of the role assignment. |
| [`name`](#parameter-roleassignmentsname) | string | The name (as GUID) of the role assignment. If not provided, a GUID will be generated. |
| [`principalType`](#parameter-roleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `roleAssignments.name`

The name (as GUID) of the role assignment. If not provided, a GUID will be generated.

- Required: No
- Type: string

### Parameter: `roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `serviceCidr`

The CIDR used for services.

- Required: No
- Type: string
- Default: `'172.30.0.0/16'`

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `upgradeableTo`

A single OpenShift version a workload identity cluster can be upgraded to. Only applicable when `managedIdentities` is provided.

- Required: No
- Type: string

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `apiServerIp` | string | The IP address of the OpenShift API server. |
| `apiServerUrl` | string | The URL of the OpenShift API server. |
| `clusterResourceGroupId` | string | The resource ID of the cluster (managed) resource group. |
| `consoleUrl` | string | The URL of the OpenShift web console. |
| `ingressIp` | string | The IP address of the default ingress controller. |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the ARO cluster. |
| `oidcIssuer` | string | The OIDC issuer URL. Only set for managed (workload) identity clusters. |
| `resourceGroupName` | string | The resource group the ARO cluster was deployed into. |
| `resourceId` | string | The resource ID of the ARO cluster. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/public:avm/utl/types/avm-common-types:0.7.0` | Remote reference |

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

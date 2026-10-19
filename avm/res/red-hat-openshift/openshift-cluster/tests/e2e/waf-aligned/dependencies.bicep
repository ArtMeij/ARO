@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

@description('Required. The name of the virtual network to create.')
param virtualNetworkName string

@description('Required. The prefix used for the managed identity names.')
param managedIdentityNamePrefix string

@description('Required. The object ID of the "Azure Red Hat OpenShift RP" service principal in this tenant (`az ad sp list --display-name "Azure Red Hat OpenShift RP" --query [0].id -o tsv`).')
param aroRpObjectId string

var addressPrefix = '10.0.0.0/22'

// Operator identities and the ARO built-in role each one needs, plus where it needs it.
// `scope`: 'subnets' = master + worker subnet, 'vnet' = the virtual network, 'none' = no network role.
var operators = [
  { name: 'cloud-controller-manager', roleId: 'a1f96423-95ce-4224-ab27-4e3dc72facd4', scope: 'subnets' }
  { name: 'ingress', roleId: '0336e1d3-7a87-462b-b6db-342b63f7802c', scope: 'subnets' }
  { name: 'machine-api', roleId: '0358943c-7e01-48ba-8889-02cc51d78637', scope: 'subnets' }
  { name: 'aro-operator', roleId: '4436bae4-7702-4c84-919b-c4069ff25ee2', scope: 'subnets' }
  { name: 'cloud-network-config', roleId: 'be7a6435-15ae-4171-8f30-4a343eff9e8f', scope: 'vnet' }
  { name: 'file-csi-driver', roleId: '0d7aedc0-15fd-4a67-a412-efad370c947e', scope: 'vnet' }
  { name: 'image-registry', roleId: '8b32b316-c2f5-4ddf-b05b-83dacd2d08b5', scope: 'vnet' }
  { name: 'disk-csi-driver', roleId: '', scope: 'none' }
]

var federatedCredentialRoleId = 'ef318e2a-8334-4a05-9e4a-295a196c6a6e' // Azure Red Hat OpenShift Federated Credential
var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7' // Network Contributor

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-10-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: [
      {
        name: 'master'
        properties: {
          addressPrefix: cidrSubnet(addressPrefix, 23, 0)
          privateLinkServiceNetworkPolicies: 'Disabled'
          serviceEndpoints: [{ service: 'Microsoft.ContainerRegistry' }]
        }
      }
      {
        name: 'worker'
        properties: {
          addressPrefix: cidrSubnet(addressPrefix, 23, 1)
          serviceEndpoints: [{ service: 'Microsoft.ContainerRegistry' }]
        }
      }
    ]
  }

  resource masterSubnet 'subnets' existing = {
    name: 'master'
  }

  resource workerSubnet 'subnets' existing = {
    name: 'worker'
  }
}

resource clusterIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: '${managedIdentityNamePrefix}-aro-cluster'
  location: location
}

resource operatorIdentities 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = [
  for operator in operators: {
    name: '${managedIdentityNamePrefix}-${operator.name}'
    location: location
  }
]

// The cluster identity must be able to federate every operator identity.
resource federatedCredentialRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (operator, i) in operators: {
    name: guid(operatorIdentities[i].id, clusterIdentity.id, federatedCredentialRoleId)
    scope: operatorIdentities[i]
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', federatedCredentialRoleId)
      principalId: clusterIdentity.properties.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

resource masterSubnetRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (operator, i) in operators: if (operator.scope == 'subnets') {
    name: guid(virtualNetwork::masterSubnet.id, operatorIdentities[i].id, operator.roleId)
    scope: virtualNetwork::masterSubnet
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', operator.roleId)
      principalId: operatorIdentities[i].properties.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

resource workerSubnetRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (operator, i) in operators: if (operator.scope == 'subnets') {
    name: guid(virtualNetwork::workerSubnet.id, operatorIdentities[i].id, operator.roleId)
    scope: virtualNetwork::workerSubnet
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', operator.roleId)
      principalId: operatorIdentities[i].properties.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

resource virtualNetworkRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (operator, i) in operators: if (operator.scope == 'vnet') {
    name: guid(virtualNetwork.id, operatorIdentities[i].id, operator.roleId)
    scope: virtualNetwork
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', operator.roleId)
      principalId: operatorIdentities[i].properties.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

// The ARO resource provider manages the cluster network (NSG, load balancers, private link service).
resource aroRpRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(virtualNetwork.id, aroRpObjectId, networkContributorRoleId)
  scope: virtualNetwork
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
    principalId: aroRpObjectId
    principalType: 'ServicePrincipal'
  }
}

@description('The resource ID of the master subnet.')
output masterSubnetResourceId string = virtualNetwork::masterSubnet.id

@description('The resource ID of the worker subnet.')
output workerSubnetResourceId string = virtualNetwork::workerSubnet.id

@description('The resource ID of the cluster managed identity.')
output clusterIdentityResourceId string = clusterIdentity.id

@description('The operator identities, in the shape the `platformWorkloadIdentities` parameter expects.')
output platformWorkloadIdentities object = reduce(
  map(
    operators,
    operator => {
      '${operator.name}': {
        resourceId: resourceId(
          'Microsoft.ManagedIdentity/userAssignedIdentities',
          '${managedIdentityNamePrefix}-${operator.name}'
        )
      }
    }
  ),
  {},
  (cur, next) => union(cur, next)
)

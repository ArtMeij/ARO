@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

@description('Required. The name of the virtual network to create.')
param virtualNetworkName string

@description('Required. The object ID of the "Azure Red Hat OpenShift RP" service principal in this tenant (`az ad sp list --display-name "Azure Red Hat OpenShift RP" --query [0].id -o tsv`).')
param aroRpObjectId string

@description('Required. The object ID of the service principal the cluster uses.')
param clusterServicePrincipalObjectId string

var addressPrefix = '10.0.0.0/22'
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

// Both the ARO resource provider and the cluster service principal manage the cluster network.
resource networkContributorRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for principalId in [aroRpObjectId, clusterServicePrincipalObjectId]: {
    name: guid(virtualNetwork.id, principalId, networkContributorRoleId)
    scope: virtualNetwork
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
      principalId: principalId
      principalType: 'ServicePrincipal'
    }
  }
]

@description('The resource ID of the master subnet.')
output masterSubnetResourceId string = virtualNetwork::masterSubnet.id

@description('The resource ID of the worker subnet.')
output workerSubnetResourceId string = virtualNetwork::workerSubnet.id

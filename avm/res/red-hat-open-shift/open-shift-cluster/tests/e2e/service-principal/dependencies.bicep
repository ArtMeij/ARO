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
var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor

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

// The ARO resource provider manages the cluster network.
resource aroRpNetworkContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(virtualNetwork.id, aroRpObjectId, networkContributorRoleId)
  scope: virtualNetwork
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
    principalId: aroRpObjectId
    principalType: 'ServicePrincipal'
  }
}

// A service principal cluster needs Contributor on the resource group holding the cluster (and its VNet).
// https://learn.microsoft.com/en-us/azure/openshift/howto-create-service-principal
resource clusterSpContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, clusterServicePrincipalObjectId, contributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: clusterServicePrincipalObjectId
    principalType: 'ServicePrincipal'
  }
}

@description('The resource ID of the master subnet.')
output masterSubnetResourceId string = virtualNetwork::masterSubnet.id

@description('The resource ID of the worker subnet.')
output workerSubnetResourceId string = virtualNetwork::workerSubnet.id

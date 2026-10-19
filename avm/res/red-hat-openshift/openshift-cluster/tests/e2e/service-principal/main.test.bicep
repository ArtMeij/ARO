targetScope = 'subscription'

metadata name = 'Using a service principal'
metadata description = 'This instance deploys the module with a service principal instead of managed identities, and a public API server and ingress.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-redhatopenshift.openshiftclusters-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'rhocsp'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

@description('Required. The object ID of the "Azure Red Hat OpenShift RP" service principal in the test tenant. This value is tenant-specific and must be provided by the CI as a GitHub secret or variable named \'CI_ARO_RP_OBJECT_ID\'.')
param aroRpObjectId string = ''

@description('Required. The client ID of the service principal the cluster uses. This value is tenant-specific and must be provided by the CI as a GitHub secret named \'CI_ARO_SP_CLIENT_ID\'.')
param aroSpClientId string = ''

@description('Required. The object ID of the service principal the cluster uses. This value is tenant-specific and must be provided by the CI as a GitHub secret named \'CI_ARO_SP_OBJECT_ID\'.')
param aroSpObjectId string = ''

@description('Required. The client secret of the service principal the cluster uses. This value is tenant-specific and must be provided by the CI as a GitHub secret named \'CI_ARO_SP_CLIENT_SECRET\'.')
@secure()
param aroSpClientSecret string = ''

// ============ //
// Dependencies //
// ============ //

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    location: resourceLocation
    virtualNetworkName: 'dep-${namePrefix}-vnet-${serviceShort}'
    aroRpObjectId: aroRpObjectId
    clusterServicePrincipalObjectId: aroSpObjectId
  }
}

// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      version: '4.17.27' // TODO: pick a version from `az aro get-versions --location <region>`
      apiServerVisibility: 'Public'
      ingressVisibility: 'Public'
      masterSubnetResourceId: nestedDependencies.outputs.masterSubnetResourceId
      workerProfiles: [
        {
          subnetResourceId: nestedDependencies.outputs.workerSubnetResourceId
        }
      ]
      servicePrincipalProfile: {
        clientId: aroSpClientId
        clientSecret: aroSpClientSecret
      }
    }
  }
]

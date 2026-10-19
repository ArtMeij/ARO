targetScope = 'subscription'

metadata name = 'WAF-aligned'
metadata description = 'This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework: a private API server and ingress, using managed (workload) identities.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-redhatopenshift.openshiftclusters-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'rhocwaf'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

@description('Required. The object ID of the "Azure Red Hat OpenShift RP" service principal in the test tenant. This value is tenant-specific and must be provided by the CI as a GitHub secret or variable named \'CI_ARO_RP_OBJECT_ID\'.')
param aroRpObjectId string = ''

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
    managedIdentityNamePrefix: 'dep-${namePrefix}-msi-${serviceShort}'
    aroRpObjectId: aroRpObjectId
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
      apiServerVisibility: 'Private'
      ingressVisibility: 'Private'
      masterSubnetResourceId: nestedDependencies.outputs.masterSubnetResourceId
      workerProfiles: [
        {
          subnetResourceId: nestedDependencies.outputs.workerSubnetResourceId
          count: 3
        }
      ]
      managedIdentities: {
        userAssignedResourceIds: [
          nestedDependencies.outputs.clusterIdentityResourceId
        ]
      }
      platformWorkloadIdentities: nestedDependencies.outputs.platformWorkloadIdentities
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
  }
]

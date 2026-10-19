# ARO reference notes

Sources: the [ARM template reference for openShiftClusters](https://learn.microsoft.com/en-us/azure/templates/microsoft.redhatopenshift/openshiftclusters?pivots=deployment-language-bicep), the [Red Hat Cloud Experts MIWI guide](https://cloud.redhat.com/experts/aro/miwi/) and the [MS ARO Bicep quickstart](https://learn.microsoft.com/en-us/azure/openshift/howto-create-openshift-cluster?pivots=aro-az-bicep). Items marked _verify_ have not been confirmed against current docs.

## API versions
`2025-07-25` (latest stable), `2024-08-12-preview`, `2023-11-22`, `2023-09-04`, `2023-07-01-preview`, `2023-04-01`, `2022-09-04`, `2022-04-01`, `2021-09-01-preview`, `2020-04-30`.
Deploy scope: resource group only.

## Resource shape (2025-07-25)
```
identity: { type: 'None'|'SystemAssigned'|'UserAssigned'|'SystemAssigned,UserAssigned', userAssignedIdentities: { '<id>': {} } }
properties:
  apiserverProfile:     { visibility: 'Private'|'Public' }                 // read-only: url, ip
  clusterProfile:       { domain, fipsValidatedModules: 'Enabled'|'Disabled', pullSecret, resourceGroupId, version }  // read-only: oidcIssuer
  consoleProfile:       {}                                                  // read-only: url
  ingressProfiles:      [ { name, visibility: 'Private'|'Public' } ]        // read-only: ip
  masterProfile:        { subnetId, vmSize, encryptionAtHost, diskEncryptionSetId }
  networkProfile:       { outboundType: 'Loadbalancer'|'UserDefinedRouting', podCidr, serviceCidr, preconfiguredNSG: 'Enabled'|'Disabled',
                          loadBalancerProfile: { managedOutboundIps: { count: 1-20 } } }
  platformWorkloadIdentityProfile: { platformWorkloadIdentities: { '<operator>': { resourceId } }, upgradeableTo }
  servicePrincipalProfile: { clientId, clientSecret }
  workerProfiles:       [ { name, subnetId, vmSize, count, diskSizeGB, encryptionAtHost, diskEncryptionSetId } ]
  provisioningState     // read-only in practice
```

## Managed identity / workload identity clusters
- 1 **cluster identity** (user-assigned) goes in `identity.userAssignedIdentities`.
- 8 **operator identities** go in `platformWorkloadIdentities`, keyed by operator name.
- The cluster identity needs **Azure Red Hat OpenShift Federated Credential** (`ef318e2a-8334-4a05-9e4a-295a196c6a6e`) on **each** operator identity.
- The **ARO RP** service principal (display name "Azure Red Hat OpenShift RP", object ID differs per tenant) needs **Network Contributor** (`4d97b98b-1d4f-4787-a291-c67834d212e7`) on the VNet.

| Operator key | Built-in role | Role ID | Scope |
|---|---|---|---|
| `cloud-controller-manager` | ARO Cloud Controller Manager | `a1f96423-95ce-4224-ab27-4e3dc72facd4` | master + worker subnet |
| `ingress` | ARO Cluster Ingress Operator | `0336e1d3-7a87-462b-b6db-342b63f7802c` | master + worker subnet |
| `machine-api` | ARO Machine API Operator | `0358943c-7e01-48ba-8889-02cc51d78637` | master + worker subnet |
| `aro-operator` | ARO Service Operator | `4436bae4-7702-4c84-919b-c4069ff25ee2` | master + worker subnet |
| `cloud-network-config` | ARO Network Operator | `be7a6435-15ae-4171-8f30-4a343eff9e8f` | VNet |
| `file-csi-driver` | ARO File Storage Operator | `0d7aedc0-15fd-4a67-a412-efad370c947e` | VNet |
| `image-registry` | ARO Image Registry Operator | `8b32b316-c2f5-4ddf-b05b-83dacd2d08b5` | VNet |
| `disk-csi-driver` | ARO Disk Storage Operator | `5b7237c5-45e1-49d6-bc18-a1f62f400748` | none on the network; _verify_ whether this role is needed and where |

_Verify:_ with a route table (UDR) or a preconfigured NSG, the relevant operators and the RP may also need roles on those resources. A disk encryption set needs access for the cluster/RP as well.

The Hosted Control Plane roles (`88366f10-…`, `fc0c873f-…`, `c0ff367d-…`) are for ARO HCP, **not** classic ARO. Don't use them here.

## Network requirements (classic ARO)
- Two subnets (master and worker), each at least `/27`; `/23` is recommended for workers. They can't be shared with other resources.
- Master subnet: `privateLinkServiceNetworkPolicies: 'Disabled'`.
- Service endpoint `Microsoft.ContainerRegistry` on both subnets (commonly used).
- Pod and service CIDRs must not overlap the VNet, and must avoid `100.64.0.0/16` and `100.88.0.0/16` (OVN-Kubernetes).
- `UserDefinedRouting` requires the API server **and** ingress to be `Private`, plus a route table on both subnets (0.0.0.0/0 → firewall/NVA).
- The managed (cluster) resource group must **not** exist beforehand. ARO creates it and puts a deny assignment on it.

## Misc
- Resource provider: `Microsoft.RedHatOpenShift` must be registered. Quota: the default needs ≥ 40–44 cores of the D-series family.
- Available versions: `az aro get-versions --location <region>`.
- Creation takes about 30–45 minutes.

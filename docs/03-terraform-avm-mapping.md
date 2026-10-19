# Terraform ARO AVM → our Bicep module

Reference: [Azure/terraform-azurerm-avm-res-redhatopenshift-openshiftcluster](https://github.com/Azure/terraform-azurerm-avm-res-redhatopenshift-openshiftcluster) (registry: `Azure/avm-res-redhatopenshift-openshiftcluster/azurerm`). It uses `azapi_resource` for the cluster, plus role assignments, private endpoints and telemetry. It uses no submodules.

| Terraform input | Shape | Bicep param (ours) | Notes |
|---|---|---|---|
| `name` | string, 5–50 chars, lowercase/digits/hyphens | `name` | TF validates the length; ours is `@maxLength(54)` → _align_ |
| `location` | string | `location` | |
| `resource_group_name` | string | (deployment scope) | |
| `api_server_profile.visibility` | object | `apiServerVisibility` | flattened |
| `ingress_profile.visibility` | object | `ingressVisibility` | flattened; one `default` profile |
| `cluster_profile.domain` | required | `domain` | ours is optional with a generated default |
| `cluster_profile.version` | required | `version` | |
| `cluster_profile.fips_enabled` | bool | `fipsValidatedModules` | ours uses the API enum |
| `cluster_profile.managed_resource_group_name` | default `rg-<name>` | `clusterResourceGroupName` | ours defaults to `aro-<name>` |
| `cluster_profile.pull_secret` | string | `pullSecret` (`@secure`) | |
| `main_profile.{subnet_id, vm_size, disk_encryption_set_id, encryption_at_host_enabled}` | object | `masterSubnetResourceId`, `masterVmSize`, `masterDiskEncryptionSetResourceId`, `masterEncryptionAtHost` | flattened |
| `network_profile.{pod_cidr, service_cidr, outbound_type, preconfigured_network_security_group_enabled}` | object | `podCidr`, `serviceCidr`, `outboundType`, `preconfiguredNSG` | TF has no managed outbound IP count; ours has `managedOutboundIpCount` |
| `worker_profile` | **single object** | `workerProfiles` (array, max 1) | same constraint, different shape |
| `managed_identities` | `{system_assigned, user_assigned_resource_ids}` | `managedIdentities` (`managedIdentityOnlyUserAssignedType`) | ARO needs user-assigned only |
| `platform_workload_identities` | map(`{resource_id, ...}`) | `platformWorkloadIdentities` | ours passes the API shape `{ '<op>': { resourceId } }` straight through |
| `service_principal` | `{client_id, client_secret}` | `servicePrincipalProfile` | |
| `role_assignments` | map | `roleAssignments` | AVM standard |
| `private_endpoints` | map | — | _question:_ does ARO actually support private endpoints on this resource? Probably template boilerplate; skip unless proven |
| `customer_managed_key` | object | — | not a real ARO property (DES is per-profile); skip |
| `timeouts`, `subscription_id` | | — | TF-specific |
| `tags`, `enable_telemetry` | | `tags`, `enableTelemetry` | |
| — | | `lock` | AVM standard interface; TF doesn't expose it |

TF outputs: `resource`, `resource_id`, `private_endpoints`. Ours exposes more (URLs, IPs, OIDC issuer, managed RG ID).

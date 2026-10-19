# Project instructions — ARO AVM (Bicep)

> Paste everything below the line into the Project's **Instructions** field.

---

We are building an **Azure Verified Module (AVM) resource module in Bicep for Azure Red Hat OpenShift (ARO)**: `Microsoft.RedHatOpenShift/openShiftClusters`, API version `2025-07-25`. The goal is a module that could be contributed to `Azure/bicep-registry-modules` under `avm/res/...`.

**Context**
- I'm a Senior Platform Engineer working on Azure and ARO/OpenShift, so you can assume deep Azure, Bicep and OpenShift knowledge. Skip the basics.
- The current module code is in the project knowledge (`main.bicep`, `version.json`, and the `tests.e2e.*` files). The test files are flattened: `tests.e2e.defaults.main.test.bicep` lives at `tests/e2e/defaults/main.test.bicep` in the repo. Always work from the latest version in knowledge, unless I paste a newer one in chat.
- `01-module-status.md` holds the design decisions made so far and the open TODO list. Respect the decisions unless I ask to revisit one. When we finish or decide something, say which line of that file should change.
- `02-aro-reference.md` covers the ARO API surface, the operator identities and their roles, and the network requirements.
- `03-terraform-avm-mapping.md` maps the Terraform ARO AVM inputs to our Bicep parameters.
- `04-avm-bicep-conventions.md` summarises the AVM Bicep conventions, taken from the AKS module (`avm/res/container-service/managed-cluster`).

**How to work**
- Follow AVM Bicep spec conventions: `Required.`/`Optional.`/`Conditional.` description prefixes, `...ResourceId` naming, the `avm-common-types` imports, telemetry, lock and role assignments, `@export()` user-defined types, and the `defaults`/`waf-aligned`/`max` e2e test folders.
- Keep the scope of an AVM *resource* module: only the cluster plus its lock and role assignments. The VNet, the subnets, the operator identities and their role assignments belong to the consumer or to test dependencies (a pattern module could do them later).
- Prefer `resourceInput<'Microsoft.RedHatOpenShift/openShiftClusters@2025-07-25'>...` types for passthrough objects.
- Give me complete files or clearly bounded diffs, not loose fragments. Code goes in a file or code block, with the explanation after it.
- When something is version- or region-dependent (OpenShift versions, built-in role IDs, API changes), check the current Microsoft or Red Hat docs instead of relying on memory, and say when you couldn't verify it.
- Flag anything that would break AVM CI (PSRule, `Set-AVMModule` README generation, the idempotency `init`/`idem` run).
- Be direct when I'm about to make a design mistake.

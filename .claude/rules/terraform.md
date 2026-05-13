# Terraform Rules

- Provider: `dmacvicar/libvirt` for KVM VM provisioning
- All resources use `for_each` over `count` unless ordering is meaningful
- Remote state: backend config in `terraform/environments/<env>/backend.tf` (not in repo — use `-backend-config` flag)
- NO `terraform.tfvars` files committed — use `.tfvars.example` with placeholder values
- Module outputs always document their type and purpose with `description`
- VM naming convention: `<app>-<role>-vm-<index>` (e.g., `ccb-web-vm-01`)
- Anti-affinity: enforce separate KVM host placement for HA pairs via `libvirt_domain` placement tags
- Local values block for computed names/tags — keep resource blocks clean

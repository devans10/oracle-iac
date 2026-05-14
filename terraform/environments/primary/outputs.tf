output "ccb_vm_ips" {
  description = "CC&B VM names and IP addresses"
  value       = { for k, v in module.ccb_vms : k => v.ip_address }
}

output "mdm_vm_ips" {
  description = "MDM VM names and IP addresses"
  value       = { for k, v in module.mdm_vms : k => v.ip_address }
}

output "soa_vm_ips" {
  description = "SOA Suite VM names and IP addresses"
  value       = { for k, v in module.soa_vms : k => v.ip_address }
}

output "ohs_vm_ips" {
  description = "OHS VM names and IP addresses"
  value       = { for k, v in module.ohs_vms : k => v.ip_address }
}

output "all_vm_ips" {
  description = "All provisioned VMs and their IP addresses — use for Ansible inventory generation"
  value = merge(
    { for k, v in module.ccb_vms : k => v.ip_address },
    { for k, v in module.mdm_vms : k => v.ip_address },
    { for k, v in module.soa_vms : k => v.ip_address },
    { for k, v in module.ohs_vms : k => v.ip_address },
  )
}

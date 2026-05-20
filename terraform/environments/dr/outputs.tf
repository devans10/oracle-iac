output "ccb_vm_ips" {
  description = "CC&B DR VM names and IP addresses (across both DR KVM hosts)"
  value = merge(
    { for k, v in module.ccb_vms_host_a : k => v.ip_address },
    { for k, v in module.ccb_vms_host_b : k => v.ip_address },
  )
}

output "mdm_vm_ips" {
  description = "MDM DR VM names and IP addresses (across both DR KVM hosts)"
  value = merge(
    { for k, v in module.mdm_vms_host_a : k => v.ip_address },
    { for k, v in module.mdm_vms_host_b : k => v.ip_address },
  )
}

output "soa_vm_ips" {
  description = "SOA Suite DR VM names and IP addresses (across both DR KVM hosts)"
  value = merge(
    { for k, v in module.soa_vms_host_a : k => v.ip_address },
    { for k, v in module.soa_vms_host_b : k => v.ip_address },
  )
}

output "ohs_vm_ips" {
  description = "OHS DR VM names and IP addresses"
  value       = { for k, v in module.ohs_vms : k => v.ip_address }
}

output "all_vm_ips" {
  description = "All provisioned DR VMs and their IP addresses — use for Ansible inventory generation"
  value = merge(
    { for k, v in module.ccb_vms_host_a : k => v.ip_address },
    { for k, v in module.ccb_vms_host_b : k => v.ip_address },
    { for k, v in module.mdm_vms_host_a : k => v.ip_address },
    { for k, v in module.mdm_vms_host_b : k => v.ip_address },
    { for k, v in module.soa_vms_host_a : k => v.ip_address },
    { for k, v in module.soa_vms_host_b : k => v.ip_address },
    { for k, v in module.ohs_vms : k => v.ip_address },
  )
}

output "dev_vm_ips" {
  description = "Dev VM names and IP addresses"
  value       = { for k, v in module.dev_vms : k => v.ip_address }
}

output "db_vm_private_ip" {
  description = "Private IP address of the Oracle DB VM — use in Ansible inventory as oracle_db host"
  value       = module.oracle_db_vm.private_ip_address
}

output "ccb_app_vm_private_ip" {
  description = "Private IP address of the CCB application VM — use in Ansible inventory as ccb group"
  value       = module.ccb_app_vm.private_ip_address
}

output "mdm_app_vm_private_ip" {
  description = "Private IP address of the MDM application VM — use in Ansible inventory as mdm group"
  value       = module.mdm_app_vm.private_ip_address
}

output "soa_app_vm_private_ip" {
  description = "Private IP address of the SOA application VM — use in Ansible inventory as soa group"
  value       = module.soa_app_vm.private_ip_address
}

output "vnet_id" {
  description = "Resource ID of the VNet created for this environment"
  value       = azurerm_virtual_network.main.id
}

output "app_subnet_id" {
  description = "Resource ID of the application subnet (CCB, MDM, SOA VMs)"
  value       = azurerm_subnet.app.id
}

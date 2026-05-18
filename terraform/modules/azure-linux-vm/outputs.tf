output "vm_id" {
  description = "Resource ID of the Azure Linux virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "private_ip_address" {
  description = "Actual private IP address assigned to the VM NIC (reflects static or dynamic allocation)"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "vm_name" {
  description = "VM name as provided in var.vm_name (convenience passthrough for use in parent modules)"
  value       = azurerm_linux_virtual_machine.vm.name
}

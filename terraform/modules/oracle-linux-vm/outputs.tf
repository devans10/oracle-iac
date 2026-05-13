output "ip_address" {
  value       = libvirt_domain.vm.network_interface[0].addresses[0]
  description = "VM IP address assigned by DHCP/lease"
}
output "vm_name" {
  value       = libvirt_domain.vm.name
  description = "VM name"
}

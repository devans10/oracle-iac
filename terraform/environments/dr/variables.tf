variable "libvirt_uri_dr_ccb_a" {
  description = "libvirt connection URI for DR KVM host CCB-A (hosts CCB web/iws/batch -01 VMs at DR site)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_dr_ccb_b" {
  description = "libvirt connection URI for DR KVM host CCB-B (hosts CCB web/iws/batch -02 VMs at DR site)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_dr_mdm_a" {
  description = "libvirt connection URI for DR KVM host MDM-A (hosts MDM web/iws/batch -01 VMs at DR site)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_dr_mdm_b" {
  description = "libvirt connection URI for DR KVM host MDM-B (hosts MDM web/iws/batch -02 VMs at DR site)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_dr_soa_a" {
  description = "libvirt connection URI for DR KVM host SOA-A (hosts all SOA -01/-wsm VMs at DR site)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_dr_soa_b" {
  description = "libvirt connection URI for DR KVM host SOA-B (hosts all SOA -02 VMs at DR site)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_dr_web" {
  description = "libvirt connection URI for DR KVM host WEB (hosts OHS cluster VMs at DR site)"
  type        = string
  sensitive   = true
}

variable "oracle_linux_image" {
  description = "Path or URL to Oracle Linux base image (qcow2)"
  type        = string
}

variable "app_network" {
  description = "libvirt network name for application VMs"
  type        = string
  default     = "oracle-net"
}

variable "ssh_public_key" {
  description = "SSH public key injected into VMs for oracle and root users"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name — identifies this as the DR site"
  type        = string
  default     = "dr"
}

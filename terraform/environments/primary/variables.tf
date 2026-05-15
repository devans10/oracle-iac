variable "libvirt_uri_ccb_a" {
  description = "libvirt connection URI for KVM host CCB-A (hosts CCB web/iws/batch -01 VMs)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_ccb_b" {
  description = "libvirt connection URI for KVM host CCB-B (hosts CCB web/iws/batch -02 VMs)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_mdm_a" {
  description = "libvirt connection URI for KVM host MDM-A (hosts MDM web/iws/batch -01 VMs)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_mdm_b" {
  description = "libvirt connection URI for KVM host MDM-B (hosts MDM web/iws/batch -02 VMs)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_soa_a" {
  description = "libvirt connection URI for KVM host SOA-A (hosts all SOA -01/-admin VMs)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_soa_b" {
  description = "libvirt connection URI for KVM host SOA-B (hosts all SOA -02 VMs)"
  type        = string
  sensitive   = true
}

variable "libvirt_uri_web" {
  description = "libvirt connection URI for KVM host WEB (hosts OHS cluster VMs)"
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
  default     = "oracle-app-net"
}

variable "ssh_pubkey" {
  description = "SSH public key injected into VMs for oracle and root users"
  type        = string
}

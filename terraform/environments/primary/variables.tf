variable "libvirt_uri" {
  description = "libvirt connection URI for primary KVM hosts"
  type        = string
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

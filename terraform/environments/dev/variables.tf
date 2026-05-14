variable "libvirt_uri" {
  description = "libvirt connection URI for dev KVM host"
  type        = string
}

variable "oracle_linux_image" {
  description = "Path or URL to Oracle Linux base image (qcow2)"
  type        = string
}

variable "app_network" {
  description = "libvirt network name for dev VMs"
  type        = string
  default     = "oracle-dev-net"
}

variable "ssh_pubkey" {
  description = "SSH public key injected into VMs for oracle and root users"
  type        = string
}

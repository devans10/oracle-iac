variable "vm_name"     { type = string; description = "VM hostname (e.g., ccb-web-vm-01)" }
variable "app"         { type = string; description = "Application (ccb, mdm, soa, ohs)" }
variable "role"        { type = string; description = "Role within app (web, iws, batch, admin)" }
variable "vcpu"        { type = number; description = "Number of vCPUs" }
variable "memory_mb"   { type = number; description = "Memory in MB" }
variable "kvm_host"    { type = string; description = "Target KVM host for anti-affinity tracking" }
variable "base_image"  { type = string; description = "Base qcow2 image name" }
variable "network"     { type = string; description = "libvirt network name" }
variable "env"         { type = string; description = "Environment: primary or dr" }
variable "storage_pool"{ type = string; default = "default"; description = "libvirt storage pool" }
variable "os_disk_gb"  { type = number; default = 150; description = "OS disk size in GB" }
variable "ssh_pubkey"  { type = string; description = "SSH public key for oracle user" }

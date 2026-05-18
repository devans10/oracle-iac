variable "resource_group_name" {
  description = "Name of the existing Azure resource group to deploy resources into"
  type        = string
}

variable "location" {
  description = "Azure region for all resources (must match the existing resource group's location)"
  type        = string
}

variable "subnet_id" {
  description = "Resource ID of the subnet to attach the NIC to"
  type        = string
}

variable "vm_name" {
  description = "VM name used as the hostname and resource name prefix (e.g., ccb-web-vm-01)"
  type        = string
}

variable "vm_size" {
  description = "Azure VM SKU (e.g., Standard_D4s_v3)"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 100
}

variable "data_disk_size_gb" {
  description = "Data disk size in GB. Set to 0 to skip data disk creation (no data disk attached)"
  type        = number
  default     = 0
}

variable "data_disk_lun" {
  description = "LUN number for the data disk attachment"
  type        = number
  default     = 10
}

variable "admin_username" {
  description = "Admin user created on the VM (used for SSH access)"
  type        = string
  default     = "oracle"
}

variable "ssh_public_key" {
  description = "SSH public key content injected for the admin user"
  type        = string
  sensitive   = true
}

variable "oracle_linux_image" {
  description = "Oracle Linux marketplace image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "ol94-lvm"
    version   = "latest"
  }
}

variable "tags" {
  description = "Map of tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}

variable "private_ip_address" {
  description = "Static private IP address. Leave empty string to use dynamic allocation"
  type        = string
  default     = ""
}

variable "subscription_id" {
  description = "Azure subscription ID used by the azurerm provider"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Name of the existing Azure resource group (prerequisite — must already exist before apply)"
  type        = string
}

variable "location" {
  description = "Azure region for all resources created by this environment (must match the existing resource group)"
  type        = string
  default     = "eastus"
}

variable "environment_name" {
  description = "Short environment label applied to all resource tags and name prefixes"
  type        = string
  default     = "azure-dev"
}

variable "ssh_public_key" {
  description = "SSH public key content injected into VMs for the oracle admin user"
  type        = string
  sensitive   = true
}

variable "vnet_address_space" {
  description = "CIDR block for the VNet created in this environment"
  type        = string
  default     = "10.10.0.0/16"
}

variable "app_subnet_cidr" {
  description = "CIDR block for the application VMs subnet (CCB, MDM, SOA)"
  type        = string
  default     = "10.10.1.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR block for the database VMs subnet (Oracle DB single-instance)"
  type        = string
  default     = "10.10.2.0/24"
}

variable "app_vm_size" {
  description = "Azure VM SKU for application VMs (CCB, MDM, SOA)"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "db_vm_size" {
  description = "Azure VM SKU for the Oracle DB VM (larger than app VMs to satisfy Oracle 19c SGA requirements)"
  type        = string
  default     = "Standard_D8s_v3"
}

variable "db_data_disk_size_gb" {
  description = "Size in GB of the Premium SSD data disk attached to the Oracle DB VM (holds Oracle data files, redo logs, archive logs)"
  type        = number
  default     = 256
}

variable "oracle_linux_sku" {
  description = "Oracle Linux marketplace image SKU (e.g., ol94-lvm for Oracle Linux 9.4 LVM layout)"
  type        = string
  default     = "ol94-lvm"
}

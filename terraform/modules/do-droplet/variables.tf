variable "droplet_name" {
  description = "Droplet hostname and name (e.g., do-dev-ccb-app-vm-01)"
  type        = string
}

variable "region" {
  description = "DigitalOcean region slug (e.g., nyc3)"
  type        = string
}

variable "size" {
  description = "DigitalOcean Droplet size slug"
  type        = string
  default     = "s-4vcpu-8gb"
}

variable "image" {
  description = "Droplet image slug or custom image ID. No default — operators must upload an Oracle Linux image via DO Custom Images (doctl compute image list --public)."
  type        = string
}

variable "ssh_key_ids" {
  description = "List of DigitalOcean SSH key IDs to inject into the Droplet (doctl compute ssh-key list)"
  type        = list(number)
}

variable "vpc_uuid" {
  description = "VPC UUID for private networking"
  type        = string
}

variable "data_volume_size_gb" {
  description = "Size in GB of the Block Storage volume attached for Oracle data files. Set to 0 to skip volume creation."
  type        = number
  default     = 0
}

variable "tags" {
  description = "List of tags to apply to the Droplet"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "Cloud-init script passed as user data to the Droplet. Leave empty to omit."
  type        = string
  default     = ""
}

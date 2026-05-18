variable "do_token" {
  description = "DigitalOcean API token — retrieved from BeyondTrust PasswordSafe or supplied via TF_VAR_do_token; never hardcoded"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region slug for all resources in this environment"
  type        = string
  default     = "nyc3"
}

variable "environment_name" {
  description = "Short name for this environment — used in tags and resource names"
  type        = string
  default     = "do-dev"
}

variable "oracle_linux_image" {
  description = "Droplet image slug or custom image ID for Oracle Linux. No default — upload Oracle Linux via DO Custom Images before running plan (doctl compute image list --public)."
  type        = string
}

variable "ssh_key_ids" {
  description = "DigitalOcean SSH key IDs already uploaded to the account (doctl compute ssh-key list)"
  type        = list(number)
}

variable "vpc_cidr" {
  description = "IP range for the private VPC used by all Droplets in this environment"
  type        = string
  default     = "10.20.0.0/20"
}

variable "app_droplet_size" {
  description = "Droplet size slug for CC&B, MDM, and SOA app Droplets"
  type        = string
  default     = "s-4vcpu-8gb"
}

variable "db_droplet_size" {
  description = "Droplet size slug for the Oracle 19c DB Droplet — must have at least 16 GB RAM"
  type        = string
  default     = "s-8vcpu-16gb"
}

variable "db_volume_size_gb" {
  description = "Size in GB of the Block Storage volume attached to the DB Droplet for Oracle data files, redo logs, and archived logs"
  type        = number
  default     = 256
}

variable "project_name" {
  description = "DigitalOcean project name used to group all environment resources"
  type        = string
  default     = "oracle-iac-do-dev"
}

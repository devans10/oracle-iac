output "droplet_id" {
  description = "Numeric ID of the Droplet — used for firewall and project resource references"
  value       = digitalocean_droplet.this.id
}

output "droplet_urn" {
  description = "URN of the Droplet — used for DO project resource membership"
  value       = digitalocean_droplet.this.urn
}

output "ipv4_address" {
  description = "Public IPv4 address of the Droplet — for initial SSH access"
  value       = digitalocean_droplet.this.ipv4_address
}

output "ipv4_address_private" {
  description = "Private IPv4 address of the Droplet within the VPC — used for Ansible inventory"
  value       = digitalocean_droplet.this.ipv4_address_private
}

output "droplet_name" {
  description = "Name of the Droplet"
  value       = digitalocean_droplet.this.name
}

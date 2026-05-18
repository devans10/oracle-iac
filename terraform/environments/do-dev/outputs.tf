output "db_droplet_private_ip" {
  description = "Private VPC IP of the Oracle 19c DB Droplet — use in Ansible inventory and JDBC connect strings"
  value       = module.oracle_db.ipv4_address_private
}

output "ccb_app_private_ip" {
  description = "Private VPC IP of the CC&B app Droplet — use in Ansible inventory"
  value       = module.ccb_app.ipv4_address_private
}

output "mdm_app_private_ip" {
  description = "Private VPC IP of the MDM app Droplet — use in Ansible inventory"
  value       = module.mdm_app.ipv4_address_private
}

output "soa_app_private_ip" {
  description = "Private VPC IP of the SOA Suite app Droplet — use in Ansible inventory"
  value       = module.soa_app.ipv4_address_private
}

output "db_droplet_public_ip" {
  description = "Public IP of the Oracle 19c DB Droplet — for initial SSH access and sqlplus from operator workstation"
  value       = module.oracle_db.ipv4_address
}

output "ccb_app_public_ip" {
  description = "Public IP of the CC&B app Droplet — for initial SSH access"
  value       = module.ccb_app.ipv4_address
}

output "mdm_app_public_ip" {
  description = "Public IP of the MDM app Droplet — for initial SSH access"
  value       = module.mdm_app.ipv4_address
}

output "soa_app_public_ip" {
  description = "Public IP of the SOA Suite app Droplet — for initial SSH access"
  value       = module.soa_app.ipv4_address
}

output "vpc_id" {
  description = "UUID of the VPC created for this environment — reference for additional resources"
  value       = digitalocean_vpc.this.id
}

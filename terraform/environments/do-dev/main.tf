locals {
  env = var.environment_name

  # Common tags applied to every Droplet in this environment.
  common_tags = ["oracle-iac", var.environment_name]
}

# ---------------------------------------------------------------------------
# VPC — private network for all Droplets
# ---------------------------------------------------------------------------

resource "digitalocean_vpc" "this" {
  name     = "oracle-iac-${local.env}-vpc"
  region   = var.region
  ip_range = var.vpc_cidr
}

# ---------------------------------------------------------------------------
# Droplets — one per application role
# Dev scale: DB, CCB app, MDM app, SOA app (all 4 SOA domains colocated)
# ---------------------------------------------------------------------------

# Oracle 19c DB — shared CDB with PDBs for CCB, MDM, and SOA schemas
module "oracle_db" {
  source = "../../modules/do-droplet"

  droplet_name        = "do-dev-db-vm-01"
  region              = var.region
  size                = var.db_droplet_size
  image               = var.oracle_linux_image
  ssh_key_ids         = var.ssh_key_ids
  vpc_uuid            = digitalocean_vpc.this.id
  data_volume_size_gb = var.db_volume_size_gb
  tags                = local.common_tags
}

# CC&B 25.10 app server — Web, IWS, and Batch WLS clusters colocated on one VM in dev
module "ccb_app" {
  source = "../../modules/do-droplet"

  droplet_name = "do-dev-ccb-app-vm-01"
  region       = var.region
  size         = var.app_droplet_size
  image        = var.oracle_linux_image
  ssh_key_ids  = var.ssh_key_ids
  vpc_uuid     = digitalocean_vpc.this.id
  tags         = local.common_tags
}

# MDM 25.10 app server — Web, IWS, and Batch WLS clusters colocated on one VM in dev
module "mdm_app" {
  source = "../../modules/do-droplet"

  droplet_name = "do-dev-mdm-app-vm-01"
  region       = var.region
  size         = var.app_droplet_size
  image        = var.oracle_linux_image
  ssh_key_ids  = var.ssh_key_ids
  vpc_uuid     = digitalocean_vpc.this.id
  tags         = local.common_tags
}

# SOA Suite 12.2.1.4 app server — all 4 WLS domains (soa_int, soa_if, soa_web, soa_sgg) colocated in dev
module "soa_app" {
  source = "../../modules/do-droplet"

  droplet_name = "do-dev-soa-app-vm-01"
  region       = var.region
  size         = var.app_droplet_size
  image        = var.oracle_linux_image
  ssh_key_ids  = var.ssh_key_ids
  vpc_uuid     = digitalocean_vpc.this.id
  tags         = local.common_tags
}

# ---------------------------------------------------------------------------
# DO Project — groups all environment resources for billing and access control
# ---------------------------------------------------------------------------

resource "digitalocean_project" "this" {
  name        = var.project_name
  description = "Oracle CC&B / MDM / SOA Suite do-dev environment"
  purpose     = "Other"
  environment = "Development"
}

resource "digitalocean_project_resources" "this" {
  project = digitalocean_project.this.id

  resources = [
    module.oracle_db.droplet_urn,
    module.ccb_app.droplet_urn,
    module.mdm_app.droplet_urn,
    module.soa_app.droplet_urn,
  ]
}

# ---------------------------------------------------------------------------
# Firewall — dev environment rules
# SSH open to all for dev access; application ports restricted to VPC CIDR
# ---------------------------------------------------------------------------

resource "digitalocean_firewall" "this" {
  name = "oracle-iac-${local.env}-fw"

  droplet_ids = [
    module.oracle_db.droplet_id,
    module.ccb_app.droplet_id,
    module.mdm_app.droplet_id,
    module.soa_app.droplet_id,
  ]

  # SSH — open to all in dev for operator access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # WLS Admin / Managed Server ports — restricted to VPC CIDR
  inbound_rule {
    protocol         = "tcp"
    port_range       = "7001"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8001"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8101"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8201"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8301"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8401"
    source_addresses = [var.vpc_cidr]
  }

  # Oracle Net listener — restricted to VPC CIDR
  inbound_rule {
    protocol         = "tcp"
    port_range       = "1521"
    source_addresses = [var.vpc_cidr]
  }

  # WLS Node Manager — restricted to VPC CIDR
  inbound_rule {
    protocol         = "tcp"
    port_range       = "5556"
    source_addresses = [var.vpc_cidr]
  }

  # ICMP (ping) — restricted to VPC CIDR for health checks
  inbound_rule {
    protocol         = "icmp"
    source_addresses = [var.vpc_cidr]
  }

  # Outbound — allow all egress (OS updates, Oracle software downloads, BeyondTrust API)
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

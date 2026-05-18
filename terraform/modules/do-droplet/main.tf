# do-droplet module — provisions a single DigitalOcean Droplet with optional Block Storage volume.
# See variables.tf for all inputs; outputs.tf for IP and URN outputs.

resource "digitalocean_droplet" "this" {
  name               = var.droplet_name
  region             = var.region
  size               = var.size
  image              = var.image
  ssh_keys           = var.ssh_key_ids
  vpc_uuid           = var.vpc_uuid
  private_networking = true
  tags               = var.tags
  user_data          = var.user_data != "" ? var.user_data : null
}

resource "digitalocean_volume" "data" {
  count = var.data_volume_size_gb > 0 ? 1 : 0

  name                    = "${var.droplet_name}-data"
  region                  = var.region
  size                    = var.data_volume_size_gb
  initial_filesystem_type = "xfs"
  description             = "Oracle data volume for ${var.droplet_name} — mounted at /u01"
}

resource "digitalocean_volume_attachment" "data" {
  count = var.data_volume_size_gb > 0 ? 1 : 0

  droplet_id = digitalocean_droplet.this.id
  volume_id  = digitalocean_volume.data[0].id
}

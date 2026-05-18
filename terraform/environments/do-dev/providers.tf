terraform {
  required_version = ">= 1.5"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  backend "http" {
    # Configure via: terraform init -backend-config=../../backend.hcl
  }
}

provider "digitalocean" {
  token = var.do_token
}

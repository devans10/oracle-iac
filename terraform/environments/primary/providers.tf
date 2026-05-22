terraform {
  required_version = ">= 1.5"

  required_providers {
    libvirt = {
      source  = "registry.terraform.io/dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }

  backend "http" {
    # Configure via: terraform init -backend-config=../../backend.hcl
  }
}

provider "libvirt" {
  alias = "ccb_a"
  uri   = var.libvirt_uri_ccb_a
}

provider "libvirt" {
  alias = "ccb_b"
  uri   = var.libvirt_uri_ccb_b
}

provider "libvirt" {
  alias = "mdm_a"
  uri   = var.libvirt_uri_mdm_a
}

provider "libvirt" {
  alias = "mdm_b"
  uri   = var.libvirt_uri_mdm_b
}

provider "libvirt" {
  alias = "soa_a"
  uri   = var.libvirt_uri_soa_a
}

provider "libvirt" {
  alias = "soa_b"
  uri   = var.libvirt_uri_soa_b
}

provider "libvirt" {
  alias = "soa_c"
  uri   = var.libvirt_uri_soa_c
}

provider "libvirt" {
  alias = "soa_d"
  uri   = var.libvirt_uri_soa_d
}

provider "libvirt" {
  alias = "web"
  uri   = var.libvirt_uri_web
}

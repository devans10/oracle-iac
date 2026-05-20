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
  alias = "dr_ccb_a"
  uri   = var.libvirt_uri_dr_ccb_a
}

provider "libvirt" {
  alias = "dr_ccb_b"
  uri   = var.libvirt_uri_dr_ccb_b
}

provider "libvirt" {
  alias = "dr_mdm_a"
  uri   = var.libvirt_uri_dr_mdm_a
}

provider "libvirt" {
  alias = "dr_mdm_b"
  uri   = var.libvirt_uri_dr_mdm_b
}

provider "libvirt" {
  alias = "dr_soa_a"
  uri   = var.libvirt_uri_dr_soa_a
}

provider "libvirt" {
  alias = "dr_soa_b"
  uri   = var.libvirt_uri_dr_soa_b
}

provider "libvirt" {
  alias = "dr_web"
  uri   = var.libvirt_uri_dr_web
}

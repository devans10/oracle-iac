terraform {
  required_version = ">= 1.5"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }

  backend "http" {
    # Configure via: terraform init -backend-config=../../backend.hcl
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

locals {
  env = "dev"

  # Dev topology: colocated roles on fewer, smaller VMs.
  # Admin Server and Managed Server run on the same VM per app.
  # Anti-affinity not required in dev — single KVM host is acceptable.
  # Adjust data_disk_gb downward — dev media share is typically NFS-mounted.

  dev_vms = {
    # CC&B: 1 admin VM + 1 MS VM (web/iws/batch colocated via inventory mapping)
    "dev-ccb-admin-vm-01" = { app = "ccb", role = "admin", vcpu = 4, memory_mb = 16384, data_disk_gb = 200 }
    "dev-ccb-ms-vm-01"    = { app = "ccb", role = "ms", vcpu = 8, memory_mb = 32768, data_disk_gb = 300 }

    # MDM: same 2-VM footprint
    "dev-mdm-admin-vm-01" = { app = "mdm", role = "admin", vcpu = 4, memory_mb = 16384, data_disk_gb = 200 }
    "dev-mdm-ms-vm-01"    = { app = "mdm", role = "ms", vcpu = 8, memory_mb = 32768, data_disk_gb = 300 }

    # SOA: 1 VM per domain (Admin + MS colocated). Only soa_int deployed by default in dev.
    # Enable additional domains by adding entries here and updating group_vars/dev/sizing.yml.
    "dev-soa-int-vm-01" = { app = "soa", role = "soa-int", vcpu = 8, memory_mb = 32768, data_disk_gb = 300 }

    # OHS: optional in dev — controlled by enable_ohs in group_vars/dev/sizing.yml.
    # Remove this entry to skip OHS VM provisioning entirely in dev.
    "dev-ohs-vm-01" = { app = "ohs", role = "ohs", vcpu = 2, memory_mb = 4096, data_disk_gb = 100 }
  }
}

module "dev_vms" {
  source   = "../../modules/oracle-linux-vm"
  for_each = local.dev_vms

  vm_name      = each.key
  app          = each.value.app
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_pubkey
  env          = local.env
}

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
  # Configure per KVM host — use for_each across KVM hosts
  uri = var.libvirt_uri
}

locals {
  env = "primary"

  # CC&B VM definitions — 7 VMs across 2 KVM hosts (anti-affinity: -a/-b pairs)
  ccb_vms = {
    "ccb-admin-vm-01" = { role = "admin", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-ccb-a", data_disk_gb = 300 }
    "ccb-web-vm-01"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-ccb-a", data_disk_gb = 500 }
    "ccb-web-vm-02"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-ccb-b", data_disk_gb = 500 }
    "ccb-iws-vm-01"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-ccb-a", data_disk_gb = 500 }
    "ccb-iws-vm-02"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-ccb-b", data_disk_gb = 500 }
    "ccb-batch-vm-01" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-ccb-a", data_disk_gb = 1000 }
    "ccb-batch-vm-02" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-ccb-b", data_disk_gb = 1000 }
  }

  # MDM VM definitions — 7 VMs across 2 KVM hosts
  mdm_vms = {
    "mdm-admin-vm-01" = { role = "admin", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-mdm-a", data_disk_gb = 300 }
    "mdm-web-vm-01"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-mdm-a", data_disk_gb = 500 }
    "mdm-web-vm-02"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-mdm-b", data_disk_gb = 500 }
    "mdm-iws-vm-01"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-mdm-a", data_disk_gb = 500 }
    "mdm-iws-vm-02"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-mdm-b", data_disk_gb = 500 }
    "mdm-batch-vm-01" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-mdm-a", data_disk_gb = 1000 }
    "mdm-batch-vm-02" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-mdm-b", data_disk_gb = 1000 }
  }

  # SOA Suite VM definitions — 3 VMs per domain (2 MS + 1 WSM), 4 domains = 12 VMs
  soa_vms = {
    "soa-int-vm-01"     = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-a", data_disk_gb = 500 }
    "soa-int-vm-02"     = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-b", data_disk_gb = 500 }
    "soa-int-wsm-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-a", data_disk_gb = 300 }
    "soa-if-vm-01"      = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-a", data_disk_gb = 500 }
    "soa-if-vm-02"      = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-b", data_disk_gb = 500 }
    "soa-if-wsm-vm-01"  = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-b", data_disk_gb = 300 }
    "soa-web-vm-01"     = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-a", data_disk_gb = 500 }
    "soa-web-vm-02"     = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-b", data_disk_gb = 500 }
    "soa-web-wsm-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-a", data_disk_gb = 300 }
    "soa-sgg-vm-01"     = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-a", data_disk_gb = 500 }
    "soa-sgg-vm-02"     = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-b", data_disk_gb = 500 }
    "soa-sgg-wsm-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-b", data_disk_gb = 300 }
  }

  # Oracle HTTP Server — 3-node cluster on the web KVM host
  ohs_vms = {
    "ohs-vm-01" = { role = "ohs", vcpu = 4, memory_mb = 8192, kvm_host = "kvm-host-web", data_disk_gb = 150 }
    "ohs-vm-02" = { role = "ohs", vcpu = 4, memory_mb = 8192, kvm_host = "kvm-host-web", data_disk_gb = 150 }
    "ohs-vm-03" = { role = "ohs", vcpu = 4, memory_mb = 8192, kvm_host = "kvm-host-web", data_disk_gb = 150 }
  }
}

module "ccb_vms" {
  source   = "../../modules/oracle-linux-vm"
  for_each = local.ccb_vms

  vm_name      = each.key
  app          = "ccb"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_pubkey
  env          = local.env
}

module "mdm_vms" {
  source   = "../../modules/oracle-linux-vm"
  for_each = local.mdm_vms

  vm_name      = each.key
  app          = "mdm"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_pubkey
  env          = local.env
}

module "soa_vms" {
  source   = "../../modules/oracle-linux-vm"
  for_each = local.soa_vms

  vm_name      = each.key
  app          = "soa"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_pubkey
  env          = local.env
}

module "ohs_vms" {
  source   = "../../modules/oracle-linux-vm"
  for_each = local.ohs_vms

  vm_name      = each.key
  app          = "ohs"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_pubkey
  env          = local.env
}

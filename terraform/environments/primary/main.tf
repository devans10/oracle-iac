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

  # CC&B VM definitions
  ccb_vms = {
    "ccb-admin-vm-01"  = { role = "admin",  vcpu = 4,  memory_mb = 16384,  kvm_host = "kvm-host-ccb-a" }
    "ccb-web-vm-01"    = { role = "web",    vcpu = 16, memory_mb = 65536,  kvm_host = "kvm-host-ccb-a" }
    "ccb-web-vm-02"    = { role = "web",    vcpu = 16, memory_mb = 65536,  kvm_host = "kvm-host-ccb-b" }
    "ccb-iws-vm-01"    = { role = "iws",    vcpu = 8,  memory_mb = 32768,  kvm_host = "kvm-host-ccb-a" }
    "ccb-iws-vm-02"    = { role = "iws",    vcpu = 8,  memory_mb = 32768,  kvm_host = "kvm-host-ccb-b" }
    "ccb-batch-vm-01"  = { role = "batch",  vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-ccb-a" }
    "ccb-batch-vm-02"  = { role = "batch",  vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-ccb-b" }
  }

  # MDM VM definitions
  mdm_vms = {
    "mdm-admin-vm-01"  = { role = "admin",  vcpu = 4,  memory_mb = 16384,  kvm_host = "kvm-host-mdm-a" }
    "mdm-web-vm-01"    = { role = "web",    vcpu = 16, memory_mb = 65536,  kvm_host = "kvm-host-mdm-a" }
    "mdm-web-vm-02"    = { role = "web",    vcpu = 16, memory_mb = 65536,  kvm_host = "kvm-host-mdm-b" }
    "mdm-iws-vm-01"    = { role = "iws",    vcpu = 8,  memory_mb = 32768,  kvm_host = "kvm-host-mdm-a" }
    "mdm-iws-vm-02"    = { role = "iws",    vcpu = 8,  memory_mb = 32768,  kvm_host = "kvm-host-mdm-b" }
    "mdm-batch-vm-01"  = { role = "batch",  vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-mdm-a" }
    "mdm-batch-vm-02"  = { role = "batch",  vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-mdm-b" }
  }
}

module "ccb_vms" {
  source   = "../../modules/oracle-linux-vm"
  for_each = local.ccb_vms

  vm_name    = each.key
  app        = "ccb"
  role       = each.value.role
  vcpu       = each.value.vcpu
  memory_mb  = each.value.memory_mb
  kvm_host   = each.value.kvm_host
  base_image = var.oracle_linux_image
  network    = var.app_network
  env        = local.env
}

module "mdm_vms" {
  source   = "../../modules/oracle-linux-vm"
  for_each = local.mdm_vms

  vm_name    = each.key
  app        = "mdm"
  role       = each.value.role
  vcpu       = each.value.vcpu
  memory_mb  = each.value.memory_mb
  kvm_host   = each.value.kvm_host
  base_image = var.oracle_linux_image
  network    = var.app_network
  env        = local.env
}

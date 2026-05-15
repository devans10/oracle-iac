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

  # Per-host subsets — required because providers = {} must be a static map per module block.
  # Anti-affinity is enforced by the provider binding: -a host for -01 VMs, -b host for -02 VMs.
  ccb_vms_host_a = { for k, v in local.ccb_vms : k => v if v.kvm_host == "kvm-host-ccb-a" }
  ccb_vms_host_b = { for k, v in local.ccb_vms : k => v if v.kvm_host == "kvm-host-ccb-b" }

  mdm_vms_host_a = { for k, v in local.mdm_vms : k => v if v.kvm_host == "kvm-host-mdm-a" }
  mdm_vms_host_b = { for k, v in local.mdm_vms : k => v if v.kvm_host == "kvm-host-mdm-b" }

  soa_vms_host_a = { for k, v in local.soa_vms : k => v if v.kvm_host == "kvm-host-soa-a" }
  soa_vms_host_b = { for k, v in local.soa_vms : k => v if v.kvm_host == "kvm-host-soa-b" }
}

# ---------------------------------------------------------------------------
# CC&B VMs — split by KVM host to enforce anti-affinity via provider binding
# ---------------------------------------------------------------------------

# CCB VMs on kvm-host-ccb-a (admin-vm-01, web-vm-01, iws-vm-01, batch-vm-01)
module "ccb_vms_host_a" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.ccb_vms_host_a
  providers = { libvirt = libvirt.ccb_a }

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

# CCB VMs on kvm-host-ccb-b (web-vm-02, iws-vm-02, batch-vm-02) — anti-affinity with ccb-a VMs
module "ccb_vms_host_b" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.ccb_vms_host_b
  providers = { libvirt = libvirt.ccb_b }

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

# ---------------------------------------------------------------------------
# MDM VMs — split by KVM host to enforce anti-affinity via provider binding
# ---------------------------------------------------------------------------

# MDM VMs on kvm-host-mdm-a (admin-vm-01, web-vm-01, iws-vm-01, batch-vm-01)
module "mdm_vms_host_a" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.mdm_vms_host_a
  providers = { libvirt = libvirt.mdm_a }

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

# MDM VMs on kvm-host-mdm-b (web-vm-02, iws-vm-02, batch-vm-02) — anti-affinity with mdm-a VMs
module "mdm_vms_host_b" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.mdm_vms_host_b
  providers = { libvirt = libvirt.mdm_b }

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

# ---------------------------------------------------------------------------
# SOA Suite VMs — split by KVM host to enforce anti-affinity via provider binding
# ---------------------------------------------------------------------------

# SOA VMs on kvm-host-soa-a (-vm-01 and wsm VMs assigned to soa-a)
module "soa_vms_host_a" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.soa_vms_host_a
  providers = { libvirt = libvirt.soa_a }

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

# SOA VMs on kvm-host-soa-b (-vm-02 and wsm VMs assigned to soa-b) — anti-affinity with soa-a VMs
module "soa_vms_host_b" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.soa_vms_host_b
  providers = { libvirt = libvirt.soa_b }

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

# ---------------------------------------------------------------------------
# OHS VMs — all 3 nodes on kvm-host-web (dedicated OHS KVM host)
# ---------------------------------------------------------------------------

module "ohs_vms" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.ohs_vms
  providers = { libvirt = libvirt.web }

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

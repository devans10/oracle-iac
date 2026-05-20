locals {
  env = "primary"

  # CC&B VM definitions — 11 VMs across 2 KVM hosts (anti-affinity: -a/-b pairs)
  ccb_vms = {
    "ccb-admin-vm-01" = { role = "admin", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-ccb-a", data_disk_gb = 300 }
    "ccb-web-vm-01"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-ccb-a", data_disk_gb = 500 }
    "ccb-web-vm-02"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-ccb-b", data_disk_gb = 500 }
    "ccb-iws-vm-01"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-ccb-a", data_disk_gb = 500 }
    "ccb-iws-vm-02"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-ccb-b", data_disk_gb = 500 }
    "ccb-web-vm-03"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-ccb-a", data_disk_gb = 500 }
    "ccb-web-vm-04"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-ccb-b", data_disk_gb = 500 }
    "ccb-iws-vm-03"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-ccb-a", data_disk_gb = 500 }
    "ccb-iws-vm-04"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-ccb-b", data_disk_gb = 500 }
    "ccb-batch-vm-01" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-ccb-a", data_disk_gb = 1000 }
    "ccb-batch-vm-02" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-ccb-b", data_disk_gb = 1000 }
  }

  # MDM VM definitions — 9 VMs across 2 KVM hosts
  mdm_vms = {
    "mdm-admin-vm-01" = { role = "admin", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-mdm-a", data_disk_gb = 300 }
    "mdm-web-vm-01"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-mdm-a", data_disk_gb = 500 }
    "mdm-web-vm-02"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "kvm-host-mdm-b", data_disk_gb = 500 }
    "mdm-iws-vm-01"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-mdm-a", data_disk_gb = 500 }
    "mdm-iws-vm-02"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-mdm-b", data_disk_gb = 500 }
    "mdm-iws-vm-03"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-mdm-a", data_disk_gb = 500 }
    "mdm-iws-vm-04"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-mdm-b", data_disk_gb = 500 }
    "mdm-batch-vm-01" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-mdm-a", data_disk_gb = 1000 }
    "mdm-batch-vm-02" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "kvm-host-mdm-b", data_disk_gb = 1000 }
  }

  # SOA Suite VM definitions — 38 VMs across 4 KVM hosts, one domain per host.
  # INTEG (6 VMs): admin+osb+soa+wsm on soa-a. INTF (9 VMs): admin+osb+soa+bam+odi+wsm on soa-b.
  # WEB (11 VMs): admin+osb(x4)+soa(x4)+bam+wsm on soa-c. SGG (12 VMs): admin+osb(x6)+soa(x4)+wsm on soa-d.
  soa_vms = {
    # INTEG_Domain — CC&B <-> MDM integration (kvm-host-soa-a)
    "adm-integ-vm-01" = { role = "soa-adm", vcpu = 4, memory_mb = 8192, kvm_host = "kvm-host-soa-a", data_disk_gb = 300 }
    "osb-integ-vm-01" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-a", data_disk_gb = 500 }
    "osb-integ-vm-02" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-a", data_disk_gb = 500 }
    "soa-integ-vm-01" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-a", data_disk_gb = 500 }
    "soa-integ-vm-02" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-a", data_disk_gb = 500 }
    "wsm-integ-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-a", data_disk_gb = 300 }
    # INTF_Domain — External interfaces (kvm-host-soa-b)
    "adm-intf-vm-01" = { role = "soa-adm", vcpu = 4, memory_mb = 8192, kvm_host = "kvm-host-soa-b", data_disk_gb = 300 }
    "osb-intf-vm-01" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-b", data_disk_gb = 500 }
    "osb-intf-vm-02" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-b", data_disk_gb = 500 }
    "soa-intf-vm-01" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-b", data_disk_gb = 500 }
    "soa-intf-vm-02" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-b", data_disk_gb = 500 }
    "bam-intf-vm-01" = { role = "soa-bam", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-b", data_disk_gb = 300 }
    "odi-intf-vm-01" = { role = "soa-odi", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-b", data_disk_gb = 300 }
    "odi-intf-vm-02" = { role = "soa-odi", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-b", data_disk_gb = 300 }
    "wsm-intf-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-b", data_disk_gb = 300 }
    # WEB_Domain — Web Portal integration (kvm-host-soa-c)
    "adm-web-vm-01" = { role = "soa-adm", vcpu = 4, memory_mb = 8192, kvm_host = "kvm-host-soa-c", data_disk_gb = 300 }
    "osb-web-vm-01" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-c", data_disk_gb = 500 }
    "osb-web-vm-02" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-c", data_disk_gb = 500 }
    "osb-web-vm-03" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-c", data_disk_gb = 500 }
    "osb-web-vm-04" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-c", data_disk_gb = 500 }
    "soa-web-vm-01" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-c", data_disk_gb = 500 }
    "soa-web-vm-02" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-c", data_disk_gb = 500 }
    "soa-web-vm-03" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-c", data_disk_gb = 500 }
    "soa-web-vm-04" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-c", data_disk_gb = 500 }
    "bam-web-vm-01" = { role = "soa-bam", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-c", data_disk_gb = 300 }
    "wsm-web-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-c", data_disk_gb = 300 }
    # SGG_Domain — Itron AMI (kvm-host-soa-d)
    "adm-sgg-vm-01" = { role = "soa-adm", vcpu = 4, memory_mb = 8192, kvm_host = "kvm-host-soa-d", data_disk_gb = 300 }
    "osb-sgg-vm-01" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "osb-sgg-vm-02" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "osb-sgg-vm-03" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "osb-sgg-vm-04" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "osb-sgg-vm-05" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "osb-sgg-vm-06" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "soa-sgg-vm-01" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "soa-sgg-vm-02" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "soa-sgg-vm-03" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "soa-sgg-vm-04" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "kvm-host-soa-d", data_disk_gb = 500 }
    "wsm-sgg-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "kvm-host-soa-d", data_disk_gb = 300 }
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
  soa_vms_host_c = { for k, v in local.soa_vms : k => v if v.kvm_host == "kvm-host-soa-c" }
  soa_vms_host_d = { for k, v in local.soa_vms : k => v if v.kvm_host == "kvm-host-soa-d" }
}

# ---------------------------------------------------------------------------
# CC&B VMs — split by KVM host to enforce anti-affinity via provider binding
# ---------------------------------------------------------------------------

# CCB VMs on kvm-host-ccb-a (admin-vm-01, web-vm-01/03, iws-vm-01/03, batch-vm-01)
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

# CCB VMs on kvm-host-ccb-b (web-vm-02/04, iws-vm-02/04, batch-vm-02) — anti-affinity with ccb-a VMs
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

# MDM VMs on kvm-host-mdm-a (admin-vm-01, web-vm-01, iws-vm-01/03, batch-vm-01)
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

# MDM VMs on kvm-host-mdm-b (web-vm-02, iws-vm-02/04, batch-vm-02) — anti-affinity with mdm-a VMs
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
# SOA Suite VMs — split by KVM host, one domain per host, 38 VMs total
# ---------------------------------------------------------------------------

# SOA VMs on kvm-host-soa-a (INTEG domain VMs)
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

# SOA VMs on kvm-host-soa-b (INTF domain VMs)
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

# SOA VMs on kvm-host-soa-c (WEB domain VMs)
module "soa_vms_host_c" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.soa_vms_host_c
  providers = { libvirt = libvirt.soa_c }

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

# SOA VMs on kvm-host-soa-d (SGG domain VMs)
module "soa_vms_host_d" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.soa_vms_host_d
  providers = { libvirt = libvirt.soa_d }

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

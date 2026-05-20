locals {
  env = var.environment

  # CC&B VM definitions — 11 VMs across 2 DR KVM hosts (anti-affinity: -a/-b pairs)
  # Sizing is identical to primary — standby must match production capacity
  ccb_vms = {
    "ccb-admin-dr-vm-01" = { role = "admin", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-ccb-a", data_disk_gb = 300 }
    "ccb-web-dr-vm-01"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "dr-kvm-ccb-a", data_disk_gb = 500 }
    "ccb-web-dr-vm-02"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "dr-kvm-ccb-b", data_disk_gb = 500 }
    "ccb-iws-dr-vm-01"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-ccb-a", data_disk_gb = 500 }
    "ccb-iws-dr-vm-02"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-ccb-b", data_disk_gb = 500 }
    "ccb-web-dr-vm-03"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "dr-kvm-ccb-a", data_disk_gb = 500 }
    "ccb-web-dr-vm-04"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "dr-kvm-ccb-b", data_disk_gb = 500 }
    "ccb-iws-dr-vm-03"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-ccb-a", data_disk_gb = 500 }
    "ccb-iws-dr-vm-04"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-ccb-b", data_disk_gb = 500 }
    "ccb-batch-dr-vm-01" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "dr-kvm-ccb-a", data_disk_gb = 1000 }
    "ccb-batch-dr-vm-02" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "dr-kvm-ccb-b", data_disk_gb = 1000 }
  }

  # MDM VM definitions — 9 VMs across 2 DR KVM hosts
  mdm_vms = {
    "mdm-admin-dr-vm-01" = { role = "admin", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-mdm-a", data_disk_gb = 300 }
    "mdm-web-dr-vm-01"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "dr-kvm-mdm-a", data_disk_gb = 500 }
    "mdm-web-dr-vm-02"   = { role = "web", vcpu = 16, memory_mb = 65536, kvm_host = "dr-kvm-mdm-b", data_disk_gb = 500 }
    "mdm-iws-dr-vm-01"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-mdm-a", data_disk_gb = 500 }
    "mdm-iws-dr-vm-02"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-mdm-b", data_disk_gb = 500 }
    "mdm-iws-dr-vm-03"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-mdm-a", data_disk_gb = 500 }
    "mdm-iws-dr-vm-04"   = { role = "iws", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-mdm-b", data_disk_gb = 500 }
    "mdm-batch-dr-vm-01" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "dr-kvm-mdm-a", data_disk_gb = 1000 }
    "mdm-batch-dr-vm-02" = { role = "batch", vcpu = 32, memory_mb = 131072, kvm_host = "dr-kvm-mdm-b", data_disk_gb = 1000 }
  }

  # SOA Suite VM definitions — 38 VMs across 4 KVM hosts, one domain per host.
  # INTEG (6 VMs): admin+osb+soa+wsm on soa-a. INTF (9 VMs): admin+osb+soa+bam+odi+wsm on soa-b.
  # WEB (11 VMs): admin+osb(x4)+soa(x4)+bam+wsm on soa-c. SGG (12 VMs): admin+osb(x6)+soa(x4)+wsm on soa-d.
  soa_vms = {
    # INTEG_Domain — CC&B <-> MDM integration (dr-kvm-soa-a)
    "adm-integ-dr-vm-01" = { role = "soa-adm", vcpu = 4, memory_mb = 8192, kvm_host = "dr-kvm-soa-a", data_disk_gb = 300 }
    "osb-integ-dr-vm-01" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-a", data_disk_gb = 500 }
    "osb-integ-dr-vm-02" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-a", data_disk_gb = 500 }
    "soa-integ-dr-vm-01" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-a", data_disk_gb = 500 }
    "soa-integ-dr-vm-02" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-a", data_disk_gb = 500 }
    "wsm-integ-dr-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-soa-a", data_disk_gb = 300 }
    # INTF_Domain — External interfaces (dr-kvm-soa-b)
    "adm-intf-dr-vm-01" = { role = "soa-adm", vcpu = 4, memory_mb = 8192, kvm_host = "dr-kvm-soa-b", data_disk_gb = 300 }
    "osb-intf-dr-vm-01" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-b", data_disk_gb = 500 }
    "osb-intf-dr-vm-02" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-b", data_disk_gb = 500 }
    "soa-intf-dr-vm-01" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-b", data_disk_gb = 500 }
    "soa-intf-dr-vm-02" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-b", data_disk_gb = 500 }
    "bam-intf-dr-vm-01" = { role = "soa-bam", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-soa-b", data_disk_gb = 300 }
    "odi-intf-dr-vm-01" = { role = "soa-odi", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-soa-b", data_disk_gb = 300 }
    "odi-intf-dr-vm-02" = { role = "soa-odi", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-soa-b", data_disk_gb = 300 }
    "wsm-intf-dr-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-soa-b", data_disk_gb = 300 }
    # WEB_Domain — Web Portal integration (dr-kvm-soa-c)
    "adm-web-dr-vm-01" = { role = "soa-adm", vcpu = 4, memory_mb = 8192, kvm_host = "dr-kvm-soa-c", data_disk_gb = 300 }
    "osb-web-dr-vm-01" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-c", data_disk_gb = 500 }
    "osb-web-dr-vm-02" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-c", data_disk_gb = 500 }
    "osb-web-dr-vm-03" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-c", data_disk_gb = 500 }
    "osb-web-dr-vm-04" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-c", data_disk_gb = 500 }
    "soa-web-dr-vm-01" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-c", data_disk_gb = 500 }
    "soa-web-dr-vm-02" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-c", data_disk_gb = 500 }
    "soa-web-dr-vm-03" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-c", data_disk_gb = 500 }
    "soa-web-dr-vm-04" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-c", data_disk_gb = 500 }
    "bam-web-dr-vm-01" = { role = "soa-bam", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-soa-c", data_disk_gb = 300 }
    "wsm-web-dr-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-soa-c", data_disk_gb = 300 }
    # SGG_Domain — Itron AMI (dr-kvm-soa-d)
    "adm-sgg-dr-vm-01" = { role = "soa-adm", vcpu = 4, memory_mb = 8192, kvm_host = "dr-kvm-soa-d", data_disk_gb = 300 }
    "osb-sgg-dr-vm-01" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "osb-sgg-dr-vm-02" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "osb-sgg-dr-vm-03" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "osb-sgg-dr-vm-04" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "osb-sgg-dr-vm-05" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "osb-sgg-dr-vm-06" = { role = "soa-osb", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "soa-sgg-dr-vm-01" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "soa-sgg-dr-vm-02" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "soa-sgg-dr-vm-03" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "soa-sgg-dr-vm-04" = { role = "soa-ms", vcpu = 8, memory_mb = 32768, kvm_host = "dr-kvm-soa-d", data_disk_gb = 500 }
    "wsm-sgg-dr-vm-01" = { role = "soa-wsm", vcpu = 4, memory_mb = 16384, kvm_host = "dr-kvm-soa-d", data_disk_gb = 300 }
  }

  # Oracle HTTP Server — 3-node cluster on the DR web KVM host
  ohs_vms = {
    "ohs-dr-vm-01" = { role = "ohs", vcpu = 4, memory_mb = 8192, kvm_host = "dr-kvm-web", data_disk_gb = 150 }
    "ohs-dr-vm-02" = { role = "ohs", vcpu = 4, memory_mb = 8192, kvm_host = "dr-kvm-web", data_disk_gb = 150 }
    "ohs-dr-vm-03" = { role = "ohs", vcpu = 4, memory_mb = 8192, kvm_host = "dr-kvm-web", data_disk_gb = 150 }
  }

  # Per-host subsets — required because providers = {} must be a static map per module block.
  # Anti-affinity is enforced by the provider binding: -a host for -01 VMs, -b host for -02 VMs.
  ccb_vms_host_a = { for k, v in local.ccb_vms : k => v if v.kvm_host == "dr-kvm-ccb-a" }
  ccb_vms_host_b = { for k, v in local.ccb_vms : k => v if v.kvm_host == "dr-kvm-ccb-b" }

  mdm_vms_host_a = { for k, v in local.mdm_vms : k => v if v.kvm_host == "dr-kvm-mdm-a" }
  mdm_vms_host_b = { for k, v in local.mdm_vms : k => v if v.kvm_host == "dr-kvm-mdm-b" }

  soa_vms_host_a = { for k, v in local.soa_vms : k => v if v.kvm_host == "dr-kvm-soa-a" }
  soa_vms_host_b = { for k, v in local.soa_vms : k => v if v.kvm_host == "dr-kvm-soa-b" }
  soa_vms_host_c = { for k, v in local.soa_vms : k => v if v.kvm_host == "dr-kvm-soa-c" }
  soa_vms_host_d = { for k, v in local.soa_vms : k => v if v.kvm_host == "dr-kvm-soa-d" }
}

# ---------------------------------------------------------------------------
# CC&B VMs — split by DR KVM host to enforce anti-affinity via provider binding
# ---------------------------------------------------------------------------

# CCB VMs on dr-kvm-ccb-a (admin-dr-vm-01, web-dr-vm-01/03, iws-dr-vm-01/03, batch-dr-vm-01)
module "ccb_vms_host_a" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.ccb_vms_host_a
  providers = { libvirt = libvirt.dr_ccb_a }

  vm_name      = each.key
  app          = "ccb"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

# CCB VMs on dr-kvm-ccb-b (web-dr-vm-02/04, iws-dr-vm-02/04, batch-dr-vm-02) — anti-affinity with dr-ccb-a VMs
module "ccb_vms_host_b" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.ccb_vms_host_b
  providers = { libvirt = libvirt.dr_ccb_b }

  vm_name      = each.key
  app          = "ccb"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

# ---------------------------------------------------------------------------
# MDM VMs — split by DR KVM host to enforce anti-affinity via provider binding
# ---------------------------------------------------------------------------

# MDM VMs on dr-kvm-mdm-a (admin-dr-vm-01, web-dr-vm-01, iws-dr-vm-01/03, batch-dr-vm-01)
module "mdm_vms_host_a" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.mdm_vms_host_a
  providers = { libvirt = libvirt.dr_mdm_a }

  vm_name      = each.key
  app          = "mdm"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

# MDM VMs on dr-kvm-mdm-b (web-dr-vm-02, iws-dr-vm-02/04, batch-dr-vm-02) — anti-affinity with dr-mdm-a VMs
module "mdm_vms_host_b" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.mdm_vms_host_b
  providers = { libvirt = libvirt.dr_mdm_b }

  vm_name      = each.key
  app          = "mdm"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

# ---------------------------------------------------------------------------
# SOA Suite VMs — split by DR KVM host, one domain per host, 38 VMs total
# ---------------------------------------------------------------------------

# SOA VMs on dr-kvm-soa-a (INTEG domain VMs)
module "soa_vms_host_a" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.soa_vms_host_a
  providers = { libvirt = libvirt.dr_soa_a }

  vm_name      = each.key
  app          = "soa"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

# SOA VMs on dr-kvm-soa-b (INTF domain VMs)
module "soa_vms_host_b" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.soa_vms_host_b
  providers = { libvirt = libvirt.dr_soa_b }

  vm_name      = each.key
  app          = "soa"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

# SOA VMs on dr-kvm-soa-c (WEB domain VMs)
module "soa_vms_host_c" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.soa_vms_host_c
  providers = { libvirt = libvirt.dr_soa_c }

  vm_name      = each.key
  app          = "soa"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

# SOA VMs on dr-kvm-soa-d (SGG domain VMs)
module "soa_vms_host_d" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.soa_vms_host_d
  providers = { libvirt = libvirt.dr_soa_d }

  vm_name      = each.key
  app          = "soa"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

# ---------------------------------------------------------------------------
# OHS VMs — all 3 nodes on dr-kvm-web (dedicated DR OHS KVM host)
# ---------------------------------------------------------------------------

module "ohs_vms" {
  source    = "../../modules/oracle-linux-vm"
  for_each  = local.ohs_vms
  providers = { libvirt = libvirt.dr_web }

  vm_name      = each.key
  app          = "ohs"
  role         = each.value.role
  vcpu         = each.value.vcpu
  memory_mb    = each.value.memory_mb
  kvm_host     = each.value.kvm_host
  data_disk_gb = each.value.data_disk_gb
  base_image   = var.oracle_linux_image
  network      = var.app_network
  ssh_pubkey   = var.ssh_public_key
  env          = local.env
}

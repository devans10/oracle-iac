# oracle-linux-vm module — provisions a single Oracle Linux VM on a KVM host
# See variables.tf for all inputs; outputs.tf for VM IP/name outputs

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

resource "libvirt_volume" "os_disk" {
  name             = "${var.vm_name}-os.qcow2"
  pool             = var.storage_pool
  base_volume_name = basename(var.base_image)
  size             = var.os_disk_gb * 1073741824
  format           = "qcow2"
}

resource "libvirt_volume" "data_disk" {
  name   = "${var.vm_name}-data.qcow2"
  pool   = var.storage_pool
  size   = var.data_disk_gb * 1073741824
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "init" {
  name = "${var.vm_name}-init.iso"
  pool = var.storage_pool
  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
    vm_name     = var.vm_name
    ssh_pubkey  = var.ssh_pubkey
    oracle_user = "oracle"
  })
}

resource "libvirt_domain" "vm" {
  name   = var.vm_name
  memory = var.memory_mb
  vcpu   = var.vcpu

  cloudinit = libvirt_cloudinit_disk.init.id

  disk {
    volume_id = libvirt_volume.os_disk.id
  }

  disk {
    volume_id = libvirt_volume.data_disk.id
  }

  network_interface {
    network_name   = var.network
    wait_for_lease = true
  }

  cpu {
    mode = "host-passthrough"
  }
}

# azure-linux-vm module — provisions a single Oracle Linux VM in Azure
# See variables.tf for all inputs; outputs.tf for VM ID and IP outputs.

locals {
  ip_allocation = var.private_ip_address != "" ? "Static" : "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = local.ip_allocation
    private_ip_address            = var.private_ip_address != "" ? var.private_ip_address : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  computer_name                   = var.vm_name
  tags                            = var.tags

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = var.oracle_linux_image.publisher
    offer     = var.oracle_linux_image.offer
    sku       = var.oracle_linux_image.sku
    version   = var.oracle_linux_image.version
  }

  os_disk {
    name                 = "${var.vm_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_managed_disk" "data" {
  count = var.data_disk_size_gb > 0 ? 1 : 0

  name                 = "${var.vm_name}-data-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count = var.data_disk_size_gb > 0 ? 1 : 0

  managed_disk_id    = azurerm_managed_disk.data[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = var.data_disk_lun
  caching            = "ReadWrite"
}

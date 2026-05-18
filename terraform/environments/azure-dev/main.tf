locals {
  common_tags = {
    environment = var.environment_name
    project     = "oracle-iac"
  }
}

# ---------------------------------------------------------------------------
# Existing resource group (prerequisite — must be created before terraform apply)
# ---------------------------------------------------------------------------
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "${var.environment_name}-vnet"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  address_space       = [var.vnet_address_space]
  tags                = local.common_tags
}

resource "azurerm_subnet" "app" {
  name                 = "${var.environment_name}-app-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_subnet_cidr]
}

resource "azurerm_subnet" "db" {
  name                 = "${var.environment_name}-db-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.db_subnet_cidr]
}

# ---------------------------------------------------------------------------
# Network Security Group
# Allows inbound: SSH, WLS admin ports, Oracle listener, Node Manager — VNet only
# Allows all outbound (package repos, BeyondTrust API, Azure services)
# ---------------------------------------------------------------------------
resource "azurerm_network_security_group" "main" {
  name                = "${var.environment_name}-nsg"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  tags                = local.common_tags

  security_rule {
    name                       = "allow-ssh-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "allow-wls-admin-inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["7001", "8001", "8101", "8201", "8301", "8401"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "allow-oracle-listener-inbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1521"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "allow-node-manager-inbound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5556"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "allow-all-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# ---------------------------------------------------------------------------
# Oracle DB VM — single-instance Oracle 19c (not RAC) for dev/azure environment
# ---------------------------------------------------------------------------
module "oracle_db_vm" {
  source = "../../modules/azure-linux-vm"

  vm_name             = "oracle-db-vm-01"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  subnet_id           = azurerm_subnet.db.id
  vm_size             = var.db_vm_size
  os_disk_size_gb     = 100
  data_disk_size_gb   = var.db_data_disk_size_gb
  data_disk_lun       = 10
  admin_username      = "oracle"
  ssh_public_key      = var.ssh_public_key
  oracle_linux_image = {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = var.oracle_linux_sku
    version   = "latest"
  }
  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# CCB app VM — CC&B 25.10 WLS (Web, IWS, Batch colocated in dev)
# ---------------------------------------------------------------------------
module "ccb_app_vm" {
  source = "../../modules/azure-linux-vm"

  vm_name             = "ccb-app-vm-01"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  subnet_id           = azurerm_subnet.app.id
  vm_size             = var.app_vm_size
  os_disk_size_gb     = 100
  data_disk_size_gb   = 0
  admin_username      = "oracle"
  ssh_public_key      = var.ssh_public_key
  oracle_linux_image = {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = var.oracle_linux_sku
    version   = "latest"
  }
  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# MDM app VM — MDM 25.10 WLS (Web, IWS, Batch colocated in dev)
# ---------------------------------------------------------------------------
module "mdm_app_vm" {
  source = "../../modules/azure-linux-vm"

  vm_name             = "mdm-app-vm-01"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  subnet_id           = azurerm_subnet.app.id
  vm_size             = var.app_vm_size
  os_disk_size_gb     = 100
  data_disk_size_gb   = 0
  admin_username      = "oracle"
  ssh_public_key      = var.ssh_public_key
  oracle_linux_image = {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = var.oracle_linux_sku
    version   = "latest"
  }
  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# SOA app VM — all four SOA Suite 12.2.1.4 WLS domains colocated in dev
# (soa_int, soa_if, soa_web, soa_sgg run on a single VM in this environment)
# ---------------------------------------------------------------------------
module "soa_app_vm" {
  source = "../../modules/azure-linux-vm"

  vm_name             = "soa-app-vm-01"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  subnet_id           = azurerm_subnet.app.id
  vm_size             = var.app_vm_size
  os_disk_size_gb     = 100
  data_disk_size_gb   = 0
  admin_username      = "oracle"
  ssh_public_key      = var.ssh_public_key
  oracle_linux_image = {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = var.oracle_linux_sku
    version   = "latest"
  }
  tags = local.common_tags
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

# 1. Spoke VNet
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = var.spoke_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.spoke_address_space]
  tags                = var.tags
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-iaas-spoke-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# 2. Subnets
resource "azurerm_subnet" "web_subnet" {
  name                 = "snet-web-tier"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = [var.web_subnet_prefix]
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "snet-app-tier"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = [var.app_subnet_prefix]
}

resource "azurerm_subnet_route_table_association" "app_udr_assoc" {
  subnet_id      = azurerm_subnet.app_subnet.id
  route_table_id = var.hub_route_table_id
}

# 3. Internal Load Balancer for App Tier
resource "azurerm_lb" "internal_app_lb" {
  name                = "ilb-iaas-app-tier"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "InternalAppFrontEnd"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "app_backend_pool" {
  loadbalancer_id = azurerm_lb.internal_app_lb.id
  name            = "bep-iaas-app-vmss"
}

# 4. Multi-AZ Linux Virtual Machine Scale Set (VMSS)
resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                = "vmss-iaas-app-prod"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_D4s_v5"
  instances           = 3
  admin_username      = "azureadmin"
  admin_password      = var.admin_password
  disable_password_authentication = false
  zones               = ["1", "2", "3"]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-vmss-app"
    primary = true

    ip_configuration {
      name                                   = "ipconfig-app"
      primary                                = true
      subnet_id                              = azurerm_subnet.app_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app_backend_pool.id]
    }
  }

  tags = var.tags
}

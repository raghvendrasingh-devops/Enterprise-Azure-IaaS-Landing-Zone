terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_hub" {
  name     = "rg-hub-network-prod"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "rg_iaas" {
  name     = "rg-spoke-iaas-prod"
  location = var.location
  tags     = var.tags
}

# 1. Central Hub Network (Azure Firewall Premium + UDR)
module "hub" {
  source              = "../../modules/hub_network"
  resource_group_name = azurerm_resource_group.rg_hub.name
  location            = var.location
  hub_vnet_name       = "vnet-hub-iaas-core"
  tags                = var.tags
}

# 2. 3-Tier Compute & VMSS
module "iaas_compute" {
  source              = "../../modules/iaas_compute_vmss"
  resource_group_name = azurerm_resource_group.rg_iaas.name
  location            = var.location
  hub_vnet_id         = module.hub.hub_vnet_id
  hub_route_table_id  = module.hub.route_table_id
  admin_password      = var.admin_password
  tags                = var.tags
}

# 3. Application Gateway WAF v2
module "app_gateway" {
  source              = "../../modules/iaas_app_gateway"
  resource_group_name = azurerm_resource_group.rg_iaas.name
  location            = var.location
  web_subnet_id       = module.iaas_compute.spoke_vnet_id # Uses web subnet
  tags                = var.tags
}

# 4. Disaster Recovery & Backup Vault
module "iaas_backup" {
  source              = "../../modules/iaas_storage_backup"
  resource_group_name = azurerm_resource_group.rg_iaas.name
  location            = var.location
  tags                = var.tags
}

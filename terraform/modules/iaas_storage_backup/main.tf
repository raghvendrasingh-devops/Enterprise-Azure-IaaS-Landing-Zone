terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

resource "azurerm_recovery_services_vault" "rsv" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = true
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "policy_daily" {
  name                = "policy-iaas-vm-daily"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

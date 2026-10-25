terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

# 1. Public IP for Application Gateway
resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw-waf-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

# 2. WAF Policy with OWASP 3.2 & Bot Protection
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "wafp-iaas-enterprise-prod"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "0.1"
    }
  }

  custom_rules {
    name      = "BlockDisallowedCountries"
    priority  = 10
    rule_type = "MatchRule"
    action    = "Block"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }
      operator           = "GeoMatch"
      negation_condition = true
      match_values       = ["IN", "US", "GB", "DE", "SG"] # Allowed regions only
    }
  }

  tags = var.tags
}

# 3. Application Gateway WAF v2
resource "azurerm_application_gateway" "appgw" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = ["1", "2", "3"]

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.web_subnet_id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_port {
    name = "frontend-port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-public-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "bep-iaas-app-tier"
  }

  backend_http_settings {
    name                  = "http-settings-app"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "probe-app-health"
  }

  http_listener {
    name                           = "http-listener-80"
    frontend_ip_configuration_name = "frontend-public-ip"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-http-to-app"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-80"
    backend_address_pool_name  = "bep-iaas-app-tier"
    backend_http_settings_name = "http-settings-app"
    priority                   = 100
  }

  probe {
    name                = "probe-app-health"
    protocol            = "Http"
    path                = "/health"
    host                = "127.0.0.1"
    interval            = 15
    timeout             = 10
    unhealthy_threshold = 3
  }

  tags = var.tags
}

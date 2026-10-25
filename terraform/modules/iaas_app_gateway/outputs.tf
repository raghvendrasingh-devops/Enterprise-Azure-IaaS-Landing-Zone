output "app_gateway_id" { value = azurerm_application_gateway.appgw.id }
output "public_ip_address" { value = azurerm_public_ip.appgw_pip.ip_address }
output "backend_pool_id" { value = azurerm_application_gateway.appgw.backend_address_pool[0].id }

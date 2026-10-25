output "hub_vnet_id" { value = azurerm_virtual_network.hub_vnet.id }
output "firewall_private_ip" { value = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address }
output "route_table_id" { value = azurerm_route_table.spoke_udr.id }

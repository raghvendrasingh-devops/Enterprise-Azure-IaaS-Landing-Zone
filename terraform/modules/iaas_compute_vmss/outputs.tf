output "spoke_vnet_id" { value = azurerm_virtual_network.spoke_vnet.id }
output "vmss_id" { value = azurerm_linux_virtual_machine_scale_set.app_vmss.id }
output "internal_lb_ip" { value = azurerm_lb.internal_app_lb.frontend_ip_configuration[0].private_ip_address }

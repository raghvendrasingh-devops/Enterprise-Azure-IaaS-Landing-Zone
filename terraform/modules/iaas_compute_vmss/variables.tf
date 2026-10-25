variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "spoke_vnet_name" { type = string; default = "vnet-spoke-iaas-prod" }
variable "spoke_address_space" { type = string; default = "172.16.16.0/20" }
variable "web_subnet_prefix" { type = string; default = "172.16.16.0/24" }
variable "app_subnet_prefix" { type = string; default = "172.16.17.0/24" }
variable "hub_vnet_id" { type = string }
variable "hub_route_table_id" { type = string }
variable "admin_password" { type = string; sensitive = true }
variable "tags" { type = map(string); default = {} }

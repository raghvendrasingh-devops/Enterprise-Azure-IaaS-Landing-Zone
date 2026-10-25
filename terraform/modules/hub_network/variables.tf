variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "hub_vnet_name" { type = string; default = "vnet-hub-iaas-prod" }
variable "hub_address_space" { type = string; default = "172.16.0.0/20" }
variable "firewall_subnet_prefix" { type = string; default = "172.16.0.0/26" }
variable "gateway_subnet_prefix" { type = string; default = "172.16.0.64/27" }
variable "bastion_subnet_prefix" { type = string; default = "172.16.0.128/26" }
variable "tags" { type = map(string); default = {} }

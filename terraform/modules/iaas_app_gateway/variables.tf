variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "web_subnet_id" { type = string }
variable "app_gateway_name" { type = string; default = "agw-iaas-waf-prod" }
variable "tags" { type = map(string); default = {} }

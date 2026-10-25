variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vault_name" { type = string; default = "rsv-iaas-backup-prod" }
variable "tags" { type = map(string); default = {} }

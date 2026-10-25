variable "location" { type = string; default = "eastus2" }
variable "admin_password" { type = string; sensitive = true; default = "P@ssw0rdEnterprise2026!Secure" }
variable "tags" {
  type = map(string)
  default = {
    Environment = "Production"
    Owner       = "Raghvendra-Singh"
    Tier        = "Enterprise-IaaS"
    ManagedBy   = "Terraform"
  }
}

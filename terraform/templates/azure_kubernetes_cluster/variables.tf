variable "scope" {
    type = string
    description = "Identifier added as a suffix to resource names."
}

variable "location" {
    type = string
    description = "Region for resources to created in."
    default = "eastus"
}

variable "tags" {
    type = map(string)
    description = "Tags to include for any resources supporting them."
    default = {}
}

variable "firewall_sku_name" {
    type = string
    description = "Sku name to create the firewall with."
    default = "AZFW_VNet"
}

variable "firewall_sku_tier" {
    type = string
    description = "Sku tier to create the firewall with."
    default = "Standard"
}

# don't have access to AzureAD, so falling back on per user provisioning
variable "full_admin_users" {
    type = list(string)
    description = "Email addresses of users to provision full admin access"
    default = []
}
variable "scope" {
    type = string
    description = "Identifier added as a suffix to resource names."
}

variable "location" {
    type = string
    description = "Region for resources to be created in."
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

variable "address_space" {
    type = list(string)
    description = "Address space to be allocated for the virtual network"
    default = ["10.0.0.0/16"]
}
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

variable "vnet_address_space" {
    type = list(string)
    description = "Address space to dedicate for the virtual network."
    default = ["10.1.0.0/16"]
}
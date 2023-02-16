variable "scope" {
    type = string
    description = "Identifier added as a suffix to resource names."
}

variable "resource_group_name" {
    type = string
    description = "Resource group to place virtual network within."
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
    default = ["10.1.0.0/16"]
}

variable "virtual_network_hub_name" {
    type = string
    description = "Network hub name to be peered with."
}

variable "virtual_network_hub_resource_group_name" {
    type = string
    description = "Resource group of network hub to peer with."
}

variable "virtual_network_hub_id" {
    type = string
    description = "Id of network hub to peer with."
}

variable "log_analytics_workspace_id" {
    type = string
    description = "Id of log analytics workspace to send logs to."
    default = null
}
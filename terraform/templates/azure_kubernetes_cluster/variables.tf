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

variable "address_space" {
    type = list(string)
    description = "Address space to be allocated for the virtual network"
    default = ["10.1.0.0/16"]
}

variable "app_gateway_address_space" {
    type = list(string)
    description = "Address space to be allocated for the virtual network"
    default = ["10.1.2.0/24"]
}

variable "acr_address_space" {
    type = list(string)
    description = "Address space to be allocated for the virtual network"
    default = ["10.1.3.0/24"]
}

variable "aks_address_space" {
    type = list(string)
    description = "Address space to be allocated for the virtual network"
    default = ["10.1.16.0/20"]
}

variable "virtual_network_hub_name" {
    type = string
    description = "Network hub name to be peered with."
}

variable "virtual_network_hub_resource_group_name" {
    type = string
    description = "Resource group of network hub to peer with."
    default = null
}

variable "virtual_network_hub_id" {
    type = string
    description = "Id of network hub to peer with."
    default = null
}

variable "container_registry_private_dns_zone_id" {
    type = string
    description = "Id of private dns zone for azure container registry"
    default = null
}
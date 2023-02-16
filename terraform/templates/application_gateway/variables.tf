variable "resource_group_name" {
    type = string
    description = "Resource group to house application gateway within."
}

variable "location" {
    type = string
    description = "Region application gateway should be deployed in."
}

variable "subnet_id" {
    type = string
    description = "Resource id for the subnet application gateway should use."
}

variable "virtual_network_name" {
    type = string
    description = "Name of the virtual network the application gateway is using."
}

variable "scope" {
    type = string
    description = "Identifier added as a suffix to resource names."
}

variable "log_analytics_workspace_id" {
    type = string
    description = "Id of log analytics workspace to send logs to."
    default = null
}
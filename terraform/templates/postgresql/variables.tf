variable "resource_group_name" {
    type = string
    description = "Name of the resource group to create postgres within."
}

variable "sku_name" {
    type = string
    description = "Sku for the postgres server."
    default = "B_Gen5_1"
}

variable "server_version" {
    type = string
    description = "Version for the postgres server."
    default = 11
}

variable "tags" {
    type = map(string)
    description = "Tags to apply to resources created."
    default = {}
}

variable  "scope" {
    type = string
    description = "Identifier added as a suffix to resource names."
}

variable "aad_server_administrator" {
    type = string
    description = "Email address of user to set as AzureAD PostgreSQL administrator"
}
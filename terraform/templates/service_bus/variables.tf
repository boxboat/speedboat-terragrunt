variable "resource_group_name" {
    type = string
    description = "Name of the resource group to create postgres within."
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

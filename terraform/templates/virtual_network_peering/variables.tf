variable "hub_peering_pairs" {
    type = list(
        object({
            source_vnet_name = string,
            source_vnet_resource_group_name = string,
            destination_vnet_name = string,
            destination_vnet_resource_group_name = string
        })
    )
    description = "A collection of virtual hub pairings to peer."
    default = []
}

variable "tags" {
    type = map(string)
    description = "Tags to place on resources created with terraform."
    default = {}
}
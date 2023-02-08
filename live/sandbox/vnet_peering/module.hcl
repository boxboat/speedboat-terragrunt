locals {
    tags = {
        Owner = "Will Schultz"
    }
    hub_peering_pairs = [
        {
            source_vnet_name = "vnet-eastus-eastus2-cluster"
            source_vnet_resource_group_name = "rg-aks-eastus2-cluster"
            destination_vnet_name = "vnet-eastus-eastus-cluster"
            destination_vnet_resource_group_name = "rg-aks-eastus-cluster"
        },
        {
            source_vnet_name = "vnet-centralus-service-mesh"
            source_vnet_resource_group_name = "rg-aks-service-mesh"
            destination_vnet_name = "vnet-eastus-eastus-cluster"
            destination_vnet_resource_group_name = "rg-aks-eastus-cluster"
        }
    ]
}
locals {
    tags = {
        Owner = "Will Schultz"
    }
    scope = "backstage-aks"
    address_space = ["10.0.0.0/16"]
    bastion_host_address_space = ["10.0.2.0/26"]
}
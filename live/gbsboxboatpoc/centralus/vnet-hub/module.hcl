locals {
    tags = {
        Owner = "Will Schultz"
        Environment = "Development"
    }
    scope = "backstage-aks"
    address_space = ["10.0.0.0/16"]
}
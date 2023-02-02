locals {
    tags = {
        Owner = "Will Schultz"
    }
    scope = "eastus2-cluster"
    full_admin_users = [
        "will.schultz_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
        "andrew.murphy_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
    ]
    address_space = ["10.73.0.0/16"]
    app_gateway_address_space = ["10.73.1.0/24"]
    aks_address_space = ["10.73.16.0/20"]
}
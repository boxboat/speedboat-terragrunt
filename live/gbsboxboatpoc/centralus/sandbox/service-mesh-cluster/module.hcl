locals {
    tags = {
        Owner = "Will Schultz"
    }
    scope = "service-mesh"
    full_admin_users = [
        "will.schultz_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
        "andrew.murphy_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
    ]
    address_space = ["10.33.0.0/16"]
    app_gateway_address_space = ["10.33.2.0/24"]
    aks_address_space = ["10.33.16.0/20"]
}
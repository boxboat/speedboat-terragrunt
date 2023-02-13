locals {
    tags = {
        Owner = "Will Schultz"
    }
    scope = "microservices-host"
    full_admin_users = [
        "will.schultz_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
        "andrew.murphy_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
        "thao.luu_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
        "Brian.Workman_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
    ]
    address_space = ["10.2.0.0/16"]
    app_gateway_address_space = ["10.2.2.0/24"]
    aks_address_space = ["10.2.16.0/20"]
    acr_address_space = ["10.2.3.0/24"]
}
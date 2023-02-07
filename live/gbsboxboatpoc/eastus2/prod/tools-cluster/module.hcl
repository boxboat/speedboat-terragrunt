locals {
    tags = {
        Owner = "Will Schultz"
        Environment = "Development"
    }
    scope = "tools-cluster"
    full_admin_users = [
        "will.schultz_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
        "andrew.murphy_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
        "thao.luu_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
        "Brian.Workman_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
    ]
    address_space = ["10.1.0.0/16"]
    app_gateway_address_space = ["10.1.2.0/24"]
    aks_address_space = ["10.1.16.0/20"]
}
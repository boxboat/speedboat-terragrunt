locals {
  tags = {
    Owner = "Will Schultz"
  }
  scope = "a-super-cool-terragrunt-cluster"
  full_admin_users = [
    "will.schultz_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
    "andrew.murphy_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
    "Brian.Workman_ibm.com#EXT#@GBSBOXBOATPOC.onmicrosoft.com",
  ]
  // container_registry_id = "/subscriptions/cb87be4f-1fc8-4539-bf00-cfe21a36e926/resourceGroups/rg-a-super-cool-terragrunt-registry/providers/Microsoft.ContainerRegistry/registries/acrasupercoolterragruntregistry"
}
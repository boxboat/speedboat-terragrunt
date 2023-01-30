variable "azure_subscription_id" {
    type = string
    description = "Azure subscription to configure the Azure terraform providers for."
}

terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "3.41.0"
        }
        azuread = {
            source = "hashicorp/azuread"
            version = "2.33.0"
        }
        random = {
            source = "hashicorp/random"
            version = "3.4.3"
        }
    }
}

provider "azurerm" {
    subscription_id = var.azure_subscription_id
    features {}
}

provider "azuread" {}

provider "random" {}
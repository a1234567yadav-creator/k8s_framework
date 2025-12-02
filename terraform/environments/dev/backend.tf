terraform {
  backend "azurerm" {
    resource_group_name  = "1000055123-rg"
    storage_account_name = "k8splatform"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }
}
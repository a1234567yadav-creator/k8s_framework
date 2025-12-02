terraform {
  backend "azurerm" {
    # Backend configuration provided via:
    # - Locally: this file (for convenience)
    # - CI/CD: -backend-config flags (for flexibility)
    resource_group_name  = "1000055123-rg"
    storage_account_name = "k8splatform"
    container_name       = "tfstate"
    key                  = "state/dev-aks.tfstate"
  }
}

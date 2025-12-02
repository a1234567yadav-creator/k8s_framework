resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

module "azure_network" {
  source              = "../../modules/azure/network"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location           = azurerm_resource_group.aks_rg.location
}

module "aks" {
  source              = "../../modules/azure/aks"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location           = azurerm_resource_group.aks_rg.location
  vnet_name          = module.azure_network.vnet_name
  subnet_name        = module.azure_network.subnet_name
  node_count         = var.node_count
  node_size          = var.node_size
}

output "aks_cluster_name" {
  value = module.aks.aks_cluster_name
}

output "aks_resource_group" {
  value = azurerm_resource_group.aks_rg.name
}
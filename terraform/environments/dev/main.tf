module "azure_network" {
  source = "./modules/azure/network"
  vnets           = var.vnets
  location        = var.location
  resource_groups = var.resource_groups
  nsgs            = var.nsgs
  subnets         = var.subnets
  }

module "aks" {
  source = "./modules/azure/aks"
  aks_clusters = var.aks_clusters
  depends_on = [ module.azure_network ]
}

output "azure_aks_cluster_name" {
  value = module.azure_aks.cluster_name
}

output "aws_eks_cluster_name" {
  value = module.aws_eks.cluster_name
}

output "gcp_gke_cluster_name" {
  value = module.gcp_gke.cluster_name
}
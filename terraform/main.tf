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

# module "aws_vpc" {
#   source = "./modules/aws/vpc"
#   vpcs = var.vpcs
# }

# module "eks" {
#   source = "./modules/aws/eks"
#   eks_clusters = var.eks_clusters
# }

# module "gcp_network" {
#   source = "./modules/gcp/network"
#   networks    = var.networks
#   subnetworks = var.subnetworks
# }

# module "gke" {
#   source = "./modules/gcp/gke"
#   gke_clusters = var.gke_clusters
# }
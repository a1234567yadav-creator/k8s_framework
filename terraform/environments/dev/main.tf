provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

module "azure_network" {
  source = "../../modules/azure/network"
}

module "azure_aks" {
  source              = "../../modules/azure/aks"
  resource_group_name = module.azure_network.resource_group_name
  location           = module.azure_network.location
  cluster_name       = var.azure_cluster_name
  node_count         = var.azure_node_count
  node_size          = var.azure_node_size
}

module "aws_vpc" {
  source = "../../modules/aws/vpc"
}

module "aws_eks" {
  source              = "../../modules/aws/eks"
  cluster_name       = var.aws_cluster_name
  vpc_id             = module.aws_vpc.vpc_id
  node_group_size    = var.aws_node_group_size
  node_group_instance_type = var.aws_node_group_instance_type
}

module "gcp_network" {
  source = "../../modules/gcp/network"
}

module "gcp_gke" {
  source              = "../../modules/gcp/gke"
  cluster_name       = var.gcp_cluster_name
  location           = var.gcp_location
  node_count         = var.gcp_node_count
  node_size          = var.gcp_node_size
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
variable "aks_cluster_name" {
  description = "The name of the Azure Kubernetes Service (AKS) cluster."
  type        = string
}

variable "aks_node_count" {
  description = "The number of nodes in the AKS cluster."
  type        = number
  default     = 3
}

variable "aks_node_size" {
  description = "The size of the nodes in the AKS cluster."
  type        = string
  default     = "Standard_DS2_v2"
}

variable "eks_cluster_name" {
  description = "The name of the Amazon EKS cluster."
  type        = string
}

variable "eks_node_count" {
  description = "The number of nodes in the EKS cluster."
  type        = number
  default     = 3
}

variable "eks_node_size" {
  description = "The size of the nodes in the EKS cluster."
  type        = string
  default     = "t3.medium"
}

variable "gke_cluster_name" {
  description = "The name of the Google GKE cluster."
  type        = string
}

variable "gke_node_count" {
  description = "The number of nodes in the GKE cluster."
  type        = number
  default     = 3
}

variable "gke_node_size" {
  description = "The size of the nodes in the GKE cluster."
  type        = string
  default     = "e2-medium"
}

variable "region" {
  description = "The cloud provider region."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "vnet_cidr" {
  description = "The CIDR block for the VNet."
  type        = string
}
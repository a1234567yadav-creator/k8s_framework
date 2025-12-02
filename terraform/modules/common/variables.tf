variable "region" {
  description = "The cloud provider region to deploy resources."
  type        = string
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
}

variable "node_size" {
  description = "The size of the nodes in the Kubernetes cluster."
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the Kubernetes cluster."
  type        = number
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "subnet_cidrs" {
  description = "A list of CIDR blocks for the subnets."
  type        = list(string)
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "environment" {
  description = "The environment for deployment (dev, staging, prod)."
  type        = string
}
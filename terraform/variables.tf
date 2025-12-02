variable "aks_clusters" {
  description = "Map of AKS clusters and their properties"
  type = map(object({
    resource_group_name           = string
    location                     = string
    cluster_name                 = string
    dns_prefix                   = string
    agent_count                  = number
    vm_size                      = string
    vnet_name                    = string
    subnet_name                  = string
    tags                         = map(string)
    kubernetes_version           = optional(string)
    api_server_authorized_ip_ranges = optional(list(string), [])
    private_cluster_enabled       = optional(bool, false)
    node_pool_max_pods            = optional(number, 30)
    node_pool_availability_zones  = optional(list(string), [])
    network_plugin                = optional(string, "azure")
    network_policy                = optional(string)
    enable_azure_policy           = optional(bool, false)
    enable_monitoring             = optional(bool, true)
    admin_group_object_ids        = optional(list(string), [])
    disk_encryption_set_id        = optional(string)
    maintenance_window            = optional(object({
      day_of_week = string
      start_hour  = number
      duration    = number
    }))
    azure_role_assignments        = optional(list(object({
      principal_id         = string
      role_definition_name = string
    })), [])
    azure_ad_integrated          = optional(bool, true)
    local_account_disabled       = optional(bool, false)
  }))
  default = {}
}

variable "resource_groups" {
  description = "Map of resource groups and their properties."
  type = map(object({
    name     = string
    location = string
  }))
}

variable "vnets" {
  description = "Map of VNets and their properties."
  type = map(object({
    name               = string
    address_space      = list(string)
    resource_group_key = string
  }))
}

variable "subnets" {
  description = "Map of subnets and their properties."
  type = map(object({
    name           = string
    vnet_key       = string
    address_prefix = string
    nsg_key        = optional(string)
    delegations    = optional(list(object({
      name               = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })), [])
  }))
}

variable "nsgs" {
  description = "Map of NSGs and their properties."
  type = map(object({
    name                = string
    resource_group_key  = string
    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "vpcs" {
  description = "Map of VPCs and their subnet configs"
  type = map(object({
    vpc_cidr = string
    public_subnets = map(object({
      cidr_block = string
      az         = string
    }))
    private_subnets = map(object({
      cidr_block = string
      az         = string
    }))
  }))
  default = {}
}

variable "eks_clusters" {
  description = "Map of EKS clusters and their properties."
  type = map(object({
    cluster_name             = string
    desired_size             = number
    max_size                 = number
    min_size                 = number
    private_subnets          = list(string)
    eks_security_group_id    = string
    version                  = optional(string)
    endpoint_private_access  = optional(bool, false)
    endpoint_public_access   = optional(bool, true)
    tags                     = optional(map(string), {})
    node_instance_type       = optional(string)
    node_labels              = optional(map(string), {})
    node_disk_size           = optional(number, 20)
    node_ami_type            = optional(string)
    node_capacity_type       = optional(string)
    node_group_tags          = optional(map(string), {})
  }))
  default = {}
}

variable "networks" {
  description = "Map of GCP VPC networks."
  type = map(object({
    network_name = string
  }))
  default = {}
}

variable "subnetworks" {
  description = "Map of GCP subnetworks."
  type = map(object({
    subnetwork_name = string
    subnetwork_cidr = string
    region          = string
    network_key     = string
  }))
  default = {}
}

variable "gke_clusters" {
  description = "Map of GKE clusters and their configuration."
  type = map(object({
    cluster_name                  = string
    region                        = string
    node_count                    = number
    node_machine_type             = string
    network_name                  = string
    subnetwork_name               = string
    node_labels                   = optional(map(string), {})
    node_tags                     = optional(list(string), [])
    preemptible                   = optional(bool, false)
    disk_size_gb                  = optional(number, 100)
    release_channel               = optional(string, "REGULAR")
    enable_private_nodes          = optional(bool, false)
    master_authorized_networks    = optional(list(object({
      cidr_block   = string
      display_name = string
    })), [])
    logging_service               = optional(string, "logging.googleapis.com/kubernetes")
    monitoring_service            = optional(string, "monitoring.googleapis.com/kubernetes")
  }))
  default = {}
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "gcp_project" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}
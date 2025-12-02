variable "eks_clusters" {
  description = "Map of EKS clusters and their properties"
  type = map(object({
    cluster_name          = string
    desired_size          = number
    max_size              = number
    min_size              = number
    private_subnets       = list(string)
    eks_security_group_id = string
    version               = optional(string)
    endpoint_private_access = optional(bool, false)
    endpoint_public_access  = optional(bool, true)
    tags                  = optional(map(string), {})
    node_instance_type    = optional(string)
    node_labels           = optional(map(string), {})
    node_disk_size        = optional(number, 20)
    node_ami_type         = optional(string)
    node_capacity_type    = optional(string)
    node_group_tags       = optional(map(string), {})
  }))
}
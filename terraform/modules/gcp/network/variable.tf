variable "networks" {
  description = "Map of VPC networks."
  type = map(object({
    network_name = string
  }))
}

variable "subnetworks" {
  description = "Map of subnetworks. "
  type = map(object({
    subnetwork_name = string
    subnetwork_cidr = string
    region          = string
    network_key     = string  
    }))
}
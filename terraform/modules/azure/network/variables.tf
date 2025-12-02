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
    name          = string
    vnet_key      = string
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
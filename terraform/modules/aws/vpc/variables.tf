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
}
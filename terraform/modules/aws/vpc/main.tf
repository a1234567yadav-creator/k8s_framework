resource "aws_vpc" "main" {
  for_each             = var.vpcs
  cidr_block           = each.value.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${each.key}-vpc"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    for subnet in flatten([
      for vpc_key, vpc in var.vpcs : [
        for subnet_key, subnet in vpc.public_subnets : {
          key        = "${vpc_key}.public.${subnet_key}"
          vpc_key    = vpc_key
          subnet_key = subnet_key
          cidr_block = subnet.cidr_block
          az         = subnet.az
        }
      ]
    ]) : subnet.key => subnet
  }
  vpc_id                  = aws_vpc.main[each.value.vpc_key].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "${each.value.vpc_key}-public-subnet-${each.value.subnet_key}"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    for subnet in flatten([
      for vpc_key, vpc in var.vpcs : [
        for subnet_key, subnet in vpc.private_subnets : {
          key        = "${vpc_key}.private.${subnet_key}"
          vpc_key    = vpc_key
          subnet_key = subnet_key
          cidr_block = subnet.cidr_block
          az         = subnet.az
        }
      ]
    ]) : subnet.key => subnet
  }
  vpc_id            = aws_vpc.main[each.value.vpc_key].id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = "${each.value.vpc_key}-private-subnet-${each.value.subnet_key}"
  }
}

resource "aws_internet_gateway" "main" {
  for_each = var.vpcs
  vpc_id   = aws_vpc.main[each.key].id
  tags = {
    Name = "${each.key}-igw"
  }
}

resource "aws_route_table" "public" {
  for_each = var.vpcs
  vpc_id   = aws_vpc.main[each.key].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[each.key].id
  }
  tags = {
    Name = "${each.key}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for k, subnet in aws_subnet.public : k => {
      id      = subnet.id
      vpc_key = subnet.tags["Name"] != null ? split("-public-subnet-", subnet.tags["Name"])[0] : ""
    }
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.value.vpc_key].id
}

resource "aws_security_group" "eks" {
  for_each = var.vpcs
  vpc_id   = aws_vpc.main[each.key].id
  name     = "${each.key}-eks-sg"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${each.key}-eks-sg"
  }
}
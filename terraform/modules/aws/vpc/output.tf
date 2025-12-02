output "vpc_ids" {
  description = "Map of VPC IDs by key"
  value       = { for k, v in aws_vpc.main : k => v.id }
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs by key"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs by key"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "eks_security_group_ids" {
  description = "Map of EKS security group IDs by VPC key"
  value       = { for k, v in aws_security_group.eks : k => v.id }
}
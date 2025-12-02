output "eks_cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.my_cluster.endpoint
}

output "eks_cluster_security_group_id" {
  value = aws_eks_cluster.my_cluster.vpc_config[0].cluster_security_group_id
}

output "eks_cluster_role_arn" {
  value = aws_eks_cluster.my_cluster.role_arn
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.my_subnet[*].id
}
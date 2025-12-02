resource "aws_iam_role" "eks_cluster_role" {
  for_each = var.eks_clusters
  name     = "${each.key}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  for_each   = var.eks_clusters
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role[each.key].name
}

resource "aws_eks_cluster" "this" {
  for_each = var.eks_clusters
  name     = each.value.cluster_name
  role_arn = aws_iam_role.eks_cluster_role[each.key].arn
  version  = lookup(each.value, "version", null)

  vpc_config {
    subnet_ids              = each.value.private_subnets
    security_group_ids      = [each.value.eks_security_group_id]
    endpoint_private_access = lookup(each.value, "endpoint_private_access", false)
    endpoint_public_access  = lookup(each.value, "endpoint_public_access", true)
  }
  tags = lookup(each.value, "tags", {})
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_iam_role" "eks_node_role" {
  for_each = var.eks_clusters
  name     = "${each.key}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  for_each   = var.eks_clusters
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  for_each   = var.eks_clusters
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  for_each   = var.eks_clusters
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role[each.key].name
}

resource "aws_eks_node_group" "this" {
  for_each        = var.eks_clusters
  cluster_name    = aws_eks_cluster.this[each.key].name
  node_group_name = "${each.value.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role[each.key].arn
  subnet_ids      = each.value.private_subnets

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  instance_types = [lookup(each.value, "node_instance_type", "t3.medium")]
  labels         = lookup(each.value, "node_labels", {})
  disk_size      = lookup(each.value, "node_disk_size", 20)
  ami_type       = lookup(each.value, "node_ami_type", null)
  capacity_type  = lookup(each.value, "node_capacity_type", null)
  tags           = lookup(each.value, "node_group_tags", {})

  depends_on = [aws_eks_cluster.this]
}
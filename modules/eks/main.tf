resource "aws_eks_cluster" "main" {
  name = var.env
  role_arn = aws_iam_role.cluster.arn
  version  = var.eks_version
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_node_group" "main" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
# to demonstrate schedular we need multiple nodes. default: 1, 2, 1
  scaling_config {
    desired_size = each.value["min_nodes"]
    min_size     = each.value["min_nodes"]
    max_size     = each.value["max_nodes"]
  }

  update_config {
    max_unavailable = 1
  }
}

#  Add Addon for network policy
resource "aws_eks_addon" "main" {
  for_each = var.addons
  cluster_name = aws_eks_cluster.main.name
  addon_name   = each.key
  configuration_values = jsondecode(each.value["config"])
}

# cluster access entry for workstation
resource "aws_eks_access_entry" "access" {
  for_each          = var.access
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value["principal_arn"]
  kubernetes_groups = try(each.value["kubernetes_groups"], [])
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "main" {
  for_each          = var.access
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = each.value["policy_arn"]
  principal_arn = each.value["principal_arn"]

  access_scope {
    type       = each.value["access_scope"]
    namespaces = each.value["access_scope"] == "cluster" ? [] : try(each.value["namespaces"], [])
  }
}
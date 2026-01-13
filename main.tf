module "vpc" {
  source = "./modules/vpc"

  for_each       = var.vpc
  env            = var.env
  subnets        = each.value["subnets"]
  vpc_cidr_block = each.value["vpc_cidr_block"]
  vpc_peers      = each.value["vpc_peers"]
}


module "ec2" {
  for_each      = var.databases
  source        = "./modules/ec2"
  ami           = var.ami
  env           = var.env
  instance_type = each.value["instance_type"]
  disk_size     = each.value["disk_size"]
  name          = each.key
  zone_id       = var.zone_id
  token         = var.token
  subnet        = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_ref"], null), "id", null)
  vpc_id        = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  bastion_nodes = var.bastion_nodes
  app_cidrs     = each.value["app_cidrs"]
  app_port      = each.value["app_port"]
  kms_arn_id    = var.kms_arn_id
}

# # workstation and eks cluster's PVC should be same
# module "eks" {
#   for_each    = var.eks
#   source      = "./modules/eks"
#   env         = var.env
#   eks_version = each.value["eks_version"]
#   subnet_ids  = [lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), "app-az1", null), "id", null),lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), "app-az2", null), "id", null)]
#   node_groups = each.value["node_groups"]
#   access      = each.value["access"]
#   addons      = each.value["addons"]
#   vault_token = var.token
# }
#
# output "main" {
#   value = module.vpc
# }


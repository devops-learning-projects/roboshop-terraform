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
}

## # workstation and eks cluster's PVC should be same
module "eks" {
  for_each    = var.eks
  source      = "./modules/eks"
  env         = var.env
  eks_version = each.value["eks_version"]
  subnet_ids  = each.value["subnet_ids"]
  node_groups = each.value["node_groups"]
  access      = each.value["access"]
  addons      = each.value["addons"]
  vault_token = var.token
}
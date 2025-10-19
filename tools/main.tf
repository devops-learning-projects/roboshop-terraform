# for hashicorp vault
module "tools" {
  for_each      = var.tools
  source        = "../modules/ec2"
  ami           = var.ami
  instance_type = each.value["instance_type"]
  name          = each.key
  zone_id       = var.zone_id
  token         = var.token
  is_tool       = true
  iam_policy    = try(each.value["iam_policy"], [])
}

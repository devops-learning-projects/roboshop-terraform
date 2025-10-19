# give here least permission
locals {
  iam_policy = concat(["sts:GetCallerIdentity"], var.iam_policy)
}
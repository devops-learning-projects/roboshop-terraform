provider "aws" {}

terraform {
  backend "s3" {}
}

provider "vault" {
  address        = "http://vault-internal.maidevops.fun:8200"
  token          = var.token
}


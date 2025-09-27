provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-myshop"
    key    = "tools/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "vault" {
  address        = "http://vault-internal.maidevops.fun:8200"
  token          = var.token
}


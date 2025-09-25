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


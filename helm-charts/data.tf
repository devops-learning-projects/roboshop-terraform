data "vault_generic_secret" "ses" {
  path = "roboshop-infra/ses"
}

data "aws_subnets" "lb-az" {
  filter {
    name   = "tag:Name"
    values = ["lb-az1", "lb-az2"]
  }
}


variable "zone_id" {
  default = "Z00952302MOEZ376FKNPS"
}

variable "ami" {
  default = "ami-09c813fb71547fc4f"
}

variable "tools" {
  default = {
    # vault = {
    #   instance_type = "t3.small"
    # }
    github-runner = {
      instance_type = "t3.small"
      iam_policy    = ["*"]
      disk_size     = 50
    }
    elk = {
      instance_type  = "m8i.xlarge"
      spot           = true
      spot_max_price = 0.142001
      subnet         = "subnet-0a10be74295112b3e"
    }
  }
}

variable "token" {}

variable "ecr" {
  default = {
    frontend  = "IMMUTABLE"
    cart      = "IMMUTABLE"
    catalogue = "IMMUTABLE"
    user      = "IMMUTABLE"
    shipping  = "IMMUTABLE"
    payment   = "IMMUTABLE"
    runner    = "MUTABLE"
  }
}
provider "aws" {}

variable "ami" {
  default = "ami-09c813fb71547fc4f"
}

variable "instance_type" {
  default = "t3.small"
}

variable "instances" {
  default = ["frontend", "catalogue"]
}

resource "aws_instance" "frontend" {
  count         = length(var.instances)
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = var.instances[count.index]
  }
}



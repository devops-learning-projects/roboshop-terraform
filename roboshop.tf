provider "aws" {}

variable "ami" {
  default = ""
}

variable "instance_type" {
  default = "t3.small"
}

resource "aws_instance" "frontend" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "frontend"
  }
}

resource "aws_instance" "catalogue" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "catalogue"
  }
}

resource "aws_instance" "mongodb" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "mongodb"
  }
}

resource "aws_instance" "mysql" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "mysql"
  }
}

resource "aws_instance" "payment" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "payment"
  }
}
resource "aws_instance" "rabbitmq" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "rabbitmq"
  }
}
resource "aws_instance" "redis" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "redis"
  }
}

resource "aws_instance" "user" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "user"
  }
}

resource "aws_instance" "shipping" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "shipping"
  }
}
resource "aws_instance" "cart" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "cart"
  }
}


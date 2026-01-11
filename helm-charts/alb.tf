# create security group for public lb
resource "aws_security_group" "public_lb" {
  name        = "public_lb"
  description = "public lb security group"
  vpc_id      = data.aws_vpc.main.id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_lb"
  }
}

# Public lb
resource "aws_lb" "main" {
  name               = "public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_lb.id]
  subnets            = data.aws_subnets.public_subnets.ids

  enable_deletion_protection = false

  tags = {
    Environment = "public"
  }
}


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

# Target group for public lb
resource "aws_lb_target_group" "tg" {
  name        = "public-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"
  health_check {
    matcher = "404"
  }
}

resource "aws_lb_target_group_attachment" "tg-attach"{
  depends_on       = [helm_release.nginx_ingress]
  count            = length(data.aws_network_interface.nlb_ips[*].private_ip)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = data.aws_network_interface.nlb_ips[count.index].private_ip
  port             = 80
}

# listener for public lb
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:804756348441:certificate/3ed301ab-eb02-4306-b300-0b19c78def23"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# redirect to https
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# create records for public lb
resource "aws_route53_record" "records" {
  count   = length(var.alb_dns_records)
  zone_id = var.zone_id
  name    = "${var.alb_dns_records[count.index]}-${var.env}"
  type    = "CNAME"
  ttl     = 30
  records = [aws_lb.main.dns_name]
}
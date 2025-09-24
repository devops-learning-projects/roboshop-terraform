resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "${var.name}-${var.env}"
  }
}

resource "aws_route53_record" "records" {
  zone_id = var.zone_id
  name    = "${var.name}-${var.env}"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}

resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.allow-all.id]

  tags = {
    Name = local.tagName
  }
}

resource "aws_route53_record" "records" {
  zone_id = var.zone_id
  name    = local.dnsName
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}

resource "aws_route53_record" "public" {
  count   = var.env == null ? 1 : 0
  zone_id = var.zone_id
  name    = local.dnsNamePublic
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.public_ip]
}

resource "null_resource" "ansible" {
  depends_on = [aws_route53_record.records]
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.instance.private_ip
    }

    inline = [
      "sudo pip3.11 install ansible",
      "ansible-pull -i localhost, -U https://github.com/devops-learning-projects/roboshop-ansible roboshop.yml -e role_name=${var.name}"
    ]
  }
}
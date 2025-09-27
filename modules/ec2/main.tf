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
  count   = var.env == null ? 0 : 1
  depends_on = [aws_route53_record.records]
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = data.vault_generic_secret.ssh-creds.data["username"]
      password = data.vault_generic_secret.ssh-creds.data["password"]
      host     = aws_instance.instance.private_ip
    }

    inline = [
      "ansible-pull -i localhost, -U https://github.com/devops-learning-projects/roboshop-ansible roboshop.yml -e role_name=${var.name} -e token=${var.token} -e env=${var.env} | sudo tee /opt/ansible.log"
    ]
  }
}

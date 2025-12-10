resource "aws_instance" "instance" {
  count                  = var.spot ? 0 : 1
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.allow-all.id]
  iam_instance_profile   = aws_iam_instance_profile.main.name

  root_block_device {
    volume_size = var.disk_size
  }

  tags = {
    Name = local.tagName
    monitor = var.monitor
  }
}
# keeping a instance in spot for elasticSearch(elk)
resource "aws_instance" "spot_instance" {
  count                  = var.spot ? 1 : 0
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.allow-all.id]
  iam_instance_profile   = aws_iam_instance_profile.main.name
  # subnet_id              = var.subnet

  root_block_device {
    volume_size = var.disk_size
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.spot_max_price
      instance_interruption_behavior = "stop"
      spot_instance_type = "persistent"
    }
  }

  tags = {
    Name = local.tagName
  }
}

resource "aws_route53_record" "records" {
  zone_id = var.zone_id
  name    = local.dnsName
  type    = "A"
  ttl     = 30
  records = var.spot ? [aws_instance.spot_instance[0].private_ip] : [aws_instance.instance[0].private_ip]
}

resource "aws_route53_record" "public" {
  count   = var.env == null ? 1 : 0
  zone_id = var.zone_id
  name    = local.dnsNamePublic
  type    = "A"
  ttl     = 30
  records = var.spot ? [aws_instance.spot_instance[0].public_ip] : [aws_instance.instance[0].public_ip]
}

resource "null_resource" "ansible" {
  count   = var.env == null ? 0 : 1

  triggers = {
    instance_id = var.spot ? aws_instance.spot_instance[0].id : aws_instance.instance[0].id
  }

  depends_on = [aws_route53_record.records]
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = data.vault_generic_secret.ssh-creds.data["username"]
      password = data.vault_generic_secret.ssh-creds.data["password"]
      host     = var.spot ? aws_instance.spot_instance[0].private_ip : aws_instance.instance[0].private_ip
    }

    inline = [
      "ansible-pull -i localhost, -U https://github.com/devops-learning-projects/roboshop-ansible roboshop.yml -e role_name=${var.name} -e token=${var.token} -e env=${var.env} | sudo tee /opt/ansible.log"
    ]
  }
}

instances = {
  frontend = {
    instance_type = "t3.small"
  }
  catalogue = {
    instance_type = "t3.small"
  }
  cart = {
    instance_type = "t3.small"
  }
  mongodb = {
    instance_type = "t3.small"
  }
  user = {
    instance_type = "t3.small"
  }
  mysql = {
    instance_type = "t3.small"
  }
  redis = {
    instance_type = "t3.small"
  }
  payment = {
    instance_type = "t3.small"
  }
  shipping = {
    instance_type = "t3.small"
  }
  rabbitmq = {
    instance_type = "t3.small"
  }
}

env       = "dev"
ami       = "ami-09c813fb71547fc4f"
zone_id   = "Z00952302MOEZ376FKNPS"
zone_name = "maidevops.fun"
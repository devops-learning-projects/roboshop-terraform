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

env       = "prod"
ami       = "ami-02cd238b02cf23cc1"
zone_id   = "Z00952302MOEZ376FKNPS"
zone_name = "maidevops.fun"
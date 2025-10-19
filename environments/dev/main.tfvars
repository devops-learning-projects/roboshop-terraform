# instances = {
#   frontend = {
#     instance_type = "t3.small"
#     disk_size = 30
#   }
#   catalogue = {
#     instance_type = "t3.small"
#     disk_size = 30
#   }
#   cart = {
#     instance_type = "t3.small"
#     disk_size = 30
#   }
#   mongodb = {
#     instance_type = "t3.small"
#     disk_size = 20
#   }
#   user = {
#     instance_type = "t3.small"
#     disk_size = 30
#   }
#   mysql = {
#     instance_type = "t3.small"
#     disk_size = 20
#   }
#   redis = {
#     instance_type = "t3.small"
#     disk_size = 20
#   }
#   payment = {
#     instance_type = "t3.small"
#     disk_size = 30
#   }
#   shipping = {
#     instance_type = "t3.small"
#     disk_size = 30
#   }
#   rabbitmq = {
#     instance_type = "t3.small"
#     disk_size = 20
#   }
# }

databases = {
  mysql = {
    instance_type = "t3.small"
    disk_size     = 20
  }
  # mongodb = {
  #   instance_type = "t3.small"
  #   disk_size     = 20
  # }
  # redis = {
  #   instance_type = "t3.small"
  #   disk_size     = 20
  # }
  # rabbitmq = {
  #   instance_type = "t3.small"
  #   disk_size     = 20
  # }
}

env       = "dev"
ami       = "ami-02cd238b02cf23cc1"
zone_id   = "Z00952302MOEZ376FKNPS"
zone_name = "maidevops.fun"

eks = {
  main = {
    eks_version = 1.33
    subnet_ids  = ["subnet-0a10be74295112b3e", "subnet-0ae77905116bf41c6"]
    node_groups = {
      one = {
        min_nodes = 1
        max_nodes = 10
      }
    }
  }
}
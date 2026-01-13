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
    subnet_ref    = "db-az1"
    app_port      = 3306
    app_cidrs     = ["10.10.10.0/24", "10.10.11.0/24"]
  }
  mongodb = {
    instance_type = "t3.small"
    disk_size     = 20
    subnet_ref    = "db-az1"
    app_port      = 27017
    app_cidrs     = ["10.10.10.0/24", "10.10.11.0/24"]
  }
  redis = {
    instance_type = "t3.small"
    disk_size     = 20
    subnet_ref    = "db-az2"
    app_port      = 6379
    app_cidrs     = ["10.10.10.0/24", "10.10.11.0/24"]
  }
  rabbitmq = {
    instance_type = "t3.small"
    disk_size     = 20
    subnet_ref    = "db-az2"
    app_port      = 5672
    app_cidrs     = ["10.10.10.0/24", "10.10.11.0/24"]
  }
}

env        = "dev"
ami        = "ami-02cd238b02cf23cc1"
zone_id    = "Z00952302MOEZ376FKNPS"
zone_name  = "maidevops.fun"
kms_arn_id = "arn:aws:kms:us-east-1:804756348441:key/a1229335-502b-4684-a07a-27a0426a28ad"

eks = {
  main = {
    eks_version = 1.33
    # subnet_ids  = ["subnet-0a10be74295112b3e", "subnet-0ae77905116bf41c6"]
    node_groups = {
      spot1 = {
        min_nodes     = 1
        max_nodes     = 10
        instance_types = ["t3.xlarge"]
        capacity_type = "SPOT"
      }
      # one = {
      #   min_nodes     = 2
      #   max_nodes     = 10
      #   instance_types = ["t3.medium"]
      #   capacity_type = "ON_DEMAND"
      # }
    }
    # cluster access entry for workstation
    access = {
      workstation = {
        principal_arn = "arn:aws:iam::804756348441:role/workstation-role"
        access_scope  = "cluster"
        policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      }
      github-runner = {
        principal_arn = "arn:aws:iam::804756348441:role/github-runner-ec2-role"
        access_scope  = "cluster"
        policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      }
    }
    addons = {
      vpc-cni = {
        config = {
          "enableNetworkPolicy": "true",
          "nodeAgent": {
            "enablePolicyEventLogs": "true"
          }
        }
      }
      eks-pod-identity-agent = {
        config = {}
      }
    }
  }
}

# Create desire vpc and subnets
vpc = {
  main = {
    vpc_cidr_block = "10.10.0.0/16"
    subnets = {
      app-az1 = {
        cidr_block        = "10.10.10.0/24"
        availability_zone = "us-east-1a"
        ngw               = true
      }
      app-az2 = {
        cidr_block        = "10.10.11.0/24"
        availability_zone = "us-east-1b"
        ngw               = true
      }
      db-az1 = {
        cidr_block        = "10.10.12.0/24"
        availability_zone = "us-east-1a"
        ngw               = true
      }
      db-az2 = {
        cidr_block        = "10.10.13.0/24"
        availability_zone = "us-east-1b"
        ngw               = true
      }
      gateway = {
        cidr_block        = "10.10.0.0/24"
        availability_zone = "us-east-1a"
        igw               = true
      }
      lb-az1 = {
        cidr_block        = "10.10.14.0/24"
        availability_zone = "us-east-1a"
        igw               = true
      }
      lb-az2 = {
        cidr_block        = "10.10.15.0/24"
        availability_zone = "us-east-1b"
        igw               = true
      }
      public-az1 = {
        cidr_block        = "10.10.16.0/24"
        availability_zone = "us-east-1a"
        igw               = true
      }
      public-az2 = {
        cidr_block        = "10.10.17.0/24"
        availability_zone = "us-east-1b"
        igw               = true
      }
    }
    vpc_peers = {
      "vpc-01900a496fb13e07c" = {
        name        = "default"
        vpc_id      = "vpc-01900a496fb13e07c"
        vpc_cidr    = "172.31.0.0/16"
        route_table = "rtb-0c3c5b0965e99f16c"
      }
    }
  }
}
# workstation and github runner ip
bastion_nodes = ["172.31.32.181/32", "172.31.42.152/32"]


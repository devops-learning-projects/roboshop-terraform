variable "zone_id" {
  default = "Z00952302MOEZ376FKNPS"
}

variable "ami" {
  default = "ami-09c813fb71547fc4f"
}

variable "tools" {
  default = {
    vault = {
      instance_type = "t3.small"
    }
  }
}

variable "ami" {}
variable "instance_type" {}
variable "name" {}
variable "env" {
  default = null
}
variable "zone_id" {}
variable "token" {}
variable "disk_size" {
  default = 20
}
variable "is_tool" {
  default = false
}

variable "iam_policy" {
  default = []
}

variable "spot" {
  default = false
}

variable "monitor" {
  default = false
}

variable "spot_max_price" {
  default = 0
}

variable "subnet" {
  default = null
}
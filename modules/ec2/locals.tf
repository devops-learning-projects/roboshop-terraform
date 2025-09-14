locals {
  name = var.name == null ? var.name : "${var.name}-${var.env}"
}
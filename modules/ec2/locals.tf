locals {
  name = var.env == null ? var.name : "${var.name}-${var.env}"
}
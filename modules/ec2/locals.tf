locals {
  tagName = var.env == null ? var.name : "${var.name}-${var.env}"
  dnsName = var.env == null ? "${var.name}-internal" : "${var.name}-${var.env}"
  dnsNamePublic = var.env == null ? var.name : "${var.name}-${var.env}"
}
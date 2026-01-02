resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block

  tags = {
    Name = var.env
  }
}


resource "aws_subnet" "main" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

  tags = {
    Name = each.key
  }
}

# vpc peering connection
resource "aws_vpc_peering_connection" "main" {
  for_each      = var.vpc_peers
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = each.value["vpc_id"]
  auto_accept   = true

  tags = {
    Name = "${var.env}-to-${each.key}"
  }

}


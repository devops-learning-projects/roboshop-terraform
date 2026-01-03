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

# aws route table connection
resource "aws_route" "main-to-other" {
  for_each                  = var.vpc_peers
  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block    = each.value["vpc_cidr"]
  vpc_peering_connection_id = aws_vpc_peering_connection.main[each.key].id
}

resource "aws_route" "other-to-main" {
  for_each                  = var.vpc_peers
  route_table_id            = each.value["route_table"]
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main[each.key].id
}

# aws internet gateway to ensure internet for new instances
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.env
  }
}

# Elastic IP
resource "aws_eip" "ngw" {
  domain   = "vpc"
}

# Nat gateway to distribute the internet
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.main["gateway"].id

  tags = {
    Name = var.env
  }
}

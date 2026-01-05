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

# route table to make relation with subnet and nat gateway
resource "aws_route_table" "main" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = each.key
  }
}

# route table association
resource "aws_route_table_association" "subnet-assoc" {
  for_each       = var.subnets
  subnet_id      = lookup(lookup(aws_subnet.main, each.key, null), "id", null)
  route_table_id = lookup(lookup(aws_route_table.main, each.key, null), "id", null)
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
# this is optional to add to default route table, not needed.
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

resource "aws_route" "subnets-to-other" {
  for_each                  = local.route_peering_combination
  route_table_id            = each.value["route_table_id"]
  destination_cidr_block    = lookup(lookup(var.vpc_peers, each.value["vpc_id"], null), "vpc_cidr", null)
  vpc_peering_connection_id = each.value["peering_id"]
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

# nat gateway & route table connection
resource "aws_route" "gateway" {
  route_table_id            = lookup(lookup(aws_route_table.main, "gateway", null ), "id", null )
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}

resource "aws_route" "ngw-to-subnets" {
  for_each                  = local.ngw_subnets
  route_table_id            = lookup(lookup(aws_route_table.main, each.key, null), "id", null)
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.ngw.id
}
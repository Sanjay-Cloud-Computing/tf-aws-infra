# Create a public route table for each VPC
resource "aws_route_table" "public_rt" {
  count  = var.no_of_vpcs
  vpc_id = aws_vpc.my_vpc[count.index].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw[count.index].id # Match IGW for each VPC
  }

  tags = {
    Name = "PublicRouteTable-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[floor(count.index / length(local.selected_zones))].id
}

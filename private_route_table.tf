resource "aws_route_table" "private_rt" {
  count  = var.no_of_vpcs
  vpc_id = aws_vpc.my_vpc[count.index].id

  tags = {
    Name = "PrivateRouteTable-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[floor(count.index / length(local.selected_zones))].id
}

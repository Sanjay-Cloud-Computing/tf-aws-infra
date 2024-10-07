# Create a single shared Internet Gateway
resource "aws_internet_gateway" "my_gw" {
  count  = var.no_of_vpcs
  vpc_id = aws_vpc.my_vpc[count.index].id

  tags = {
    Name = "InternetGateway-${count.index + 1}"
  }
}






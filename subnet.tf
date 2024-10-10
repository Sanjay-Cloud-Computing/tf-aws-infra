locals {
  selected_zones = slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.max_availability_zones))

  public_subnet_cidrs = [
    for vpc_cidr in local.vpc_cidrs : [
      for j in range(length(local.selected_zones)) : cidrsubnet(vpc_cidr, 8, j)
    ]
  ]

  private_subnet_cidrs = [
    for vpc_cidr in local.vpc_cidrs : [
      for j in range(length(local.selected_zones)) : cidrsubnet(vpc_cidr, 8, length(local.selected_zones) + j)
    ]
  ]
}

resource "aws_subnet" "public_subnet" {
  count             = length(local.vpc_cidrs) * length(local.selected_zones)
  vpc_id            = aws_vpc.my_vpc[floor(count.index / length(local.selected_zones))].id
  cidr_block        = local.public_subnet_cidrs[floor(count.index / length(local.selected_zones))][count.index % length(local.selected_zones)]
  availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))

  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.no_of_vpcs * length(local.selected_zones)
  vpc_id            = aws_vpc.my_vpc[floor(count.index / length(local.selected_zones))].id
  cidr_block        = local.private_subnet_cidrs[floor(count.index / length(local.selected_zones))][count.index % length(local.selected_zones)]
  availability_zone = local.selected_zones[count.index % length(local.selected_zones)]

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

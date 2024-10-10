locals {
  vpc_cidrs = [for i in range(min(var.no_of_vpcs, 5)) : cidrsubnet(var.vpc_cidr_base, 4, i)]
}

resource "aws_vpc" "my_vpc" {
  count      = length(local.vpc_cidrs)
  cidr_block = local.vpc_cidrs[count.index]

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${count.index + 1}"
  }
}



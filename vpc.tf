# Define the local variable to calculate unique CIDR blocks for each VPC
locals {
  # Calculate unique CIDR blocks for each VPC based on the base CIDR (e.g., 10.0.0.0/16)
  # The second parameter '4' in cidrsubnet specifies the number of VPCs (2^4 = 16 subnets possible)
  vpc_cidrs = [for i in range(min(var.no_of_vpcs, 5)) : cidrsubnet(var.vpc_cidr_base, 4, i)]
}

# Create the VPC resources dynamically based on the number of VPCs required
resource "aws_vpc" "my_vpc" {
  count      = length(local.vpc_cidrs)
  cidr_block = local.vpc_cidrs[count.index]

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${count.index + 1}"
  }
}



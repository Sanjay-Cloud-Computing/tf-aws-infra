# Fetch current VPC count
data "aws_vpcs" "existing_vpcs" {}

# Fetch the current VPC limit
data "aws_servicequotas_service_quota" "vpc_limit" {
  service_code = "vpc"
  quota_code   = "L-F678F1CE"
}

# Calculate the maximum number of VPCs that can be created
locals {
  available_vpcs = data.aws_servicequotas_service_quota.vpc_limit.value - length(data.aws_vpcs.existing_vpcs.ids)
}

# Declare the data source to fetch available AWS availability zones
data "aws_availability_zones" "available" {
  state = "available" # Filter to only include currently available zones
}


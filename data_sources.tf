data "aws_vpcs" "existing_vpcs" {}
data "aws_servicequotas_service_quota" "vpc_limit" {
  service_code = "vpc"
  quota_code   = "L-F678F1CE"
}

locals {
  available_vpcs = data.aws_servicequotas_service_quota.vpc_limit.value - length(data.aws_vpcs.existing_vpcs.ids)
}

data "aws_availability_zones" "available" {
  state = "available" # Filter to only include currently available zones
}

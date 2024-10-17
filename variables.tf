variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
  # default     = "us-west-1"
}

variable "vpc_cidr_base" {
  description = "Base CIDR block to use for creating VPCs (e.g., 10.0)"
  type        = string
  # default     = "10.0.0.0/16"
}

variable "no_of_vpcs" {
  description = "Number of VPCs to create"
  type        = number
  # default     = 3
}

variable "max_availability_zones" {
  description = "Maximum number of availability zones to consider"
  type        = number
  # default     = 5
}

variable "public_subnet_per_vpc" {
  description = "Number of public subnets to create per VPC"
  type        = number
  # default     = 1
}

variable "private_subnet_per_vpc" {
  description = "Number of private subnets to create per VPC"
  type        = number
  # default     = 1
}

variable "application_port" {
  description = "The port on which the application runs"
  type        = number
}

variable "vpc_name" {
  description = "Base name for the VPCs to be created"
  type        = string
  # default     = "MyVPC"
}

variable "custom_ami_id" {
  description = "Amazon Machine Image (AMI) to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "The key pair name for SSH access"
  type        = string
  default     = null
}

variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-west-1"


variable "vpc_cidr_base" {
  description = "Base CIDR block to use for creating VPCs (e.g., 10.0)"
  type        = string
}

variable "no_of_vpcs" {
  description = "Number of VPCs to create"
  type        = number
}

variable "max_availability_zones" {
  description = "Maximum number of availability zones to consider"
  type        = number
  default     = 3
}

variable "public_subnet_per_vpc" {
  description = "Number of public subnets to create per VPC"
  type        = number
  default     = 1
}

variable "private_subnet_per_vpc" {
  description = "Number of private subnets to create per VPC"
  type        = number
  default     = 1
}

variable "vpc_name" {
  description = "Base name for the VPCs to be created"
  type        = string
  default     = "MyVPC"
}


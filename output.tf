# Output the IDs of all public subnets
output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnet : subnet.id]
}

# Output the IDs of all private subnets
output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
}

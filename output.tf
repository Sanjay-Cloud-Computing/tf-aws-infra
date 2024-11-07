output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "load_balancer_dns" {
  value = aws_lb.web_app_alb.dns_name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.web_app_asg.name
}

output "application_security_group_id" {
  value = aws_security_group.application_sg.id
}

# Security Group Creation
resource "aws_security_group" "application_sg" {
  vpc_id = aws_vpc.my_vpc[0].id

  name        = "application_security_group"
  description = "Allow inbound traffic for SSH, HTTP, HTTPS, and application-specific port"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Allow application traffic from load balancer"
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ApplicationSecurityGroup"
  }
}


resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "rds-parameter-group"
  family      = "mariadb10.6"
  description = "Custom parameter group for MariaDB instance"

  tags = {
    Name = "RDSParameterGroup"
  }
}

resource "aws_security_group" "db_security_group" {
  vpc_id = aws_vpc.my_vpc[0].id
  name   = "db_security_group"

  ingress {
    description     = "Allow MariaDB traffic from the application security group"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DBSecurityGroup"
  }
}

# RDS Instance for MariaDB
resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  instance_class         = "db.t3.micro"
  engine                 = "mariadb"
  engine_version         = "10.6"
  username               = "csye6225"
  password               = random_password.db_password.result
  parameter_group_name   = aws_db_parameter_group.rds_parameter_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id, ]
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_name                = "csye6225"
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_key.arn

  tags = {
    Name = "RDSInstance"
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id


  tags = {
    Name = "RDSSubnetGroup"
  }
}

# Output for RDS Endpoint and Security Group
output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "rds_security_group_id" {
  value = aws_security_group.db_security_group.id
}

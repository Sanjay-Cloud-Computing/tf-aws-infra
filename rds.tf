resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "rds-parameter-group"
  family      = "mariadb10.6" # MariaDB version
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
    from_port       = var.db_port # 3306 for MariaDB
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id] # Reference to application SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
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
  instance_class         = "db.t3.micro" # Cheapest instance class, modify as needed
  engine                 = "mariadb"     # MariaDB as the database engine
  engine_version         = "10.6"        # Specify the version of MariaDB
  username               = "csye6225"
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.rds_parameter_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id, ] # Attach DB security group
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_name                = "csye6225"

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

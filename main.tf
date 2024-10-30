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
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow application traffic"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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


resource "aws_instance" "web_app_instance" {
  ami                         = var.custom_ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_role_profile.name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 25
    delete_on_termination = true
  }

  disable_api_termination = false

  user_data = <<-EOF
              #!/bin/bash
              # Write environment variables to /etc/environment
              echo "DB_USERNAME='csye6225'" >> /etc/environment
              echo "DB_PASSWORD='${var.db_password}'" >> /etc/environment
              echo "DB_HOST='${aws_db_instance.rds_instance.address}'" >> /etc/environment
              echo "DB_PORT='3306'" >> /etc/environment
              echo "DB_NAME='test'" >> /etc/environment
              echo "S3_BUCKET_NAME='${aws_s3_bucket.file_upload_bucket.bucket}'" >> /etc/environment

              echo "SENDGRID_API_KEY='${var.email_key}'" >> /etc/environment

              # Source the environment variables
              source /etc/environment

              # Start CloudWatch Agent (assuming it is installed in the AMI or Packer configuration)
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start

              # Start your application (modify to fit your application start command)
              sudo systemctl start app.service
              EOF


  tags = {
    Name = "WebAppInstance"
  }
}

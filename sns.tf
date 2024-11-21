# SNS Topic
resource "aws_sns_topic" "user_creation_topic" {
  name = "user_creation_topic"

  tags = {
    Environment = var.route_name
    Name        = "UserCreationTopic"
  }
}

# Pass SNS Topic ARN to the application via EC2 user data
resource "aws_launch_template" "web_app_launch_template" {
  name          = "csye6225_asg"
  image_id      = var.custom_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_role_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "DB_USERNAME='csye6225'" >> /etc/environment
              echo "DB_PASSWORD='${var.db_password}'" >> /etc/environment
              echo "DB_HOST='${aws_db_instance.rds_instance.address}'" >> /etc/environment
              echo "DB_PORT='3306'" >> /etc/environment
              echo "DB_NAME='test'" >> /etc/environment
              echo "S3_BUCKET_NAME='${aws_s3_bucket.file_upload_bucket.bucket}'" >> /etc/environment
              echo "ROUTE_NAME='${var.route_name}'" >> /etc/environment
              echo "SENDGRID_API_KEY='${var.email_key}'" >> /etc/environment
              echo "SNS_TOPIC_ARN='${aws_sns_topic.user_creation_topic.arn}'" >> /etc/environment
              source /etc/environment
EOF
  )
}

# SNS Topic
resource "aws_sns_topic" "user_creation_topic" {
  name = "user_creation_topic"

  tags = {
    Environment = var.route_name
    Name        = "UserCreationTopic"
  }
}

# Access for secret
resource "aws_iam_policy" "ec2_secrets_access" {
  name        = "EC2SecretsAccessPolicy"
  description = "Allow EC2 instances to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue"
        ],
        Resource : "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:db-password-rds1"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_secrets_access_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_secrets_access.arn
}


# Pass SNS Topic ARN to the application via EC2 user data
resource "aws_launch_template" "web_app_launch_template" {
  name          = "csye6225_asg"
  image_id      = var.custom_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda" # Root volume
    ebs {
      delete_on_termination = true
      volume_size           = 8
      volume_type           = "gp2"
      encrypted             = true
      iops                  = 0
      kms_key_id            = aws_kms_key.ec2_key.arn
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_role_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e  # Exit on any error

              # Update the package index
              sudo apt update -y

              # Install AWS CLI v2
              sudo apt install -y awscli

              # Install jq for JSON parsing
              sudo apt install -y jq

              # Set AWS default region 
              # export AWS_DEFAULT_REGION=us-east-1
              export AWS_DEFAULT_REGION=${var.region}

              # Retrieve the database password from Secrets Manager
              # SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id db-password-rds-6 --query 'SecretString' --output text)
              # DB_PASSWORD=$(echo "$SECRET_VALUE" | jq -r '.password')

              SECRET_NAME="${aws_secretsmanager_secret.db_password_secret.name}"
              SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query 'SecretString' --output text)
              DB_PASSWORD=$(echo "$SECRET_VALUE" | jq -r '.password')

              sudo bash -c "echo \"DB_PASSWORD='$DB_PASSWORD'\" >> /etc/environment"

              # Write environment variables to /etc/environment
              sudo bash -c "echo \"DB_USERNAME='csye6225'\" >> /etc/environment"
              # sudo bash -c "echo \"DB_PASSWORD='$DB_PASSWORD'\" >> /etc/environment"
              sudo bash -c "echo \"DB_HOST='${aws_db_instance.rds_instance.address}'\" >> /etc/environment"
              sudo bash -c "echo \"DB_PORT='3306'\" >> /etc/environment"
              sudo bash -c "echo \"DB_NAME='test'\" >> /etc/environment"
              sudo bash -c "echo \"S3_BUCKET_NAME='${aws_s3_bucket.file_upload_bucket.bucket}'\" >> /etc/environment"
              sudo bash -c "echo \"ROUTE_NAME='${var.route_name}'\" >> /etc/environment"
              sudo bash -c "echo \"SENDGRID_API_KEY='${var.email_key}'\" >> /etc/environment"
              sudo bash -c "echo \"SNS_TOPIC_ARN='${aws_sns_topic.user_creation_topic.arn}'\" >> /etc/environment"

              # Load the environment variables
              source /etc/environment

               # Start your application (modify to fit your application start command)
              sudo systemctl start app.service

              # Configure and start CloudWatch Agent
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent-config.json -s
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
EOF
  )


}

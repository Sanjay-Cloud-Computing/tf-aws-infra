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
              # Write environment variables to /etc/environment
              echo "DB_USERNAME='csye6225'" >> /etc/environment
              echo "DB_PASSWORD='${var.db_password}'" >> /etc/environment
              echo "DB_HOST='${aws_db_instance.rds_instance.address}'" >> /etc/environment
              echo "DB_PORT='3306'" >> /etc/environment
              echo "DB_NAME='test'" >> /etc/environment
              echo "S3_BUCKET_NAME='${aws_s3_bucket.file_upload_bucket.bucket}'" >> /etc/environment
              echo "ROUTE_NAME='${var.route_name}'" >> /etc/environment
              echo "SENDGRID_API_KEY='${var.email_key}'" >> /etc/environment

              # Source the environment variables
              source /etc/environment

              # Start your application (modify to fit your application start command)
              sudo systemctl start app.service

              # Configure and start CloudWatch Agent
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent-config.json -s
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
EOF
  )

}

resource "aws_autoscaling_group" "web_app_asg" {
  desired_capacity = 3 # Start with 3 instances
  max_size         = 5 # Allow scaling up to 5 instances
  min_size         = 3 # Ensure a minimum of 3 instances
  launch_template {
    id      = aws_launch_template.web_app_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = aws_subnet.public_subnet[*].id

  tag {
    key                 = "Name"
    value               = "WebAppInstance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                    = "scale_up"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  autoscaling_group_name  = aws_autoscaling_group.web_app_asg.name
  policy_type             = "SimpleScaling"
  metric_aggregation_type = "Average"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "cpu_scale_up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  alarm_actions       = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                    = "scale_down"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  autoscaling_group_name  = aws_autoscaling_group.web_app_asg.name
  policy_type             = "SimpleScaling"
  metric_aggregation_type = "Average"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "cpu_scale_down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 8
  alarm_actions       = [aws_autoscaling_policy.scale_down_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }
}


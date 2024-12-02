resource "aws_lb" "web_app_alb" {
  name               = "web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id

  enable_deletion_protection = false

  tags = {
    Name = "WebAppALB"
  }
}

resource "aws_lb_target_group" "web_app_target_group" {
  name        = "web-app-target-group"
  port        = var.application_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc[0].id
  target_type = "instance"
  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# ---- HTTP -----
resource "aws_lb_listener" "web_app_http_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }
}

resource "aws_autoscaling_attachment" "asg_alb_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
  lb_target_group_arn    = aws_lb_target_group.web_app_target_group.arn
}

# LB Security Group

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.my_vpc[0].id

  name        = "load_balancer_security_group"
  description = "Allow HTTP and HTTPS traffic to Load Balancer"

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTP (IPv6)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow HTTPS (IPv6)"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LoadBalancerSecurityGroup"
  }
}

data "aws_acm_certificate" "web_app_cert" {
  domain   = "demo.cloudsan.me"
  statuses = ["ISSUED"]
}
resource "aws_lb_listener" "web_app_https_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"
  # certificate_arn = "arn:aws:acm:${var.region}:${data.aws_caller_identity.current.account_id}:certificate/7d0b38a6-a56e-441b-a5ab-00065d0d2ba1"
  certificate_arn = data.aws_acm_certificate.web_app_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }
}

# resource "aws_lb_listener" "web_app_http_redirect_listener" {
#   load_balancer_arn = aws_lb.web_app_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       protocol    = "HTTPS"
#       port        = "443"
#       status_code = "HTTP_301"
#     }
#   }
# }



data "aws_route53_zone" "root_zone" {
  name         = "${var.route_name}.cloudsan.me"
  private_zone = false
}

resource "aws_route53_record" "web_app_a_record" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = ""
  type    = "A"
  alias {
    name                   = aws_lb.web_app_alb.dns_name
    zone_id                = aws_lb.web_app_alb.zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "root_zone" {
  name         = "${var.route_name}.cloudsan.me"
  private_zone = false
}

resource "aws_route53_record" "web_app_a_record" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = ""
  type    = "A"
  ttl     = 60
  records = [aws_instance.web_app_instance.public_ip]
}

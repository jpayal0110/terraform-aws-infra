# Use the defined Hosted Zone
data "aws_route53_zone" "webapp_zone" {
  name         = "${var.aws_profile}.${var.domain_name}" # Subdomain (e.g., app.yourdomain.com)
  private_zone = false
}

# Create an A record pointing to the Load Balancer
resource "aws_route53_record" "webapp_record" {
  zone_id = data.aws_route53_zone.webapp_zone.zone_id
  name    = "${var.aws_profile}.${var.domain_name}" # Subdomain (e.g., app.yourdomain.com)
  type    = "A"

  alias {
    name                   = aws_lb.web_app_alb.dns_name
    zone_id                = aws_lb.web_app_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "webapp" {
  name    = var.domain
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.webapp_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.webapp_cdn.hosted_zone_id
  }
  zone_id = data.terraform_remote_state.shared.outputs.primary_zone_id
}
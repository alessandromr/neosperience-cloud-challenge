output "domain_cert_arn" {
  value = aws_acm_certificate.primary.arn
}
output "domain_useast_cert_arn" {
  value = aws_acm_certificate.primary_us_east_1.arn
}
output "primary_zone_id" {
  value = aws_route53_zone.primary.zone_id
}
output "alb_arn" {
  value = module.alb.arn
}
output "alb_sg_id" {
  value = module.alb.security_group_id
}
output "alb_dns_name" {
  value = module.alb.dns_name
}
output "alb_http_listener_arn" {
  value = module.alb.listeners["ex-http-https-redirect"].arn
}
output "alb_https_listener_arn" {
  value = module.alb.listeners["ex-https"].arn
}
output "ecs_cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
}
output "waf_acl_id" {
  value = aws_wafv2_web_acl.neosperience-cloudfront-waf.id
}
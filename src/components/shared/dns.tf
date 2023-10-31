resource "aws_route53_zone" "primary" { //we can choose to import the existing zone or just use the id where needed
  name = var.domain
}
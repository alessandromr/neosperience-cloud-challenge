resource "aws_wafv2_web_acl" "neosperience-cloudfront-waf" {
  provider = aws.us-east-1

  name  = "neosperience-test-cloudfront-waf-${var.env}"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "ratelimit-hard"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.hard_cloudfront_waf_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ratelimit-hard-${var.env}"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "neosperience-test-cloudfront-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Env        = var.env
  }
}


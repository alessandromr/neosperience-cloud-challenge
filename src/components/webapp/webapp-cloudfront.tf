resource "random_string" "alb_token" {
  length = 32
  special = false
}

resource "aws_cloudfront_distribution" "webapp_cdn" {
  enabled = true
  aliases = [var.domain]
  default_root_object = "/"

  origin  {
    domain_name              = module.webapp_s3.s3_bucket_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.webapp_cdn.id
    origin_id                = "webappBucket"
  }

  origin  {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    domain_name              = data.terraform_remote_state.shared.outputs.alb_dns_name
    origin_id                = "webappECS"
    custom_header {
      name  = "x-cf-token"
      value = random_string.alb_token.result
    }
  }

  default_cache_behavior  {
    target_origin_id       = "webappECS"

    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = aws_cloudfront_cache_policy.webapp_cdn_ecs.id
  }

  ordered_cache_behavior {
    path_pattern           = "/admin/*"
    target_origin_id       = "webappECS"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = aws_cloudfront_cache_policy.webapp_cdn_ecs_admin.id
  }
  ordered_cache_behavior {
    path_pattern           = "/user/*"
    target_origin_id       = "webappECS"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = aws_cloudfront_cache_policy.webapp_cdn_ecs_admin.id
  }

  ordered_cache_behavior {
    path_pattern           = "/public/uploads/*"
    target_origin_id       = "webappBucket"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = aws_cloudfront_cache_policy.webapp_cdn_general.id
  }
  ordered_cache_behavior {
    path_pattern           = "/public/static/*"
    target_origin_id       = "webappBucket"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = aws_cloudfront_cache_policy.webapp_cdn_general.id
  }

  viewer_certificate  {
    acm_certificate_arn = data.terraform_remote_state.shared.outputs.domain_useast_cert_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  custom_error_response {
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }
  custom_error_response {
    error_code = 403
    response_code = 200
    response_page_path = "/index.html"
  }

  web_acl_id = data.terraform_remote_state.shared.outputs.waf_acl_id
}

resource "aws_cloudfront_cache_policy" "webapp_cdn_general" {
  name = "transcritto-webapp-cdn-general-${var.env}"
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
  min_ttl = 3600
  default_ttl = 3600
  max_ttl = 86400
}

resource "aws_cloudfront_cache_policy" "webapp_cdn_ecs" {
  name = "transcritto-webapp-cdn-ecs-${var.env}"
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all" //forward session for the authentication
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
  min_ttl = 1
  default_ttl = 3600
  max_ttl = 3600
}

resource "aws_cloudfront_cache_policy" "webapp_cdn_ecs_admin" { //cache disabled
  name = "transcritto-webapp-cdn-ecs-admin-${var.env}"
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
  min_ttl = 0
  default_ttl = 0
  max_ttl = 0
}

resource "aws_cloudfront_origin_access_control" "webapp_cdn" {
  name                              = "transcritto-webapp-${var.env}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
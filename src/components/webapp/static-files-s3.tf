module "webapp_s3" {
  source = "registry.terraform.io/terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket                                = "neosperience-test-webapp-${var.env}"
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_policy.json

  versioning = {
    enabled = false
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::neosperience-test-webapp-${var.env}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      values   = [aws_cloudfront_distribution.webapp_cdn.arn]
      variable = "AWS:SourceArn"
    }
  }
}
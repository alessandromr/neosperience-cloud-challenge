# s3 infrastructure bucket
data "aws_iam_policy_document" "neosperience-test-infrastructure" {
  policy_id = "neosperience-test-terraform-${var.env}-policy"
  statement {
    sid = "AllowSSLRequestsOnly"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::neosperience-test-terraform-${var.env}/*",
      "arn:aws:s3:::neosperience-test-terraform-${var.env}"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket" "neosperience-test-infrastructure" {
  bucket = "neosperience-test-terraform-${var.env}"

  tags = {
    Name        = "neosperience-test infrastructure bucket"
    DailyBackup = "active"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "neosperience-test-infrastructure" {
  bucket = aws_s3_bucket.neosperience-test-infrastructure.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_policy" "neosperience-test-infrastructure" {
  bucket = aws_s3_bucket.neosperience-test-infrastructure.id
  policy = data.aws_iam_policy_document.neosperience-test-infrastructure.json
}

resource "aws_s3_bucket_versioning" "neosperience-test-infrastructure" {
  bucket = aws_s3_bucket.neosperience-test-infrastructure.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "neosperience-test-infrastructure" {
  bucket = aws_s3_bucket.neosperience-test-infrastructure.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
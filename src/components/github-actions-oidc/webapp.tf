
# Roles
resource "aws_iam_role" "github-webapp" {
  depends_on = [aws_iam_openid_connect_provider.github]

  name               = "github-neosperience-test-webapp-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.github-webapp-assume-policy.json
}

data "aws_iam_policy_document" "github-webapp-assume-policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:alessandromr/neosperience-test-webapp:*"]
    }
  }
}

resource "aws_iam_role_policy" "github-webapp" {
  name = "github-neosperience-test-webapp-${var.env}"
  role = aws_iam_role.github-webapp.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::neosperience-test-webapp-${var.env}/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": "arn:aws:s3:::neosperience-test-webapp-${var.env}"
      },
    ]
  })
}
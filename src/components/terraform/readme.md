# Assume role and create s3 bucket first
```
AWS_PROFILE="neosperience-test-ENV" aws sts assume-role --role-arn arn:aws:iam::1234567890:role/OrganizationAccountAccessRole --role-session-name "user@email.com"
AWS_PROFILE="neosperience-test-ENV" aws s3api create-bucket --bucket neosperience-test-terraform-ENV --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
make import component=terraform env=ENV resource=aws_s3_bucket.neosperience-test-infrastructure id=neosperience-test-terraform-ENV lock=false
make applyTarget component=terraform env=ENV lock=false target=aws_dynamodb_table.terraform
make apply component=terraform env=ENV
```
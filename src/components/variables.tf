variable "env" {
  default = "dev"
  type    = string
}
variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "aws_account_id" {
  description = "AWS account id"
  default     = ""
}

variable "aws_organization_id" {
  default     = ""
  description = "Organization ID"
}

variable "domain" {
  type = string
}

variable "aws_profile" {
  description = "AWS profile"
}
variable "availability_zones" {}

variable "vpc_cidr" {
  description = "VPC CIDR block"
}
variable "vpc_public_subnets" {
  description = "VPC public subnets"
  default     = []
}

variable "vpc_private_subnets" {
  description = "VPC private subnets"
  default     = []
}
variable "datadog_vpc_private_subnets" {
  default = []
}

variable "vpc_database_subnets" {
  description = "VPC database subnets"
  default     = []
}

variable "vpc_cache_subnets" {
  description = "VPC elasticache subnets"
  default     = []
}

variable "one_nat_gw_per_az" {
  description = "Create one nat gateway for each AZs"
  default     = false
}

variable "single_nat_gw" {
  description = "Create a single nat gateway for all the AZs"
  default     = true
}

variable "hard_cloudfront_waf_limit" {
  default = 4000
}
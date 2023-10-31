module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "neosperience-test-${var.env}"
  cidr = var.vpc_cidr

  azs              = var.availability_zones
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets
  database_subnets = var.vpc_database_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_dhcp_options  = true

  enable_nat_gateway     = true
  one_nat_gateway_per_az = var.one_nat_gw_per_az
  single_nat_gateway     = var.single_nat_gw

  tags = {
    Env        = var.env
    CostCenter = "Network"
  }
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = []

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    }
  }

  tags = {
    Env        = var.env
    CostCenter = "Network"
  }
}
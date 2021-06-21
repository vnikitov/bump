module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.1.0"

  #source = "./modules/terraform-aws-vpc"

  name                = "vpc-${var.env}-${var.region}"
  cidr                = var.vpc-cidr
  azs                 = var.availability_zones
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets

  private_subnet_suffix = "private"
  public_subnet_suffix  = "public"

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  enable_vpn_gateway   = true

  tags = local.common_tags
}

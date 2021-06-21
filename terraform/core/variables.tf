variable "env" {
  default = "dev"
}

variable "region" {
  default = "eu-central-1"
}

variable "project" {
  default = "Bump"
}

variable "name" {
  default = "bump"
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = var.env
    Region      = var.region
    Project     = var.project
  }
}

# You need to provice AWS region
variable "account_region" {
  default = "eu-central-1"
}

variable "vpc-cidr" {
  description = "The CIDR block for the AWS VPC"
  default = "10.55.0.0/16"
}

variable "availability_zones" {
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  default = ["10.55.1.0/24", "10.55.2.0/24", "10.55.3.0/24"]
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  default = ["10.55.10.0/24", "10.55.11.0/24", "10.55.12.0/24"]
}

variable "database_subnets" {
  description = "List of CIDR blocks for database subnets"
  default = ["10.55.21.0/24", "10.55.22.0/24", "10.55.23.0/24"]
}

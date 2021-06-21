variable "env" {
  default = "dev"
}

variable "region" {
  default = "eu-central-1"
}

variable "project" {
  default = "Bump"
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

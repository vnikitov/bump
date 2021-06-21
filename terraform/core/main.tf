terraform {
  backend "s3" {
    bucket = "bump-generic-acc"
    key    = "tfstate-core/terraform.tfstate"
    region = "eu-central-1"
  }
  required_version = "~> 1.0.0"
}

provider "aws" {
  region = "eu-central-1"
}
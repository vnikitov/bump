variable "env" {
  default = "dev"
}

variable "region" {
  description = "the AWS region in which resources are created"
  default     = "eu-central-1"
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


variable "name" {
  description = "the name of application"
  default     = "bump"
}

# Web variables
variable "web_container_port" {
  description = "Port of container"
  default     = 80
}

variable "web_container_cpu" {
  default     = 512
  description = "The number of cpu units used by the task"
}

variable "web_container_memory" {
  default     = 1024
  description = "The amount (in MiB) of memory used by the task"
}

variable "web_container_image" {
  description = "Docker image to be launched"
  default     = "247528355866.dkr.ecr.eu-central-1.amazonaws.com/bump-web"
}

variable "web_service_desired_count" {
  default     = "2"
  description = "Desired count of services running"
}

# Worker variables
variable "worker_container_port" {
  description = "Port of container"
  default     = 80
}

variable "worker_container_cpu" {
  default     = 512
  description = "The number of cpu units used by the task"
}

variable "worker_container_memory" {
  default     = 1024
  description = "The amount of memory used by the task"
}

variable "worker_container_image" {
  description = "Docker image to be launched"
  default     = "247528355866.dkr.ecr.eu-central-1.amazonaws.com/bump-worker"
}

variable "worker_service_desired_count" {
  default     = "1"
  description = "Number of services running"
}

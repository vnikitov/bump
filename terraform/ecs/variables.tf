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
variable "container_port" {
  description = "Port of container"
  default     = 80
}

variable "container_cpu" {
  default     = 512
  description = "The number of cpu units used by the task"
}

variable "container_memory" {
  default     = 1024
  description = "The amount (in MiB) of memory used by the task"
}

variable "container_image" {
  description = "Docker image to be launched"
  default     = "nginx"
}

variable "service_desired_count" {
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
  default     = "nginx"
}

variable "worker_service_desired_count" {
  default     = "2"
  description = "Number of services running in parallel"
}

variable "ecr_repository" {
  type = any
  default = {
    bump-web    = "bump-web"
    bump-worker = "bump-worker"
  }
}

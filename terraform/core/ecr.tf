resource "aws_ecr_repository" "ecr-repository" {
  for_each = var.ecr_repository
  name     = each.value
  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "aws_ecr_lifecycle_policy" "ecr-lifecycle-policy" {
  for_each   = var.ecr_repository
  repository = each.value

  policy = <<EOF
{
  "rules": [
    {
      "action": {
        "type": "expire"
      },
      "selection": {
        "countType": "imageCountMoreThan",
        "countNumber": 20,
        "tagStatus": "any"
      },
      "description": "Keep last 40 images",
      "rulePriority": 1
    }
  ]
}
EOF
}

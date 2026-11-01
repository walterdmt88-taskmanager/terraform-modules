# ECR repository names are path-style (lowercase, '/' allowed): taskmanager/user-service.
# This deviates from the {prefix}-{project}-{env}-{type}-{region}-{purpose} convention on purpose:
# the registry URL already carries account + region, and one repo serves every environment.
locals {
  name = "${var.project}/${var.purpose}"
}

resource "aws_ecr_repository" "this" {
  name                 = local.name
  image_tag_mutability = var.image_tag_mutability

  # force_delete stays false: a repository that still holds images cannot be destroyed by accident.
  force_delete = false

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  # Two-layer tag merge — common tags from the caller + per-resource tags
  tags = merge(var.tags, {
    Name            = local.name
    ApplicationRole = "Container registry ${var.purpose}"
    SensitiveData   = "false"
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the last ${var.max_image_count} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.max_image_count
      }
      action = {
        type = "expire"
      }
    }]
  })
}

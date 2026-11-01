output "repository" {
  description = "The full aws_ecr_repository object"
  value       = aws_ecr_repository.this
}

output "name" {
  description = "Repository name (e.g. taskmanager/user-service)"
  value       = aws_ecr_repository.this.name
}

output "arn" {
  description = "Repository ARN — use it to scope IAM policies"
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "Registry URL to push/pull (<account>.dkr.ecr.<region>.amazonaws.com/<name>)"
  value       = aws_ecr_repository.this.repository_url
}

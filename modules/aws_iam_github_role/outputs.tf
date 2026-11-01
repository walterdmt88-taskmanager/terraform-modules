output "arn" {
  description = "Role ARN — set as role-to-assume in aws-actions/configure-aws-credentials"
  value       = aws_iam_role.this.arn
}

output "name" {
  description = "Role name produced by the naming convention"
  value       = aws_iam_role.this.name
}

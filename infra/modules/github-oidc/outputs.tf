output "role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions — set this as a GitHub Actions variable (AWS_ROLE_ARN)"
  value       = aws_iam_role.github_actions.arn
}

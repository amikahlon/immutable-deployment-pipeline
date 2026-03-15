output "client_repository_url" {
  description = "ECR repository URL for the client image"
  value       = aws_ecr_repository.client.repository_url
}

output "server_repository_url" {
  description = "ECR repository URL for the server image"
  value       = aws_ecr_repository.server.repository_url
}

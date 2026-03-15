output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "alb_security_group_id" {
  value = module.network.alb_security_group_id
}

output "app_security_group_id" {
  value = module.network.app_security_group_id
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB — use this as the app entry point"
  value       = module.alb.alb_dns_name
}

output "client_ecr_url" {
  description = "ECR repository URL for the client image"
  value       = module.ecr.client_repository_url
}

output "server_ecr_url" {
  description = "ECR repository URL for the server image"
  value       = module.ecr.server_repository_url
}

output "github_actions_role_arn" {
  description = "Set this as a GitHub Actions variable named AWS_ROLE_ARN"
  value       = module.github_oidc.role_arn
}

output "client_asg_name" {
  description = "Name of the client Auto Scaling Group"
  value       = module.compute.client_asg_name
}

output "server_asg_name" {
  description = "Name of the server Auto Scaling Group"
  value       = module.compute.server_asg_name
}

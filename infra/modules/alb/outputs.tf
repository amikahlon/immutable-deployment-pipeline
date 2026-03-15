output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.main.arn
}

output "client_tg_arn" {
  description = "ARN of the client target group"
  value       = aws_lb_target_group.client.arn
}

output "server_tg_arn" {
  description = "ARN of the server target group"
  value       = aws_lb_target_group.server.arn
}

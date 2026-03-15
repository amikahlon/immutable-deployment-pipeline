output "client_asg_name" {
  description = "Name of the client Auto Scaling Group"
  value       = aws_autoscaling_group.client.name
}

output "server_asg_name" {
  description = "Name of the server Auto Scaling Group"
  value       = aws_autoscaling_group.server.name
}

output "client_launch_template_id" {
  description = "ID of the client Launch Template"
  value       = aws_launch_template.client.id
}

output "server_launch_template_id" {
  description = "ID of the server Launch Template"
  value       = aws_launch_template.server.id
}

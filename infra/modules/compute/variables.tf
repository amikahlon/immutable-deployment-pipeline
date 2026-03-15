variable "project_name" {
  type        = string
  description = "Project name used as a prefix for all resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region (needed for ECR login in user data)"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs where ASG instances will launch"
}

variable "app_security_group_id" {
  type        = string
  description = "Security group ID to attach to EC2 instances"
}

variable "client_tg_arn" {
  type        = string
  description = "ARN of the ALB target group for the client"
}

variable "server_tg_arn" {
  type        = string
  description = "ARN of the ALB target group for the server"
}

variable "client_repository_url" {
  type        = string
  description = "ECR repository URL for the client image"
}

variable "server_repository_url" {
  type        = string
  description = "ECR repository URL for the server image"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to pull from ECR"
  default     = "latest"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances in each ASG"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances in each ASG"
  default     = 3
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances in each ASG"
  default     = 2
}

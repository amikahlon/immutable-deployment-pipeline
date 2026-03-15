variable "project_name" {
  type        = string
  description = "Project name used as a prefix for all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID to attach to the ALB"
}

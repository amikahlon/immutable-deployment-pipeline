variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_1_cidr" {
  type        = string
  description = "CIDR block for public subnet 1"
}

variable "public_subnet_2_cidr" {
  type        = string
  description = "CIDR block for public subnet 2"
}

variable "private_subnet_1_cidr" {
  type        = string
  description = "CIDR block for private subnet 1"
}

variable "private_subnet_2_cidr" {
  type        = string
  description = "CIDR block for private subnet 2"
}

variable "az_1" {
  type        = string
  description = "Availability Zone 1"
}

variable "az_2" {
  type        = string
  description = "Availability Zone 2"
}

# ── GitHub OIDC ──────────────────────────────────────────────────────────────

variable "github_org" {
  type        = string
  description = "GitHub username or organisation that owns the repository"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name (without the org prefix)"
}

variable "create_oidc_provider" {
  type        = bool
  description = "Set to false if the GitHub OIDC provider already exists in this account"
  default     = true
}

# ── Compute ──────────────────────────────────────────────────────────────────

variable "instance_type" {
  type        = string
  description = "EC2 instance type for application instances"
  default     = "t3.small"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to pull from ECR (set per deployment)"
  default     = "latest"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of instances in the ASG"
  default     = 1
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of instances in the ASG"
  default     = 3
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired number of instances in the ASG"
  default     = 2
}

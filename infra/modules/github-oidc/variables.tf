variable "project_name" {
  type        = string
  description = "Project name used as a prefix for all resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region (used to scope IAM policy resource ARNs)"
}

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

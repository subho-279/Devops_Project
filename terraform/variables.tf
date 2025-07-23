variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "artifact_bucket_name" {
  description = "Name of the S3 bucket used by CodePipeline"
  default     = "devops-masters-artifacts-subho"
}

variable "logging_bucket_name" {
  description = "Name of the S3 bucket to store logs"
  default     = "devops-masters-logs-subho"
}

variable "github_owner" {
  description = "GitHub repository owner"
  default     = "subho-279"
}

variable "github_repo" {
  description = "GitHub repository name"
  default     = "Devops_Project"
}

variable "github_branch" {
  description = "Branch to use in GitHub repo"
  default     = "main"
}

variable "github_token" {
  description = "GitHub token for CodePipeline (set in Terraform Cloud or TF_VAR)"
  type        = string
}
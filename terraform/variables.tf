variable "aws_region" {
  default = "us-east-1"
}

variable "artifact_bucket_name" {
  default = "devops-masters-artifacts-subho"
}

variable "github_owner" {
  default = "subho-279"
}

variable "github_repo" {
  default = "Devops_Project"
}

variable "github_branch" {
  default = "main"
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}
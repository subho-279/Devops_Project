variable "artifact_bucket_name" {
  description = "S3 bucket for CodePipeline artifacts"
  type        = string
}

variable "logging_bucket_name" {
  description = "S3 bucket for logging"
  type        = string
}

variable "logging_target_bucket" {
  description = "Target S3 bucket for logging"
  type        = string
}

variable "logging_target_prefix" {
  description = "Prefix for access logs"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN for encrypting S3 buckets"
  type        = string
  default     = "arn:aws:kms:us-east-1:067518243275:key/f810e2bd-13aa-4d5c-8396-35686de12eca"
}

variable "kms_key_id" {
  description = "KMS Key ID for encrypting S3 buckets"
  type        = string
  default     = "f810e2bd-13aa-4d5c-8396-35686de12eca"
}

variable "github_repo" {
  description = "GitHub repository in the format username/repo"
  type        = string
  default     = "subho-279/Devops_Subhojeet"
}

variable "github_branch" {
  description = "GitHub branch to deploy from"
  type        = string
  default     = "main"
}

variable "repo_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "subho-279"
}

variable "repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = "Devops_Subhojeet"
}

variable "repo_url" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/subho-279/Devops_Subhojeet.git"
}

variable "repo_branch" {
  description = "GitHub branch to use"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub Personal Access Token for CodePipeline integration"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "ec2_private_key" {
  description = "PEM private key used to SSH into EC2 instance"
  type        = string
  sensitive   = true
}
variable "ec2_ssh_key" {
  description = "Base64 encoded EC2 SSH key"
  type        = string
}

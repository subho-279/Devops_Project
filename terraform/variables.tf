variable "artifact_bucket_name" {
  description = "S3 bucket for CodePipeline artifacts"
  type        = string
}

variable "logging_bucket_name" {
  description = "S3 bucket for access logs"
  type        = string
}

# FIX: removed logging_target_bucket var — now uses resource reference in main.tf
# FIX: kept logging_target_prefix only
variable "logging_target_prefix" {
  description = "Prefix for access logs stored in the logging bucket"
  type        = string
  default     = "access-logs/"
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

variable "repo_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "subho-279"
}

variable "repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = "Devops_Project"
}

variable "repo_branch" {
  description = "GitHub branch to deploy from"
  type        = string
  default     = "main"
}

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "ec2_ip" {
  description = "Public IP of the EC2 deploy target"
  type        = string
  default     = "3.86.200.44"
}

# FIX: SSH key is now referenced from SSM Parameter Store, not passed as plaintext
variable "ec2_ssh_key_ssm_param" {
  description = "SSM Parameter Store path holding the base64-encoded EC2 SSH private key"
  type        = string
  default     = "/devops/ec2_ssh_key"
}

# FIX: GitHub token is now referenced from SSM Parameter Store
variable "github_token_ssm_param" {
  description = "SSM Parameter Store path holding the GitHub Personal Access Token"
  type        = string
  default     = "/devops/github_token"
}

# Kept for backward compatibility but no longer used in main.tf
variable "ec2_private_key" {
  description = "DEPRECATED — store key in SSM Parameter Store instead"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ec2_ssh_key" {
  description = "DEPRECATED — store key in SSM Parameter Store instead"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_token" {
  description = "DEPRECATED — store token in SSM Parameter Store instead"
  type        = string
  sensitive   = true
  default     = ""
}

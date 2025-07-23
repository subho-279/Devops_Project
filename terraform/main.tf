provider "aws" {
  region = var.aws_region
}

# Artifact storage bucket (secured)
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.artifact_bucket_name

  versioning {
    enabled = true
  }

  tags = {
    Name        = "artifact-bucket"
    Environment = "dev"
  }
}

# Encryption for the artifact bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.artifact_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all forms of public access
resource "aws_s3_bucket_public_access_block" "artifact_bucket_block" {
  bucket                  = aws_s3_bucket.artifact_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Logging configuration
resource "aws_s3_bucket_logging" "artifact_bucket_logging" {
  bucket        = aws_s3_bucket.artifact_bucket.id
  target_bucket = var.logging_bucket_name
  target_prefix = "artifact-logs/"
}

# Logging bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket_name

  versioning {
    enabled = true
  }

  tags = {
    Name        = "log-bucket"
    Environment = "dev"
  }
}

# CodePipeline IAM Role
resource "aws_iam_role" "codepipeline_role" {
  name = "devops-masters-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# CodeBuild IAM Role
resource "aws_iam_role" "codebuild_role" {
  name = "devops-masters-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# CodeBuild Project
resource "aws_codebuild_project" "devops_build" {
  name          = "DevOpsMastersBuild"
  description   = "Build project for DevOps pipeline"
  build_timeout = 10
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:6.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type     = "CODEPIPELINE"
    buildspec = file("buildspec.yml")
  }
}

# CodePipeline with GitHub (v1 for now)
resource "aws_codepipeline" "devops_pipeline" {
  name     = "DevOpsMastersPipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.devops_build.name
      }
    }
  }
}
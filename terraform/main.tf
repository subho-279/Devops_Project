provider "aws" {
  region = var.region
}
resource "aws_s3_bucket_public_access_block" "artifact_block" {
  bucket                  = aws_s3_bucket.artifact_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Artifact S3 bucket
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.artifact_bucket_name
}

# Logging S3 bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket_name
  logging {
    target_bucket = var.logging_target_bucket
    target_prefix = var.logging_target_prefix
  }
}


# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "artifact_encryption" {
  bucket = aws_s3_bucket.artifact_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_encryption" {
  bucket = aws_s3_bucket.logging_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "artifact_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "logging_versioning" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Logging configuration
resource "aws_s3_bucket_logging" "logging_config" {
  bucket        = aws_s3_bucket.artifact_bucket.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

# Public access block
resource "aws_s3_bucket_public_access_block" "logging_bucket_block" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# IAM Roles
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-subho-20250723"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role-subho-20250723"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# CodeBuild Project
resource "aws_codebuild_project" "devops_build" {
  name          = "MyBuildProject"
  description   = "DevOps Build"
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
    type      = "CODEPIPELINE"
    buildspec = file("buildspec.yml")
  }
}

resource "aws_codebuild_project" "deploy_project" {
  name         = "DeployToEC2"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "EC2_IP"
      value = "3.86.200.44"
    }

    environment_variable {
      name  = "EC2_SSH_USER"
      value = "ec2-user"
    }

    environment_variable {
      name  = "EC2_SSH_KEY"
      value = var.ec2_ssh_key
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = var.github_token
    }

    environment_variable {
      name  = "REGION"
      value = var.region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "deploy/buildspec.yml"
  }
}

# CodePipeline (GitHub v1, optional warning)
resource "aws_codepipeline" "pipeline" {
  name     = "DevOpsPipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifact_bucket.bucket
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.repo_owner
        Repo       = var.repo_name
        Branch     = var.repo_branch
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      version          = "1"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.devops_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToEC2"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        ProjectName = aws_codebuild_project.deploy_project.name
      }
    }
  }
}
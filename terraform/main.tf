provider "aws" {
  region = var.region
}

# --------------------------------------------------------------------------
# S3 Buckets
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.artifact_bucket_name
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket_name
}

# Public access blocks
resource "aws_s3_bucket_public_access_block" "artifact_block" {
  bucket                  = aws_s3_bucket.artifact_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "logging_bucket_block" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

# Versioning
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

# Logging: artifact bucket → logging bucket
resource "aws_s3_bucket_logging" "artifact_logging" {
  bucket        = aws_s3_bucket.artifact_bucket.id
  target_bucket = aws_s3_bucket.logging_bucket.id   # FIX: use resource ref, not var
  target_prefix = var.logging_target_prefix
}

# --------------------------------------------------------------------------
# IAM Roles
# --------------------------------------------------------------------------

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

# FIX: CodeBuild also needs S3 and logs access to function properly
resource "aws_iam_role_policy" "codebuild_s3_logs" {
  name = "codebuild-s3-logs-policy"
  role = aws_iam_role.codebuild_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:GetObjectVersion"],
        Resource = "${aws_s3_bucket.artifact_bucket.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
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

# FIX: CodePipeline also needs S3 access for artifacts
resource "aws_iam_role_policy" "codepipeline_s3" {
  name = "codepipeline-s3-policy"
  role = aws_iam_role.codepipeline_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:PutObject", "s3:GetBucketVersioning", "s3:GetObjectVersion", "s3:ListBucket"],
      Resource = [
        aws_s3_bucket.artifact_bucket.arn,
        "${aws_s3_bucket.artifact_bucket.arn}/*"
      ]
    }]
  })
}

# --------------------------------------------------------------------------
# CodeBuild Projects
# --------------------------------------------------------------------------

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
    buildspec = "buildspec.yml"   # FIX: don't use file() for CODEPIPELINE type; reference path relative to source
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
      value = var.ec2_ip
    }

    environment_variable {
      name  = "EC2_SSH_USER"
      value = "ec2-user"
    }

    # FIX: Store SSH key as PARAMETER_STORE or SECRETS_MANAGER, not PLAINTEXT
    environment_variable {
      name  = "EC2_SSH_KEY"
      value = var.ec2_ssh_key_ssm_param
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = var.github_token_ssm_param
      type  = "PARAMETER_STORE"
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

# --------------------------------------------------------------------------
# CodePipeline
# FIX: GitHub v1 (OAuthToken) is deprecated — upgraded to GitHub v2 (CodeStarConnection)
# --------------------------------------------------------------------------

resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

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
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"  # FIX: use v2 connection
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.repo_owner}/${var.repo_name}"
        BranchName       = var.repo_branch
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

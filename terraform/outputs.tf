output "artifact_bucket_name" {
  description = "S3 bucket used for CodePipeline artifacts"
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "logging_bucket_name" {
  description = "S3 bucket used for logging"
  value       = aws_s3_bucket.logging_bucket.bucket
}

output "codepipeline_url" {
  description = "URL to view the CodePipeline in AWS Console"
  value       = "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.pipeline.name}/view?region=${var.region}"
}

output "codebuild_project_name" {
  value = aws_codebuild_project.devops_build.name
}
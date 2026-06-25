output "artifact_bucket_name" {
  description = "S3 bucket used for CodePipeline artifacts"
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "logging_bucket_name" {
  description = "S3 bucket used for access logging"
  value       = aws_s3_bucket.logging_bucket.bucket
}

output "codepipeline_url" {
  description = "URL to view the CodePipeline in AWS Console"
  value       = "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.pipeline.name}/view?region=${var.region}"
}

output "codebuild_build_project_name" {
  description = "Name of the build CodeBuild project"
  value       = aws_codebuild_project.devops_build.name
}

output "codebuild_deploy_project_name" {
  description = "Name of the deploy CodeBuild project"
  value       = aws_codebuild_project.deploy_project.name
}

# FIX: expose the CodeStar connection ARN so it can be activated in the console
output "codestar_connection_arn" {
  description = "CodeStar GitHub connection ARN — must be manually activated in the AWS Console before the pipeline runs"
  value       = aws_codestarconnections_connection.github.arn
}

output "codestar_connection_status" {
  description = "Current status of the CodeStar GitHub connection (must be AVAILABLE before pipeline runs)"
  value       = aws_codestarconnections_connection.github.connection_status
}

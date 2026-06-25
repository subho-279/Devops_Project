package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCodePipeline(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"artifact_bucket_name":  "test-artifact-bucket-subho-ci",
			"logging_bucket_name":   "test-logging-bucket-subho-ci",
			"logging_target_prefix": "access-logs/",
			// FIX: removed logging_target_bucket (no longer a variable)
			// FIX: secrets now reference SSM param paths, not raw values
			"ec2_ssh_key_ssm_param":  "/devops/ec2_ssh_key",
			"github_token_ssm_param": "/devops/github_token",
			"repo_owner":             "subho-279",
			"repo_name":              "Devops_Project",
			"repo_branch":            "main",
			"region":                 "us-east-1",
			"ec2_ip":                 "3.86.200.44",
		},

		// Retry on known transient errors
		MaxRetries:         3,
		TimeBetweenRetries: 5,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs exist and are non-empty
	artifactBucket := terraform.Output(t, terraformOptions, "artifact_bucket_name")
	assert.NotEmpty(t, artifactBucket, "artifact_bucket_name output should not be empty")

	loggingBucket := terraform.Output(t, terraformOptions, "logging_bucket_name")
	assert.NotEmpty(t, loggingBucket, "logging_bucket_name output should not be empty")

	pipelineURL := terraform.Output(t, terraformOptions, "codepipeline_url")
	assert.Contains(t, pipelineURL, "codepipeline", "codepipeline_url should contain 'codepipeline'")

	connectionARN := terraform.Output(t, terraformOptions, "codestar_connection_arn")
	assert.Contains(t, connectionARN, "arn:aws", "codestar_connection_arn should be a valid ARN")
}

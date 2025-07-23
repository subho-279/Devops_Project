<<<<<<< HEAD
// cleaned placeholder
=======
package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformCodePipeline(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform",

		Vars: map[string]interface{}{
			"artifact_bucket_name":      "my-artifact-bucket-unique-name",
			"logging_bucket_name":       "my-logging-bucket-unique-name",
			"logging_target_bucket":     "my-logging-bucket-unique-name",
			"logging_target_prefix":     "access-logs/",
			
			"ec2_ssh_key":               "devops_key",
			"kms_key_arn":               "arn:aws:kms:us-east-1:067518243275:key/f810e2bd-13aa-4d5c-8396-35686de12eca",
			"github_repo":               "subho-279/Devops_Subhojeet",
			
			"repo_owner":                "subho-279",
			"repo_name":                 "Devops_Subhojeet",
			"repo_branch":               "main",
			"repo_url":                  "https://github.com/subho-279/Devops_Subhojeet.git",
			"region":                    "us-east-1",
		},
	}

	// Init and apply
	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)
}
>>>>>>> ac779e9 (Triggering pipeline test)

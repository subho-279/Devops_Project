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
			"ec2_private_key":           "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBekRHVVdaMFR5V3FKSisxMmJmZ0xSUEYyeW00Nk5pcXVTcW9abUFwcE5zYWYwQzdQCk1IWTlvU215eU1zaktIZW5NZW15c1FLVkt0MTl5NkZqcjgyWm5SNEpudU9QWjgrWmkxYXNjOW5lUDA4dmxXZE0KMlZnRlJuSlBIbG9KVUw3eXBjQUJTdHVwK2s0YVN5cHc0NldHU2hhdDRNSDBxNmlVUVdPaCtUc0F3MUorc1dXZwpoSEdZSGFXcmxQOG5CbkNkbkphRUUxcHhrVHU5SnRIVzhQTmlpNklieUpscGFhMVBvVUozRDhqSTZJMWxkWVVyClQxTWJ6aVR3SmVVbTd6S1JrMUFCQjk3V1M3dGswd3NWcERETk0vZWQwT1lHbGZ3dXJkVDhaQ0RPT1F3WWtwOU0KU3hyRWZXdWhoTDZ3dFd3T0plOEZYWVIvTnZ6YnNMMldaa0UvRXdJREFRQUJBb0lCQVFDaXZIVFdBc2tOUWxuegpOMTZtZ0FSRE93b0loVmJoYXB5anB2Tms2QTg0ZDQ1UXRhMnNtdCs5UE9WZS8vNlNOdUpLZGsxU281Tk1xVitqClZZbUVTQ0RBUm5zMlpYZ2FMU3JiRVFXNkF3NE1lTWlja3NwOWdaZ2FyK2w4Y0JkeWdld1N5M1o4T1pzN2dObVYKeEVwYU04WlY3OE0rR0hZdUJObTdUM044bFZpalVRTXlodFdHQ1QwT0JtMVZ6UW95clF5SEJaK3BUcXkyVXI4SQpiL0l5ZlR1Y0t0eWJ0VEpPc01hVlZNQ1RCSXBiL0tWRUR5aUU5c2Q1Smp2SXpPSmdaZUVDVjJLZVRScWlIOCt3CmtQK0hmZGZWczB2dnVaY1BXcUsxQlRma2lXTWxQblA4VnY5Z05SS3NuTnIyRHZSSkpXUXFCRUpjbFhLblJxS2QKV0xncjFONXhBb0dCQVBpQU1za25tYzNocW5DYTg3aGhrZXRoTmNob3VzbmlpeXVIL2xhZjA1TnRITDF0NEhNYgpFdW45ZTBZK1VDNlhvVnF4d0pjWUJHbGFLcEhpUXI3YVo3TytxODgxMEVvTjBrTDdNQS9DeUtydGo3TkdlQkdLCjFRRCtLOU5HTUxmVGo5dWRxVXRBK2o5Q3dNNE5KMEZiZmhkbk41Yk5lUlR4RzA3cnpVTUE0L2dwQW9HQkFOSmIKRmNHMWw0MlVVZktIaWQ4RFFNdDVLdmpqbHdFTmdoTEUxTHUyc2w5TWhiVTJabUFHR1FRV3JYNWVLRlpTbCtadQp5L3RramdaUjBUM2dUNlJzdUhoTnp6cHZCSDJjUG05Mm1idHpxT3d3L2RIR080N2l6cGVORmx5eHp3M2p1dXQxCmdlMkpTTVZBWlBJQjhpcU5Hd3RscHlJWkk5QUtROXhiVkNockt0VGJBb0dCQUt2c0hiYTNkQnhSUFJic3pTTksKTmFjUU9TSnUrcFBEN1I3djFsSGQvNFhtbmxTY0dRWHB2RHN3aU1IL1NJQURuYmxlY3V6VnkrK0xWeHBZM0c2bwpNY2pVYUk5U0hzbXRLRVA0L3JaWXYzWXFKeG9UN2V2TkRqTENwbFZrSVQ1ODJ2Rkk4YUJEMHg1RE01c2ExSWJPCklyMVVSc3hKV2JUWVhsbEtvRmJ6M2NTSkFvR0FaS0p3eVNoUDVjcTBYWnZjS0pYTTFNc1Y5Tllrc3JzOHBEQUkKT2ZtUVlpa2d1bTNaRWswNGdJMDgyUHpBdlhOcitqQzlZM3BhdThrK21pU0sxWFd4MXRRYXRMRFI3Q25vY0xqRAptVHNlOEVnTDFlVEpMM1Z3TW02cjZSS2pwTmh5M3h4cldURlpZQXlMZm4vUjArdUhxYThyQXhRVjN2eGFOTHg0CmlaR2pmd3NDZ1lBMWhIaU5jYmk3bWp6U1BCRGhyTjM4WWFTcmFUOVA3L3RlNmNRbEFrbW9SZHhaeXhqSG9iZEwKWTZjcmVWdmJ6K0JKc1hlenF4THpiU0tUNmVWNDQ2b1c3RzNQOGg4TnVuc0dNUkhRQmMyd2xtcHRrb1VUWW9RbQp2K0tRUENJM0FXUkR5MXo2NmJXWnVQb2VNTDFicHRhdVVtWUFpbC9QSGtHYmFsN1RLcS9rVkE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQ==%.pem",
			"ec2_ssh_key":               "devops_key",
			"kms_key_arn":               "arn:aws:kms:us-east-1:067518243275:key/f810e2bd-13aa-4d5c-8396-35686de12eca",
			"github_repo":               "subho-279/Devops_Subhojeet",
			"github_token":              "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",
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

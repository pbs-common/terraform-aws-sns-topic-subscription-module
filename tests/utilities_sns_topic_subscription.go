package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func testSNSTopicSubscription(t *testing.T, variant string) {
	t.Parallel()

	terraformDir := fmt.Sprintf("../examples/%s", variant)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		LockTimeout:  "5m",
		Upgrade: true,
	}

	defer terraform.Destroy(t, terraformOptions)

	packageLambda(t, variant)

	terraform.InitAndApply(t, terraformOptions)

	awsAccountID := getAWSAccountID(t)
	awsRegion := getAWSRegion(t)

	expectedName := fmt.Sprintf("ex-tf-sns-topic-sub-%s", variant)

	expectedPartialARN := fmt.Sprintf("arn:aws:sns:%s:%s:%s:", awsRegion, awsAccountID, expectedName)

	arn := terraform.Output(t, terraformOptions, "arn")
	assert.Contains(t, arn, expectedPartialARN)
}

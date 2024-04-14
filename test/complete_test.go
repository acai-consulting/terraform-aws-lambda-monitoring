package test

import (
	"context"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials/stscreds"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go-v2/service/sts"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestExampleComplete(t *testing.T) {
	// Log to indicate start of test
	t.Log("Starting Sample Module test")

	terraformComplete := &terraform.Options{
		TerraformDir: "../examples/complete",
		NoColor:      false,
		Lock:         true,
	}

	defer terraform.Destroy(t, terraformComplete)
	terraform.InitAndApply(t, terraformComplete)

	logGroupName := terraform.Output(t, terraformComplete, "central_error_loggroup_name")

	// Wait for 10 seconds before proceeding to log group entries test
	t.Log("Waiting 10 seconds before invoking log group entries test")
	time.Sleep(10 * time.Second)

	// Core Security ARN
	testLogGroupEntries(t, logGroupName, "arn:aws:iam::992382728088:role/OrganizationAccountAccessRole")
}

func testLogGroupEntries(t *testing.T, logGroupName string, roleArn string) {
	// Load the default AWS configuration
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		t.Fatalf("Failed to load AWS SDK config, %s", err)
	}

	stsClient := sts.NewFromConfig(cfg)

	creds := stscreds.NewAssumeRoleProvider(stsClient, roleArn)

	cfg.Credentials = aws.NewCredentialsCache(creds)

	cwLogsClient := cloudwatchlogs.NewFromConfig(cfg)

	// Define the time frame to check for log entries
	now := time.Now()
	input := &cloudwatchlogs.FilterLogEventsInput{
		LogGroupName: &logGroupName,
		StartTime:    aws.Int64(now.Add(-24*time.Hour).Unix() * 1000), // Checking for logs in the last 24 hours
		EndTime:      aws.Int64(now.Unix() * 1000),
	}

	// Query the CloudWatch Logs
	result, err := cwLogsClient.FilterLogEvents(context.TODO(), input)
	if err != nil {
		t.Fatalf("Failed to retrieve log events: %s", err)
	}

	// Assert that there are log entries
	assert.NotEmpty(t, result.Events, "The log group should contain log entries")
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.00"
      configuration_aliases = []
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_region" "current" {}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = merge(
    var.resource_tags,
    {
      "module_lambda_provider" = "ACAI GmbH",
      "module_lambda_origin"   = "terraform registry",
      "module_lambda_source"   = "acai-consulting/lambda-monitoring/aws",
      "module_lambda_version"  = /*inject_version_start*/ "1.0.0" /*inject_version_end*/
    }
  )
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ COLLECTOR CLOUDWATCH LOGGROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "central_error_loggroup" {
  #checkov:skip=CKV_AWS_338
  name              = var.settings.error_loggroup_name
  retention_in_days = var.settings.retention_in_days
  kms_key_id        = var.existing_kms_cmk_arn
  tags              = local.resource_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM ROLE TO BE ASSUMED BY TRUSTED ACCOUNTS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "central_lambda_role" {
  name                 = var.settings.iam_role_name
  assume_role_policy   = data.aws_iam_policy_document.central_lambda_role_trust.json
  path                 = var.iam_role_settings.path
  permissions_boundary = var.iam_role_settings.permissions_boundary_arn
  tags                 = local.resource_tags
}

data "aws_iam_policy_document" "central_lambda_role_trust" {
  statement {
    sid     = "TrustPolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [for id in var.settings.trusted_account_ids : "arn:aws:iam::${id}:root"]
    }
  }
}

resource "aws_iam_role_policy" "central_lambda_role_permissions" {
  name   = "AllowCloudWatchLogGroup"
  role   = aws_iam_role.central_lambda_role.name
  policy = data.aws_iam_policy_document.central_lambda_role_permissions.json
}

#tfsec:ignore:AVD-AWS-0057
data "aws_iam_policy_document" "central_lambda_role_permissions" {
  #checkov:skip=CKV_AWS_356 
  statement {
    sid     = "LogsToCloudWatch"
    effect  = "Allow"
    actions = ["logs:DescribeLogStreams", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      aws_cloudwatch_log_group.central_error_loggroup.arn,
      "${aws_cloudwatch_log_group.central_error_loggroup.arn}:*"
    ]
  }
}

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
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

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
      "module_lambda_version"  = /*inject_version_start*/ "1.0.1" /*inject_version_end*/
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ FORWARDING LAMBDA
# ---------------------------------------------------------------------------------------------------------------------
module "forwarder_lambda" {
  #checkov:skip=CKV_TF_1: Currently version-tags are used
  source  = "acai-consulting/lambda/aws"
  version = "1.2.1"

  lambda_settings = {
    function_name = var.settings.lambda_name
    description   = "Target for LogGroup Subscription-filter."
    config = {
      runtime               = "python3.10"
      architecture          = "arm64"
      timeout               = var.lambda_settings.timeout
      memory_size           = var.lambda_settings.memory_size
      log_retention_in_days = var.lambda_settings.log_retention_in_days
    }
    package = {
      source_path = "${path.module}/lambda-files"
    }
    environment_variables = {
      LOG_LEVEL                          = var.lambda_settings.log_level
      ACCOUNT_ID                         = data.aws_caller_identity.this.account_id
      REGION                             = data.aws_region.this.name
      CENTRAL_ERROR_IAM_ROLE_ARN         = var.settings.central_iam_role_arn
      CENTRAL_ERROR_LOGGROUP_NAME        = var.settings.central_loggroup_name
      CENTRAL_ERROR_LOGGROUP_REGION_NAME = var.settings.central_loggroup_region_name
    }
  }
  execution_iam_role_settings = {
    new_iam_role = merge(
      var.iam_role_settings,
      {
        permission_policy_json_list = [data.aws_iam_policy_document.lambda_execution_role_permission.json]
      }
    )
  }
  resource_tags = local.resource_tags
}

data "aws_iam_policy_document" "lambda_execution_role_permission" {
  statement {
    sid = "LogGroupAccess"
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    resources = [
      var.settings.central_iam_role_arn
    ]
  }
}


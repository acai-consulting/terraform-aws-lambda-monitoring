# ---------------------------------------------------------------------------------------------------------------------
# ¦ VERSIONS
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
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CENTRAL LOGGING
# ---------------------------------------------------------------------------------------------------------------------
module "central_logging" {
  source = "../../modules/central_logging"

  settings = {
    trusted_account_ids = ["767398146370"] // workload
  }
  providers = {
    aws = aws.core_security
  }
}

locals {
  forwarder_settings = {
    central_iam_role_arn         = module.central_logging.central_iam_role_arn
    central_loggroup_name        = module.central_logging.central_error_loggroup_name
    central_loggroup_region_name = module.central_logging.central_error_loggroup_region_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ WORKLOAD ACCOUNT - EUC1
# ---------------------------------------------------------------------------------------------------------------------
module "workload_euc1" {
  source = "./workload"

  forwarder_settings = {
    lambda_name     = "euc1-lambda-error-forwarder"
    central_logging = module.central_logging.central_logging
  }
  failing_lambda_prefix     = "euc1-failing-lambda"
  number_of_failing_lambdas = 3

  providers = {
    aws = aws.workload_euc1
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ WORKLOAD ACCOUNT - USE1
# ---------------------------------------------------------------------------------------------------------------------
module "workload_use1" {
  source = "./workload"
  forwarder_settings = {
    lambda_name     = "use1-lambda-error-forwarder"
    central_logging = module.central_logging.central_logging
  }
  failing_lambda_prefix = "use1-lambda-failing"

  number_of_failing_lambdas = 2
  providers = {
    aws = aws.workload_use1
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ WORKLOAD DEMO LAMBDA INVOCATIONS
# ---------------------------------------------------------------------------------------------------------------------
data "aws_lambda_invocation" "workload_euc1_invoke_lambdas" {
  for_each = { for idx in module.workload_euc1.workload_lambda_names : idx => idx }

  function_name = each.key
  input         = <<JSON
{
  "logs": {
    "warn": "EUC1 This is a warning message.",
    "error": "EUC1 This is an error message.",
    "info": "EUC1 This is an informational message.",
    "exception": "EUC1 This is a message with an exception."
  }
}
JSON
  provider      = aws.workload_euc1
  depends_on = [
    module.workload_euc1
  ]
}

data "aws_lambda_invocation" "workload_use1_invoke_lambdas" {
  for_each = { for idx in module.workload_use1.workload_lambda_names : idx => idx }

  function_name = each.key
  input         = <<JSON
{
  "logs": {
    "warn": "USE1 This is a warning message.",
    "error": "USE1 This is an error message.",
    "info": "USE1 This is an informational message.",
    "exception": "USE1 This is a message with an exception."
  }
}
JSON
  provider      = aws.workload_use1
  depends_on = [
    module.workload_use1
  ]
}

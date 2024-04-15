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
# ¦ WORKLOAD ACCOUNT - EUC1
# ---------------------------------------------------------------------------------------------------------------------
module "workload_error_forwarder" {
  source = "../../../"

  settings = var.forwarder_settings
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ WORKLOAD ACCOUNT - EUC1 - DEMO LAMBDAS
# ---------------------------------------------------------------------------------------------------------------------
module "workload_lambda" {
  #checkov:skip=CKV_TF_1: Currently version-tags are used
  count   = var.number_of_failing_lambdas
  source  = "acai-consulting/lambda/aws"
  version = "1.2.2"

  lambda_settings = {
    function_name = "${var.failing_lambda_prefix}-${count.index + 1}"
    description   = "This Lambda will cause an Error"
    config = {
      architecture          = "arm64"
      runtime               = "python3.10"
      log_level             = "INFO"
      log_retention_in_days = 7
      memory_size           = 512
      timeout               = 60
    }
    error_handling = {
      central_collector = {
        target_arn = module.workload_error_forwarder.forwarder_lambda.lambda.arn
      }
    }
    package = {
      source_path = "${path.module}/lambda-files"
    }
  }
  depends_on = [
    module.workload_error_forwarder
  ]
}

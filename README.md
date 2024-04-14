# terraform-aws-lambda-monitoring

<!-- LOGO -->
<a href="https://acai.gmbh">    
  <img src="https://acai.gmbh/images/logo/logo-acai-badge.png" alt="acai logo" title="ACAI" align="right" height="100" />
</a>

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url]
![module-version-shield]
![terraform-version-shield]
![trivy-shield]
![checkov-shield]
[![Latest Release][release-shield]][release-url]

<!-- DESCRIPTION -->
[Terraform][terraform-url] module to centrally monitor Lambda functions located in multiple accounts and regions.
Requires: https://github.com/acai-consulting/terraform-aws-lambda

<!-- ARCHITECTURE -->
## Architecture
![architecture](https://raw.githubusercontent.com/acai-consulting/terraform-aws-lambda-monitoring/main/docs/terraform-aws-lambda-monitoring.svg)

<!-- USAGE -->
## Usage

### Central Logging
```hcl
module "central_logging" {
  source = "git::https://github.com/acai-consulting/terraform-aws-lambda-monitoring.git//modules/central_logging"

  settings = {
    trusted_account_ids = ["767398146370"] // workload
  }
}
```

### Workload Account
```hcl
# ---------------------------------------------------------------------------------------------------------------------
# ¦ WORKLOAD ACCOUNT - EUC1
# ---------------------------------------------------------------------------------------------------------------------
locals {
  forwarder_settings = {
    central_iam_role_arn         = module.core_configuration.central_logging.central_iam_role_arn
    central_loggroup_name        = module.core_configuration.central_logging.central_error_loggroup_name
    central_loggroup_region_name = module.core_configuration.central_logging.central_error_loggroup_region_name
  }
}

module "workload_error_forwarder" {
  source = "git::https://github.com/acai-consulting/terraform-aws-lambda-monitoring.git"

  settings = local.forwarder_settings
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ WORKLOAD ACCOUNT - DEMO LAMBDA
# ---------------------------------------------------------------------------------------------------------------------
module "workload_lambda" {
  source = "git::https://github.com/acai-consulting/terraform-aws-lambda.git?ref=1.2.1"

  lambda_settings = {
    function_name = "lambda-to-monitor"
    description   = "Errors of this Lambda will be forwarded to the Central Logging"
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
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.00 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.00 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_forwarder_lambda"></a> [forwarder\_lambda](#module\_forwarder\_lambda) | acai-consulting/lambda/aws | 1.2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_execution_role_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration for the central error collector. | <pre>object({<br>    lambda_name                  = optional(string, "lambda-error-forwarder")<br>    central_iam_role_arn         = string<br>    central_loggroup_name        = string<br>    central_loggroup_region_name = string<br>  })</pre> | n/a | yes |
| <a name="input_iam_role_settings"></a> [iam\_role\_settings](#input\_iam\_role\_settings) | Settings for IAM Roles. | <pre>object({<br>    path                     = optional(string, "/")<br>    permissions_boundary_arn = optional(string)<br>  })</pre> | <pre>{<br>  "path": "/",<br>  "permissions_boundary_arn": null<br>}</pre> | no |
| <a name="input_lambda_settings"></a> [lambda\_settings](#input\_lambda\_settings) | HCL map of the SEMPER Lambda-Settings. | <pre>object({<br>    timeout               = optional(number, 30)<br>    memory_size           = optional(number, 512)<br>    log_retention_in_days = optional(number, 90)<br>    log_level             = optional(string, "INFO")<br>  })</pre> | <pre>{<br>  "log_level": "INFO",<br>  "log_retention_in_days": 90,<br>  "memory_size": 512,<br>  "timeout": 60<br>}</pre> | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of tags to assign to the resources in this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | account\_id |
| <a name="output_forwarder_lambda"></a> [forwarder\_lambda](#output\_forwarder\_lambda) | account\_id |
<!-- END_TF_DOCS -->

<!-- AUTHORS -->
## Authors

This module is maintained by [ACAI GmbH][acai-url] with help from [these amazing contributors][contributors-url]

<!-- LICENSE -->
## License

This module is licensed under Apache 2.0
<br />
See [LICENSE][license-url] for full details

<!-- COPYRIGHT -->
<br />
<br />
<p align="center">Copyright &copy; 2024 ACAI GmbH</p>

<!-- MARKDOWN LINKS & IMAGES -->
[acai-url]: https://acai.gmbh
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[module-version-shield]: https://img.shields.io/badge/module_version-1.0.0-CB224B?style=flat
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.10-blue.svg?style=flat&color=blueviolet
[trivy-shield]: https://img.shields.io/badge/trivy-passed-green
[checkov-shield]: https://img.shields.io/badge/checkov-passed-green
[release-shield]: https://img.shields.io/github/v/release/acai-consulting/terraform-aws-lambda-monitoring?style=flat&color=success
[release-url]: https://registry.terraform.io/modules/acai-consulting/lambda-monitoring/aws/latest
[license-url]: ./LICENSE
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.com

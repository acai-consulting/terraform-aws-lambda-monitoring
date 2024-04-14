<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.00 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.00 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.central_error_loggroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.central_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.central_lambda_role_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.central_lambda_role_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.central_lambda_role_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration for the central error collector. | <pre>object({<br>    iam_role_name       = optional(string, "central-lambda-errors")<br>    trusted_account_ids = list(string)<br>    error_loggroup_name = optional(string, "/aws/lambda/central-lambda-errors")<br>    retention_in_days   = optional(number, 30)<br>  })</pre> | n/a | yes |
| <a name="input_existing_kms_cmk_arn"></a> [existing\_kms\_cmk\_arn](#input\_existing\_kms\_cmk\_arn) | KMS key ARN to be used to encrypt logs and sqs messages. | `string` | `null` | no |
| <a name="input_iam_role_settings"></a> [iam\_role\_settings](#input\_iam\_role\_settings) | Settings for IAM Roles. | <pre>object({<br>    path                     = optional(string, "/")<br>    permissions_boundary_arn = optional(string)<br>  })</pre> | <pre>{<br>  "path": "/",<br>  "permissions_boundary_arn": null<br>}</pre> | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of tags to assign to the resources in this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_central_error_loggroup_arn"></a> [central\_error\_loggroup\_arn](#output\_central\_error\_loggroup\_arn) | n/a |
| <a name="output_central_error_loggroup_name"></a> [central\_error\_loggroup\_name](#output\_central\_error\_loggroup\_name) | n/a |
| <a name="output_central_error_loggroup_region_name"></a> [central\_error\_loggroup\_region\_name](#output\_central\_error\_loggroup\_region\_name) | n/a |
| <a name="output_central_iam_role_arn"></a> [central\_iam\_role\_arn](#output\_central\_iam\_role\_arn) | n/a |
<!-- END_TF_DOCS -->
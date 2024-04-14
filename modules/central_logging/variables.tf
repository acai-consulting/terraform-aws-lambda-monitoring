variable "settings" {
  description = "Configuration for the central error collector."
  type = object({
    iam_role_name       = optional(string, "central-lambda-errors")
    trusted_account_ids = list(string)
    error_loggroup_name = optional(string, "/aws/lambda/central-lambda-errors")
    retention_in_days   = optional(number, 30)
  })

  validation {
    condition     = alltrue([for id in var.settings.trusted_account_ids : can(regex("^[0-9]{12}$", id))])
    error_message = "All account_ids must be 12-digit numbers."
  }

  validation {
    condition     = var.settings.retention_in_days == null || can(index([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.settings.retention_in_days))
    error_message = "Invalid log_retention_in_days value."
  }
}

variable "iam_role_settings" {
  description = "Settings for IAM Roles."
  type = object({
    path                     = optional(string, "/")
    permissions_boundary_arn = optional(string)
  })
  default = {
    path                     = "/"
    permissions_boundary_arn = null
  }

  validation {
    condition     = var.iam_role_settings.path == null ? true : can(regex("^/([^/]+(/[^/]+)*/?)?$", var.iam_role_settings.path))
    error_message = "Path value must start with '/' and can optionally end with '/', without containing consecutive '/' characters."
  }

  validation {
    condition     = var.iam_role_settings.permissions_boundary_arn == null ? true : can(regex("^arn:aws:iam::[0-9]{12}:policy/.+$", var.iam_role_settings.permissions_boundary_arn))
    error_message = "Permissions boundary ARN must be a valid IAM policy ARN, starting with 'arn:aws:iam::', followed by a 12-digit AWS account number, and the policy name."
  }
}

variable "existing_kms_cmk_arn" {
  description = "KMS key ARN to be used to encrypt logs and sqs messages."
  type        = string
  default     = null
  validation {
    condition     = var.existing_kms_cmk_arn == null ? true : can(regex("^arn:aws:kms", var.existing_kms_cmk_arn))
    error_message = "Value must contain ARN, starting with \"arn:aws:kms\"."
  }
}

variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}

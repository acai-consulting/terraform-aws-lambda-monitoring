variable "settings" {
  description = "Configuration for the central error collector."
  type = object({
    lambda_name = optional(string, "lambda-error-forwarder")
    central_logging = object({
      iam_role_arn               = string
      error_loggroup_name        = string
      error_loggroup_region_name = string
    })
  })
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

variable "lambda_settings" {
  description = "HCL map of the SEMPER Lambda-Settings."
  type = object({
    timeout               = optional(number, 30)
    memory_size           = optional(number, 512)
    log_retention_in_days = optional(number, 90)
    log_level             = optional(string, "INFO")
  })
  default = {
    timeout               = 60
    memory_size           = 512
    log_retention_in_days = 90
    log_level             = "INFO"
  }
}

variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}

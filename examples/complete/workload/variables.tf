variable "forwarder_settings" {
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

variable "failing_lambda_prefix" {
  type = string
}

variable "number_of_failing_lambdas" {
  type    = number
  default = 2
}

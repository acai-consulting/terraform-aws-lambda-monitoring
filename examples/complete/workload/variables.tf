variable "forwarder_settings" {
  description = "Configuration for the central error collector."
  type = object({
    lambda_name                  = optional(string, "lambda-error-forwarder")
    central_iam_role_arn         = string
    central_loggroup_name        = string
    central_loggroup_region_name = string
  })
}

variable "failing_lambda_prefix" {
  type = string
}

variable "number_of_failing_lambdas" {
  type    = number
  default = 2
}

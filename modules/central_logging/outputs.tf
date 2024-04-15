output "central_iam_role_arn" {
  description = "central_iam_role_arn"
  value = aws_iam_role.central_lambda_role.arn
}

output "central_error_loggroup_name" {
  description = "central_error_loggroup_name"
  value = aws_cloudwatch_log_group.central_error_loggroup.name
}

output "central_error_loggroup_region_name" {
  description = "central_error_loggroup_region_name"
  value = data.aws_region.current.name
}

output "central_error_loggroup_arn" {
  description = "central_error_loggroup_arn"
  value = aws_cloudwatch_log_group.central_error_loggroup.arn
}

output "central_logging" {
  description = "central_logging"
  value = {
    iam_role_arn               = aws_iam_role.central_lambda_role.arn
    error_loggroup_name        = aws_cloudwatch_log_group.central_error_loggroup.name
    error_loggroup_region_name = data.aws_region.current.name
  }
}

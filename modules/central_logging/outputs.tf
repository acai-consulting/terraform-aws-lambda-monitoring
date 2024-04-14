output "central_error_loggroup_name" {
  value = aws_cloudwatch_log_group.central_error_loggroup.name
}

output "central_error_loggroup_region_name" {
  value = data.aws_region.current.name

}

output "central_error_loggroup_arn" {
  value = aws_cloudwatch_log_group.central_error_loggroup.arn
}

output "central_iam_role_arn" {
  value = aws_iam_role.central_lambda_role.arn
}

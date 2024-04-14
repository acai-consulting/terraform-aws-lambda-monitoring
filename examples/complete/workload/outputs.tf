output "workload_lambda_names" {
  description = "Names of the workload lambda functions"
  value       = [for instance in module.workload_lambda : instance.lambda.name]
}

output "workload_lambda_arns" {
  description = "ARNs of the workload lambda functions"
  value       = [for instance in module.workload_lambda : instance.lambda.arn]
}

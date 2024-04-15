output "account_id" {
  description = "account_id"
  value       = data.aws_caller_identity.this.account_id
}

output "forwarder_lambda" {
  description = "forwarder_lambda"
  value = {
    target_name = module.forwarder_lambda.lambda.name
    target_arn  = module.forwarder_lambda.lambda.arn
  }
}

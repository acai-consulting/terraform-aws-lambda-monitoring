output "account_id" {
  description = "account_id"
  value       = data.aws_caller_identity.this.account_id
}

output "forwarder_lambda" {
  description = "forwarder_lambda"
  value       = module.forwarder_lambda
}

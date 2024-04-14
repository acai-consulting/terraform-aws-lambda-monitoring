output "central_logging" {
  description = "central_logging"
  value       = module.central_logging
}

output "central_error_loggroup_name" {
  description = "central_error_loggroup_name"
  value       = module.central_logging.central_error_loggroup_name
}


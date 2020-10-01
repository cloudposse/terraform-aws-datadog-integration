output "aws_account_id" {
  value       = module.datadog_integration.aws_account_id
  description = "AWS Account ID of the IAM Role for Datadog to use for this integration"
}

output "aws_role_name" {
  value       = module.datadog_integration.aws_role_name
  description = "Name of the AWS IAM Role for Datadog to use for this integration"
}

output "datadog_external_id" {
  value       = module.datadog_integration.datadog_external_id
  description = "Datadog integration external ID"
}

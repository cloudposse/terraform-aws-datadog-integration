output "aws_account_id" {
  value       = local.aws_account_id
  description = "AWS Account ID of the IAM Role for Datadog to use for this integration"
}

output "aws_role_name" {
  value       = aws_iam_role.default.name
  description = "Name of the AWS IAM Role for Datadog to use for this integration"
}

output "datadog_external_id" {
  value       = var.datadog_external_id
  description = "External ID from Datadog to use for this integration"
}
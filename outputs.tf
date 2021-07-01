output "aws_account_id" {
  value       = local.aws_account_id
  description = "AWS Account ID of the IAM Role for Datadog to use for this integration"
}

output "aws_role_name" {
  value       = join("", aws_iam_role.default.*.name)
  description = "Name of the AWS IAM Role for Datadog to use for this integration"
}

output "datadog_external_id" {
  value       = join("", datadog_integration_aws.integration.*.external_id)
  description = "Datadog integration external ID"
}

output "lambda_rds_function_id" {
  value       = join("", aws_lambda_function.forwarder_rds.*.id)
  description = "Lambda resource ID"
}

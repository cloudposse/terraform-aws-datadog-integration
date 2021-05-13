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

output "lambda_function_id" {
  value = length(aws_lambda_function.default) > 0 ? aws_lambda_function.default[0].id : null
}

output "lambda_iam_role_id" {
  value = length(aws_iam_role.lambda) > 0 ? aws_iam_role.lambda[0].id : null
}
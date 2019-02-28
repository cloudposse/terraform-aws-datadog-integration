output "role" {
  value       = "${aws_iam_role.default.name}"
  description = "Name of the AWS IAM Role for Datadog to use for this integration"
}

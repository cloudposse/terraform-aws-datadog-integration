output "role" {
  value       = "${aws_iam_role.default.name}"
  description = "Name of AWS IAM Role associated with creating integration"
}

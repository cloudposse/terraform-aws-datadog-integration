resource "aws_ssm_parameter" "example_api_key" {
  name  = "/datadog/api-key"
  type  = "String"
  value = "00000000-0000-0000-0000-000000000000"
}
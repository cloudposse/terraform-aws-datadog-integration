resource "aws_ssm_parameter" "test_fixture" {
  name  = "/datadog/api-key"
  type  = "String"
  value = "00000000-0000-0000-0000-000000000000"
}

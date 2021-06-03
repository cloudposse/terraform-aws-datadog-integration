module "datadog_integration" {
  source = "../../"

  datadog_aws_account_id           = var.datadog_aws_account_id
  integrations                     = var.integrations
  filter_tags                      = var.filter_tags
  host_tags                        = var.host_tags
  excluded_regions                 = var.excluded_regions
  account_specific_namespace_rules = var.account_specific_namespace_rules

  # Enables RDS enhanced monitoring
  dd_api_key_source = var.dd_api_key_source

  depends_on = [
    aws_ssm_parameter.test_fixture
  ]

  context = module.this.context
}

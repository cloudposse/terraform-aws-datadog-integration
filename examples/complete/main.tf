module "datadog_integration" {
  source = "../../"

  datadog_aws_account_id           = var.datadog_aws_account_id
  policies                         = var.policies
  filter_tags                      = var.filter_tags
  host_tags                        = var.host_tags
  excluded_regions                 = var.excluded_regions
  account_specific_namespace_rules = var.account_specific_namespace_rules

  context = module.this.context
}

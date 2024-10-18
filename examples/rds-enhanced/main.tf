module "datadog_integration" {
  source = "../../"

  datadog_aws_account_id               = var.datadog_aws_account_id
  integrations                         = var.integrations
  filter_tags                          = var.filter_tags
  host_tags                            = var.host_tags
  excluded_regions                     = var.excluded_regions
  account_specific_namespace_rules     = var.account_specific_namespace_rules
  security_audit_policy_enabled        = var.security_audit_policy_enabled
  extended_resource_collection_enabled = var.extended_resource_collection_enabled

  context = module.this.context
}

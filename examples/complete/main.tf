module "datadog_integration" {
  source = "../../"

  datadog_aws_account_id = var.datadog_aws_account_id
  integrations           = var.integrations

  context = module.this.context
}

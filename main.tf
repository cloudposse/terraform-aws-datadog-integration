data "aws_caller_identity" "current" {
  count = module.this.enabled ? 1 : 0
}

locals {
  aws_account_id      = join("", data.aws_caller_identity.current.*.account_id)
  datadog_external_id = join("", datadog_integration_aws.integration.*.external_id)
}

# https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws
# https://docs.datadoghq.com/api/v1/aws-integration/
resource "datadog_integration_aws" "integration" {
  count                            = module.this.enabled ? 1 : 0
  account_id                       = local.aws_account_id
  role_name                        = module.this.id
  filter_tags                      = var.filter_tags
  host_tags                        = host_tags
  excluded_regions                 = var.excluded_regions
  account_specific_namespace_rules = var.account_specific_namespace_rules
}

data "aws_iam_policy_document" "assume_role" {
  count = module.this.enabled ? 1 : 0

  statement {
    sid    = "DatadogAWSTrustRelationship"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.datadog_aws_account_id}:root"
      ]
    }

    condition {
      test = "StringEquals"
      values = [
      local.datadog_external_id]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role" "default" {
  count              = module.this.enabled ? 1 : 0
  name               = module.this.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
}

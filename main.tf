locals {
  enabled             = module.this.enabled
  aws_account_id      = join("", data.aws_caller_identity.current.*.account_id)
  aws_partition       = join("", data.aws_partition.current.*.partition)
  datadog_external_id = join("", datadog_integration_aws.integration.*.external_id)
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

# https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws
# https://docs.datadoghq.com/api/v1/aws-integration/
resource "datadog_integration_aws" "integration" {
  count                            = local.enabled ? 1 : 0
  account_id                       = local.aws_account_id
  role_name                        = module.this.id
  filter_tags                      = var.filter_tags
  host_tags                        = var.host_tags
  excluded_regions                 = var.excluded_regions
  account_specific_namespace_rules = var.account_specific_namespace_rules
  cspm_resource_collection_enabled = var.cspm_resource_collection_enabled
  metrics_collection_enabled       = var.metrics_collection_enabled
  resource_collection_enabled      = var.resource_collection_enabled
}

data "aws_iam_policy_document" "assume_role" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "DatadogAWSTrustRelationship"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:${local.aws_partition}:iam::${var.datadog_aws_account_id}:root"
      ]
    }

    condition {
      test = "StringEquals"
      values = [
        local.datadog_external_id
      ]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role" "default" {
  count              = local.enabled ? 1 : 0
  name               = module.this.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  tags               = module.this.tags
}

# https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#resource-collection
resource "aws_iam_role_policy_attachment" "security_audit" {
  count      = local.enabled && ((var.cspm_resource_collection_enabled != null ? var.cspm_resource_collection_enabled : false) || var.security_audit_policy_enabled) ? 1 : 0
  role       = join("", aws_iam_role.default.*.name)
  policy_arn = format("arn:%s:iam::aws:policy/SecurityAudit", local.aws_partition)
}

# https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#aws-resource-collection-iam-policy-1

data "aws_iam_policy_document" "resource_collection" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "DatadogResourceCollection"
    effect = "Allow"

    actions = [
      "backup:ListRecoveryPointsByBackupVault",
      "bcm-data-exports:GetExport",
      "bcm-data-exports:ListExports",
      "cassandra:Select",
      "cur:DescribeReportDefinitions",
      "ec2:GetSnapshotBlockPublicAccessState",
      "glacier:GetVaultNotifications",
      "glue:ListRegistries",
      "lightsail:GetInstancePortStates",
      "savingsplans:DescribeSavingsPlanRates",
      "savingsplans:DescribeSavingsPlans",
      "timestream:DescribeEndpoints",
      "waf-regional:ListRuleGroups",
      "waf-regional:ListRules",
      "waf:ListRuleGroups",
      "waf:ListRules",
      "wafv2:GetIPSet",
      "wafv2:GetRegexPatternSet",
      "wafv2:GetRuleGroup"
    ]

    resources = ["*"]
  }
}

module "resource_collection_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = compact(concat(module.this.attributes, ["resource-collection"]))

  context = module.this.context
}

locals {
  resource_collection_count = local.enabled && contains(split(",", lower(join(",", local.policies))), "resource-collection") ? 1 : 0
}

resource "aws_iam_policy" "resource_collection" {
  count  = local.resource_collection_count
  name   = module.resource_collection_label.id
  policy = join("", data.aws_iam_policy_document.resource_collection[*].json)
  tags   = module.resource_collection_label.tags
}

resource "aws_iam_role_policy_attachment" "resource_collection" {
  count      = local.resource_collection_count
  role       = join("", aws_iam_role.default[*].name)
  policy_arn = join("", aws_iam_policy.resource_collection[*].arn)
}

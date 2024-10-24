# https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#datadog-aws-iam-policy

# AWS Integration IAM Policy
data "aws_iam_policy_document" "all" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "DatadogAll"
    effect = "Allow"

    actions = [
      "apigateway:GET",
      "autoscaling:Describe*",
      "backup:List*",
      "budgets:ViewBudget",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:LookupEvents",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "codedeploy:BatchGet*",
      "codedeploy:List*",
      "directconnect:Describe*",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "ec2:Describe*",
      "ec2:GetTransitGatewayPrefixListReferences",
      "ec2:SearchTransitGatewayRoutes",
      "ecs:Describe*",
      "ecs:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:Describe*",
      "elasticmapreduce:List*",
      "es:DescribeElasticsearchDomains",
      "es:ListDomainNames",
      "es:ListTags",
      "events:CreateEventBus",
      "fsx:DescribeFileSystems",
      "fsx:ListTagsForResource",
      "health:DescribeAffectedEntities",
      "health:DescribeEventDetails",
      "health:DescribeEvents",
      "kinesis:Describe*",
      "kinesis:List*",
      "lambda:GetPolicy",
      "lambda:List*",
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:PutSubscriptionFilter",
      "logs:TestMetricFilter",
      "oam:ListAttachedLinks",
      "oam:ListSinks",
      "organizations:Describe*",
      "organizations:List*",
      "rds:Describe*",
      "rds:List*",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "route53:List*",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:ListAllMyBuckets",
      "s3:PutBucketNotification",
      "ses:Get*",
      "sns:GetSubscriptionAttributes",
      "sns:List*",
      "sns:Publish",
      "sqs:ListQueues",
      "states:DescribeStateMachine",
      "states:ListStateMachines",
      "support:DescribeTrustedAdvisor*",
      "support:RefreshTrustedAdvisorCheck",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "wafv2:GetLoggingConfiguration",
      "wafv2:ListLoggingConfigurations",
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries"
    ]

    resources = ["*"]
  }
}

module "all_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = compact(concat(module.this.attributes, ["all"]))

  context = module.this.context
}

locals {
  enabled       = var.enabled
  integrations  = split(",", lower(join(",", var.integrations)))
  all_count     = local.enabled && contains(local.integrations, "all") ? 1 : 0
  resource_collection_count = local.enabled && contains(local.integrations, "resource_collection") ? 1 : 0
}

resource "aws_iam_policy" "all" {
  count  = local.all_count
  name   = module.all_label.id
  policy = join("", data.aws_iam_policy_document.all.*.json)
  tags   = module.all_label.tags
}

resource "aws_iam_role_policy_attachment" "all" {
  count      = local.all_count
  role       = join("", aws_iam_role.default.*.name)
  policy_arn = join("", aws_iam_policy.all.*.arn)
}

# AWS Resource Collection IAM Policy
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

  attributes = compact(concat(module.this.attributes, ["resource_collection"]))

  context = module.this.context
}

resource "aws_iam_policy" "resource_collection" {
  count  = local.resource_collection_count
  name   = module.resource_collection_label.id
  policy = data.aws_iam_policy_document.resource_collection[0].json
  tags   = module.resource_collection_label.tags
}

resource "aws_iam_role_policy_attachment" "resource_collection" {
  count      = local.resource_collection_count
  role       = aws_iam_role.default[0].name
  policy_arn = aws_iam_policy.resource_collection[0].arn
}

# Attach AWS Managed SecurityAudit Policy for Resource Collection
resource "aws_iam_role_policy_attachment" "security_audit" {
  count      = local.resource_collection_count
  role       = aws_iam_role.default[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

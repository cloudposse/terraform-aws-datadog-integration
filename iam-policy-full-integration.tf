# https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#aws-integration-iam-policy
# https://datadog-cloudformation-template.s3.amazonaws.com/aws/datadog_integration_role.yaml

data "aws_iam_policy_document" "full_integration" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "DatadogFullIntegration"
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
      "codedeploy:List*",
      "codedeploy:BatchGet*",
      "directconnect:Describe*",
      "dynamodb:List*",
      "dynamodb:Describe*",
      "ec2:Describe*",
      "ec2:GetTransitGatewayPrefixListReferences",
      "ec2:SearchTransitGatewayRoutes",
      "ecs:Describe*",
      "ecs:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:List*",
      "elasticmapreduce:Describe*",
      "es:ListTags",
      "es:ListDomainNames",
      "es:DescribeElasticsearchDomains",
      "events:CreateEventBus",
      "fsx:DescribeFileSystems",
      "fsx:ListTagsForResource",
      "health:DescribeEvents",
      "health:DescribeEventDetails",
      "health:DescribeAffectedEntities",
      "kinesis:List*",
      "kinesis:Describe*",
      "lambda:GetPolicy",
      "lambda:List*",
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:PutSubscriptionFilter",
      "logs:TestMetricFilter",
      "oam:ListSinks",
      "oam:ListAttachedLinks",
      "organizations:Describe*",
      "organizations:List*",
      "rds:Describe*",
      "rds:List*",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "route53:List*",
      "s3:GetBucketLogging",
      "s3:GetBucketLocation",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:ListAllMyBuckets",
      "s3:PutBucketNotification",
      "ses:Get*",
      "sns:List*",
      "sns:Publish",
      "sns:GetSubscriptionAttributes",
      "sqs:ListQueues",
      "states:ListStateMachines",
      "states:DescribeStateMachine",
      "support:DescribeTrustedAdvisor*",
      "support:RefreshTrustedAdvisorCheck",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "wafv2:ListLoggingConfigurations",
      "wafv2:GetLoggingConfiguration",
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries"
    ]

    resources = ["*"]
  }
}

module "full_integration_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = compact(concat(module.this.attributes, ["full_integration"]))

  context = module.this.context
}

locals {
  full_integration_count = local.enabled && contains(split(",", lower(join(",", local.policies))), "full_integration") ? 1 : 0
}

resource "aws_iam_policy" "full_integration" {
  count  = local.full_integration_count
  name   = module.full_integration_label.id
  policy = join("", data.aws_iam_policy_document.full_integration[*].json)
  tags   = module.full_integration_label.tags
}

resource "aws_iam_role_policy_attachment" "full_integration" {
  count      = local.full_integration_count
  role       = join("", aws_iam_role.default[*].name)
  policy_arn = join("", aws_iam_policy.all[*].arn)
}

locals {
  enabled             = module.this.enabled
  aws_account_id      = join("", data.aws_caller_identity.current[*].account_id)
  aws_partition       = join("", data.aws_partition.current[*].partition)
  datadog_external_id = join("", datadog_integration_aws_external_id.integration[*].id)
  policies = distinct(concat(
    var.integrations != null ? var.integrations : [],
    var.policies
  ))
  effective_excluded_regions = var.excluded_regions == null ? [] : var.excluded_regions
  all_available_regions      = local.enabled && length(data.aws_regions.available) > 0 ? data.aws_regions.available[0].names : []

  included_regions_list = [
    for r in local.all_available_regions :
    r if !contains(local.effective_excluded_regions, r)
  ]
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_regions" "available" {
  count = local.enabled ? 1 : 0
}

# https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_account
# https://docs.datadoghq.com/api/v1/aws-integration/
resource "datadog_integration_aws_external_id" "integration" {
  count = local.enabled ? 1 : 0
}

resource "datadog_integration_aws_account" "integration" {
  count          = local.enabled ? 1 : 0
  aws_account_id = local.aws_account_id
  aws_partition  = local.aws_partition

  account_tags = var.host_tags

  dynamic "aws_regions" {
    for_each = [0] // Ensures the aws_regions block structure is always defined once
    content {
      // If no regions are excluded, set include_all = true. Otherwise, include_all will be null (and thus omitted).
      include_all = length(local.effective_excluded_regions) == 0 ? true : null

      // If regions are excluded, set include_only to the list. Otherwise, include_only will be null (and thus omitted).
      include_only = length(local.effective_excluded_regions) > 0 ? local.included_regions_list : null
    }
  }

  auth_config {
    aws_auth_config_role {
      role_name = module.this.id
    }
  }

  dynamic "metrics_config" {
    for_each = [0] // Always create this block as namespace_filters is required by the provider
    content {
      enabled                       = var.metrics_collection_enabled
      automute_enabled              = var.metrics_automute_enabled
      collect_cloudwatch_alarms     = var.metrics_collect_cloudwatch_alarms
      collect_custom_metrics        = var.metrics_collect_custom_metrics

      dynamic "tag_filters" {
        for_each = var.filter_tags != null && length(var.filter_tags) > 0 ? [
          {
            namespace = "*"
            tags      = var.filter_tags
          }
        ] : []
        content {
          namespace = tag_filters.value.namespace
          tags      = tag_filters.value.tags
        }
      }
      dynamic "namespace_filters" {
        for_each = [0]
        content {
          include_only = var.namespace_filters_include_only
          exclude_only = var.namespace_filters_exclude_only
        }
      }
    }
  }

  resources_config {
    extended_collection                          = var.extended_resource_collection_enabled ? true : false
    cloud_security_posture_management_collection = var.cspm_resource_collection_enabled ? true : false
  }

  // Required blocks without parameters left empty
  logs_config {
    lambda_forwarder {}
  }
  traces_config {
    xray_services {}
  }
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
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role[*].json)
  tags               = module.this.tags
}


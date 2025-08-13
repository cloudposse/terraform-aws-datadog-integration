locals {
  enabled             = module.this.enabled
  aws_account_id      = join("", data.aws_caller_identity.current[*].account_id)
  aws_partition       = join("", data.aws_partition.current[*].partition)
  datadog_external_id = join("", data.datadog_integration_aws_external_id.default[*].id)
  policies = distinct(concat(
    var.integrations != null ? var.integrations : [],
    var.policies
  ))
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

resource "datadog_integration_aws_external_id" "default" {
  count = local.enabled ? 1 : 0
}

# https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_account
# https://docs.datadoghq.com/api/v1/aws-integration/
resource "datadog_integration_aws_account" "integration" {
  count          = local.enabled ? 1 : 0
  aws_account_id = local.aws_account_id
  aws_partition  = local.aws_partition
  account_tags   = var.host_tags
  aws_regions {
    include_all = true
  }
  auth_config {
    aws_auth_config_role {
      # If role path is set to "/", the role name will be the same as the module name
      # If role path is set to something else, the role name will be the path + module name
      role_name   = (var.role_path == "/") ? module.this.id : "${var.role_path}${module.this.id}"
      external_id = local.datadog_external_id
    }
  }
  logs_config {
    lambda_forwarder {}
  }
  metrics_config {
    automute_enabled          = var.automute_enabled
    collect_cloudwatch_alarms = var.cloudwatch_alarms_enabled
    collect_custom_metrics    = var.custom_metric_enabled
    enabled                   = var.metrics_collection_enabled
    namespace_filters {
      include_only = var.namespaces
    }
    dynamic "tag_filters" {
      for_each = var.tag_filters
      content {
        namespace = tag_filters.value.key
        tags      = tag_filters.value.value
      }
    }
  }
  resources_config {
    cloud_security_posture_management_collection = var.cspm_resource_collection_enabled
    extended_collection                          = var.extended_resource_collection_enabled
  }
  traces_config {
    xray_services {
      include_only = var.xray_services
    }
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
  count                = local.enabled ? 1 : 0
  name                 = module.this.id
  assume_role_policy   = join("", data.aws_iam_policy_document.assume_role[*].json)
  tags                 = module.this.tags
  path                 = var.role_path
  permissions_boundary = var.role_permissions_boundary
}


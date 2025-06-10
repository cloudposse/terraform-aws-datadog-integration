variable "datadog_aws_account_id" {
  type        = string
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
}

variable "policies" {
  type        = list(string)
  description = <<-EOT
    List of Datadog's names for AWS IAM policies names to apply to the role.
    Valid options are "core-integration", "full-integration", "resource-collection", "CSPM", "SecurityAudit", "everything".
    "CSPM" is for Cloud Security Posture Management, which also requires "full-integration".
    "SecurityAudit" is for the AWS-managed `SecurityAudit` Policy.
    "everything" means all permissions for offerings.
    EOT
  validation {
    condition = alltrue([
      for policy in var.policies :
      contains([
        "core-integration",
        "full-integration",
        "resource-collection",
        "CSPM",
        "SecurityAudit",
        "everything"
      ], policy)
    ])
    error_message = "Invalid policy. Valid options are: core-integration, full-integration, resource-collection, CSPM, SecurityAudit, everything."
  }
  default = []
}

variable "filter_tags" {
  type = list(object({
    namespace = string
    tags      = list(string)
  }))
  description = "A list of objects containing namespace and tags to filter metrics collection. Each object should have a namespace and a list of tags in the form `key:value`."
  default     = null
}

variable "host_tags" {
  type        = list(string)
  description = "An array of tags (in the form `key:value`) to add to all hosts and metrics reporting through this integration"
  default     = null
}

variable "excluded_regions" {
  type        = list(string)
  default     = null
  description = "An array of AWS regions to exclude from metrics collection"
}

# DEPRECATED for datadog_integration_aws_account: This variable was used with the older datadog_integration_aws resource.
# For datadog_integration_aws_account, use namespace_filters_include_only or namespace_filters_exclude_only within metrics_config.
variable "account_specific_namespace_rules" {
  type        = map(string)
  default     = null
  description = "(DEPRECATED for new resource) An object, (in the form {\"namespace1\":true/false, \"namespace2\":true/false} ), that enables or disables metric collection for specific AWS namespaces for this AWS account only. For the datadog_integration_aws_account resource, use 'namespace_filters_include_only' or 'namespace_filters_exclude_only'."
}

variable "namespace_filters_include_only" {
  type        = list(string)
  default     = null
  description = "Include only these namespaces for metrics collection. Mutually exclusive with namespace_filters_exclude_only. Use 'datadog_integration_aws_available_namespaces' data source to discover available values."
}

variable "namespace_filters_exclude_only" {
  type        = list(string)
  default     = null
  description = "Exclude only these namespaces from metrics collection. Mutually exclusive with namespace_filters_include_only. If not set and include_only is not set, the provider defaults to excluding [\"AWS/SQS\", \"AWS/ElasticMapReduce\"] if the namespace_filters block is active. Use 'datadog_integration_aws_available_namespaces' data source to discover available values."
}

variable "cspm_resource_collection_enabled" {
  type        = bool
  default     = false
  description = "Whether Datadog collects cloud security posture management resources from your AWS account."
}

variable "metrics_collection_enabled" {
  type        = bool
  default     = null
  description = "Whether Datadog collects metrics for this AWS account. If null, the provider default is used if the metrics_config block is active."
}

variable "metrics_automute_enabled" {
  type        = bool
  default     = true
  description = "Enable EC2 automute for AWS metrics."
}

variable "metrics_collect_cloudwatch_alarms" {
  type        = bool
  default     = false
  description = "Enable CloudWatch alarms collection."
}

variable "metrics_collect_custom_metrics" {
  type        = bool
  default     = false
  description = "Enable custom metrics collection."
}

variable "extended_resource_collection_enabled" {
  type        = bool
  description = "Whether Datadog collects additional attributes and configuration information about the resources in your AWS account. Required for `cspm_resource_collection_enabled`."
  default     = true
}

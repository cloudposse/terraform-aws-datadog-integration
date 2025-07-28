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
  type        = list(string)
  description = "An array of EC2 tags (in the form `key:value`) that defines a filter that Datadog use when collecting metrics from EC2. Wildcards, such as ? (for single characters) and * (for multiple characters) can also be used"
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

variable "account_specific_namespace_rules" {
  type        = map(string)
  default     = null
  description = "An object, (in the form {\"namespace1\":true/false, \"namespace2\":true/false} ), that enables or disables metric collection for specific AWS namespaces for this AWS account only"
}

variable "cspm_resource_collection_enabled" {
  type        = bool
  default     = null
  description = "Whether Datadog collects cloud security posture management resources from your AWS account."
}

variable "metrics_collection_enabled" {
  type        = bool
  default     = null
  description = "Whether Datadog collects metrics for this AWS account."
}

variable "extended_resource_collection_enabled" {
  type        = bool
  description = "Whether Datadog collects additional attributes and configuration information about the resources in your AWS account. Required for `cspm_resource_collection_enabled`."
  default     = null
}

variable "namespaces" {
  type        = list(string)
  description = "An array of AWS namespaces to include in metrics collection"
  default     = null
}

variable "tag_filters" {
  type = list(object({
    key   = string
    value = string
  }))
  description = "An array of tag filters to apply to the metrics collection"
  default     = []
}

variable "xray_services" {
  type        = list(string)
  description = "An array of AWS X-Ray services to include in metrics collection"
  default     = null
}

variable "custom_metric_enabled" {
  type        = bool
  description = "Whether Datadog collects custom metrics for this AWS account."
  default     = null
}

variable "cloudwatch_alarms_enabled" {
  type        = bool
  description = "Whether Datadog collects CloudWatch alarms for this AWS account."
  default     = null
}

variable "automute_enabled" {
  type        = bool
  description = "Whether Datadog automutes CloudWatch alarms for this AWS account."
  default     = null
}

variable "role_path" {
  type        = string
  description = "The path to the IAM role"
  default     = "/"
}

variable "role_permissions_boundary" {
  type        = string
  description = "The ARN of the permissions boundary to use for the IAM role"
  default     = null

}

variable "policy_path" {
  type        = string
  description = "The path to the IAM policy"
  default     = "/"

}

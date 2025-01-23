variable "region" {
  type        = string
  description = "AWS region"
}

variable "datadog_aws_account_id" {
  type        = string
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
}

variable "policies" {
  type        = list(string)
  description = <<-EOT
    List of Datadog's names for AWS IAM policies names to apply to the role.
    Valid options are "core-integration", "full-integration", "resource-collection", "CSMP", "SecurityAudit", "everything".
    "CSMP" is for Cloud Security Posture Management, which also requires "full-integration".
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
        "CSMP",
        "SecurityAudit",
        "everything"
      ], policy)
    ])
    error_message = "Invalid policy. Valid options are: core-integration, full-integration, resource-collection, CSMP, SecurityAudit, everything."
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

variable "security_audit_policy_enabled" {
  type        = bool
  default     = false
  description = "Enable/disable attaching the AWS managed `SecurityAudit` policy to the Datadog IAM role to collect information about how AWS resources are configured (used in Datadog Cloud Security Posture Management to read security configuration metadata)"
}

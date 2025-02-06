
variable "integrations" {
  type        = list(string)
  description = <<-EOT
  DEPRECATED: Use the `policies` variable instead.
  List of AWS permission names to apply for different integrations (e.g. 'all', 'core')
  EOT
  default     = null
}

variable "resource_collection_enabled" {
  type        = bool
  description = <<-EOT
  DEPRECATED: Use the `extended_resource_collection_enabled` variables instead.
  Whether Datadog collects a standard set of resources from your AWS account.
  EOT
  default     = null
}

variable "security_audit_policy_enabled" {
  type        = bool
  description = <<-EOT
  DEPRECATED: Include `SecurityAudit` in the `policies` variable instead.
  Enable/disable attaching the AWS managed `SecurityAudit` policy to the Datadog IAM role to collect information about how AWS resources are configured (used in Datadog Cloud Security Posture Management to read security configuration metadata). If var.cspm_resource_collection_enabled, this is enabled automatically."
  EOT
  default     = null
}

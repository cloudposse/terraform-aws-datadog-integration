
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

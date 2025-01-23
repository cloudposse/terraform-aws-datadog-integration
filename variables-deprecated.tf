
variable "integrations" {
  type        = list(string)
  description = <<-EOT
  DEPRECATED: Use the `policies` variable instead.
  List of AWS permission names to apply for different integrations (e.g. 'all', 'core')"
  EOT
  default     = null
}


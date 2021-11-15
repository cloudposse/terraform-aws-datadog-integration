variable "datadog_aws_account_id" {
  type        = string
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
}

variable "enable_kinesis" {
  type        = bool
  description = "Enable Kinesis integration"
  default     = false
}

variable "kinesis_bucket_arn" {
  type        = string
  description = "ARN for kinesis retry bucket"
  default     = ""
}

variable "kinesis_api_key_ssm_parameter_name" {
  type = string
  description = "SSM param for Datadog api key to use for kinesis auth"
  default = ""
}

variable "kinesis_endpoint" {
  type        = string
  description = "Endpoint for kinesis"
  default     = "https://awsmetrics-intake.datadoghq.com/v1/input"
}

variable "integrations" {
  type        = list(string)
  description = "List of AWS permission names to apply for different integrations (e.g. 'all', 'core')"
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

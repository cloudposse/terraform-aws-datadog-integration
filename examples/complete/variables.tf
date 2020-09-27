variable "region" {
  type        = string
  description = "AWS region"
}

variable "datadog_aws_account_id" {
  type        = string
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
}

variable "datadog_api_key" {
  type        = string
  description = "Datadog API key"
}

variable "datadog_app_key" {
  type        = string
  description = "Datadog App key"
}

variable "integrations" {
  type        = list(string)
  description = "List of AWS permission names to apply for different integrations (e.g. 'all', 'core')"
}

variable "name" {
  type        = string
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
  default     = "datadog"
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "datadog_external_id" {
  type        = string
  description = "AWS External ID for this Datadog integration"
}

variable "datadog_aws_account_id" {
  type        = string
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
}

variable "integrations" {
  type        = list(string)
  description = "List of AWS permission names to apply for different integrations (`all`, `core`, `rds`)"
}


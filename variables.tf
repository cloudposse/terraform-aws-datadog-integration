variable "name" {
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
  default     = "datadog"
}

variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "datadog_external_id" {
  description = "External Id of the Datadog service"
}

variable "datadog_aws_account_id" {
  description = "Datadog’s AWS account ID"
  default     = "464622532012"
}

variable "integrations" {
  type        = "list"
  description = "List of AWS permission names to apply for different integrations (`all`, `core`, `rds`)"
}

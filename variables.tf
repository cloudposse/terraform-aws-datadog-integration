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

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `policy` or `role`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
}

variable "datadog_external_id" {
  description = "External Id of the DataDog service"
}

variable "datadog_aws_account_id" {
  description = "Datadog’s AWS account ID"
  default     = "464622532012"
}

variable "integrations" {
  type        = "list"
  description = "List of AWS integration permissions sets to apply (all, core, rds)"
}

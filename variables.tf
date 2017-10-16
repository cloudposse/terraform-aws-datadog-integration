variable "namespace" {}

variable "stage" {}

variable "name" {}

variable "delimiter" {
  default = "-"
}

variable "attributes" {
  type    = "list"
  default = []
}

variable "tags" {
  type = "map"
  default = {}
}

variable "datadog_external_id" {}

variable "datadog_aws_account_id" {
  default = "464622532012"
}

variable "integrations" {
  type = "list"
}

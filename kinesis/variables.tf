variable "datadog_api_key_ssm_parameter_name" {
  type = string
}

variable "backup_bucket_arn" {
  type        = string
  description = "Bucket for kinesis retries"
}

variable "datadog_metric_stream_namespace_list" {
  type    = list(string)
  default = []
}

variable "datadog_firehose_endpoint" {
  type = string

  validation {
    condition = contains([
      "https://awsmetrics-intake.datadoghq.com/v1/input",
      "https://awsmetrics-intake.datadoghq.eu/v1/input",
    ], var.datadog_firehose_endpoint)

    error_message = "Invalid Datadog Kinesis Firehose endpoint."
  }
}

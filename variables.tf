variable "datadog_aws_account_id" {
  type        = string
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
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

variable "subnet_ids" {
  description = "List of subnet IDs to use when running in a specific VPC."
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs used when Lambda Function should run in the VPC"
  type        = list(string)
  default     = null
}

#https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
variable "lambda_reserved_concurrent_executions" {
  type        = number
  description = "Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1."
  default     = -1
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime environment for Datadog lambda."
  default     = "python3.7"
}

variable "tracing_config_mode" {
  type        = string
  description = "Can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service."
  default     = "PassThrough"
}

variable "dd_api_key_source" {
  description = "One of: ARN for AWS Secrets Manager (asm) to retrieve the Datadog (DD) api key, ARN for the KMS (kms) key used to decrypt the ciphertext_blob of the api key, or the name of the SSM (ssm) parameter used to retrieve the Datadog API key."
  type = object({
    resource   = string
    identifier = string
  })

  default = {
    resource   = ""
    identifier = ""
  }

  # Resource can be one of kms, asm, ssm ("" to disable all lambda resources)
  validation {
    condition     = can(regex("(kms|asm|ssm)", var.dd_api_key_source.resource)) || var.dd_api_key_source.resource == ""
    error_message = "Provide one, and only one, ARN for (kms, asm) or name (ssm) to retrieve or decrypt Datadog api key."
  }

  # Check KMS ARN format
  validation {
    condition     = var.dd_api_key_source.resource == "kms" ? can(regex("arn:aws:kms:.*:key/.*", var.dd_api_key_source.identifier)) : true
    error_message = "ARN for KMS key does not appear to be valid format (example: arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab)."
  }

  # Check ASM ARN format
  validation {
    condition     = var.dd_api_key_source.resource == "asm" ? can(regex("arn:aws:secretsmanager:.*:secret:.*", var.dd_api_key_source.identifier)) : true
    error_message = "ARN for AWS Secrets Manager (asm) does not appear to be valid format (example: arn:aws:secretsmanager:us-west-2:111122223333:secret:aes128-1a2b3c)."
  }

  # Check SSM name format
  validation {
    condition     = var.dd_api_key_source.resource == "ssm" ? can(regex("^[a-zA-Z0-9_./-]+$", var.dd_api_key_source.identifier)) : true
    error_message = "Name for SSM parameter does not appear to be valid format, acceptable characters are `a-zA-Z0-9_.-` and `/` to delineate hierarchies."
  }
}

variable "dd_api_key_kms_ciphertext_blob" {
  type        = string
  description = "CiphertextBlob stored in environment variable DD_KMS_API_KEY used by the lambda function, along with the KMS key, to decrypt Datadog API key"
  default     = ""
}

variable "dd_artifact_filename" {
  type        = string
  description = "The Datadog artifact filename minus extension"
  default     = "aws-dd-forwarder"
}

variable "dd_module_name" {
  type        = string
  description = "The Datadog GitHub repository name"
  default     = "datadog-serverless-functions"
}

variable "dd_artifact_url" {
  type        = string
  description = "The URL template to format the full URL to the Datadog zip artifact"
  default     = "https://github.com/DataDog/$$${module_name}/releases/download/%v-$$${git_ref}/$$${filename}"
}

variable "dd_forwarder_version" {
  type        = string
  description = "Version tag of datadog lambdas to use. https://github.com/DataDog/datadog-serverless-functions/releases"
  default     = "3.34.0"
}

variable "forwarder_log_enabled" {
  type        = bool
  description = "Enable to add Datadog log forwarder"
  default     = false
}

variable "forwarder_rds_enabled" {
  type        = bool
  description = "Enable to add Datadog RDS enhanced monitoring forwarder"
  default     = false
}

variable "forwarder_vpc_enabled" {
  type        = bool
  description = "Enable to add Datadog VPC flow log forwarder"
  default     = false
}

variable "forwarder_log_retention_days" {
  type        = number
  description = "Number of days to retain Datadog forwarder lambda execution logs. One of [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653]"
  default     = 14
}

variable "kms_key_id" {
  type        = string
  description = "Optional KMS key ID to encrypt Datadog lambda function logs"
  default     = null
}

variable "s3_bucket_arns" {
  type        = map(string)
  description = "ARN of the Cloudtrail S3 bucket"
  default     = {}
}

variable "s3_bucket_kms_arns" {
  type        = list(string)
  description = "List of KMS ARNs for log decryption"
  default     = []
}

variable "cloudwatch_forwarder_log_groups" {
  type        = map(string)
  description = "List of cloudwatch log groups that the lambda forwarder will send logs from"
  default     = {}
}

variable "forwarder_lambda_debug_enabled" {
  type        = bool
  description = "Whether to enable or disable debug for the lambda forwarder"
  default     = false
}

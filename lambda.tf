######################################################################
## https://docs.datadoghq.com/integrations/amazon_rds/?tab=enhanced
##
## TODO 
#   - Move variables to variables.tf???
#   - Watch https://github.com/hashicorp/terraform/issues/15469 for future validation/error checking (variable validation can currently only reference itself)

variable "subnet_ids" {
  description = "List of subnets to use when running in specific VPC."
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime environment for Datadog lambda"
  default     = "python3.7"
}

variable "tracing_config_mode" {
  type        = string
  description = "Can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service."
  default     = "PassThrough"
}

variable "dd_api_key_source" {
  description = "One of: ARN for AWS Secrets Manager (asm) to retrieve the Datadog (DD) api key, ARN for the KMS (kms) key used to decrypt the ciphertext_blob of the api key, or the name of the SSM (ssm) parameter used to retrieve the DD api key."
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

  # Check kms arn format
  validation {
    condition     = var.dd_api_key_source.resource == "kms" ? can(regex("arn:aws:kms:.*:key/.*", var.dd_api_key_source.identifier)) : true
    error_message = "ARN for KMS key does not appear to be valid format (example: arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab)."
  }

  # Check asm arn format 
  validation {
    condition     = var.dd_api_key_source.resource == "asm" ? can(regex("arn:aws:secretsmanager:.*:secret:.*", var.dd_api_key_source.identifier)) : true
    error_message = "ARN for AWS Secrets Manager (asm) does not appear to be valid format (example: arn:aws:secretsmanager:us-west-2:111122223333:secret:aes128-1a2b3c)."
  }

  # Check ssm name format
  validation {
    condition     = var.dd_api_key_source.resource == "ssm" ? can(regex("^[a-zA-Z0-9_./-]+$", var.dd_api_key_source.identifier)) : true
    error_message = "Name for SSM parameter does not appear to be valid format, acceptable characters are a-zA-Z0-9_.- and / to delineate hierarchies."
  }
}

variable "dd_api_key_kms_ciphertext_blob" {
  type        = string
  description = "CiphertextBlob stored in enironment variable DD_KMS_API_KEY used by the lambda function, along with the kms key, to decrypt Datadog API key."
  default     = ""
}

locals {
  lambda_enabled         = var.dd_api_key_source.resource != "" ? true : false
  dd_api_key_resource    = var.dd_api_key_source.resource
  dd_api_key_identifier  = var.dd_api_key_source.identifier
  dd_api_key_arn         = local.dd_api_key_resource == "ssm" ? data.aws_ssm_parameter.api_key[0].arn : local.dd_api_key_identifier
  dd_api_key_iam_actions = [lookup({ kms = "kms:Decrypt", asm = "secretsmanager:GetSecretValue", ssm = "ssm:GetParameters" }, local.dd_api_key_resource, "")]
}

data "aws_ssm_parameter" "api_key" {
  count = local.dd_api_key_resource == "ssm" ? 1 : 0
  name  = local.dd_api_key_identifier
}

######################################################################
## Create base assume policy and lambda role

data "aws_iam_policy_document" "assume" {
  count = local.lambda_enabled ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "lambda" {
  count = local.lambda_enabled ? 1 : 0

  name               = module.this.id
  assume_role_policy = data.aws_iam_policy_document.assume[0].json
  tags               = module.this.tags
}

######################################################################
## Create lambda logging and secret policy then attach to base lambda role

data "aws_iam_policy_document" "lambda" {
  count = local.lambda_enabled ? 1 : 0

  statement {
    sid = "WriteLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    sid = "GetApiKey"

    effect = "Allow"

    actions = local.dd_api_key_iam_actions

    resources = [local.dd_api_key_arn]
  }

}

resource "aws_iam_policy" "lambda" {
  count = local.lambda_enabled ? 1 : 0

  name        = module.this.id
  description = "Allow put logs and access to DD api key"
  policy      = data.aws_iam_policy_document.lambda[0].json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count = local.lambda_enabled ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.lambda[0].arn
}

######################################################################
## Get DD lambda zip artifact
## https://github.com/DataDog/datadog-serverless-functions/releases
## TODO move variables to variables.tf???

variable "dd_artifact_filename" {
  type        = string
  description = "The datadog artifact filename minus extension."
  default     = "aws-dd-forwarder"
}

variable "dd_module_name" {
  type        = string
  description = "The Datadog github repository name."
  default     = "datadog-serverless-functions"
}
variable "dd_git_ref" {
  type        = string
  description = "The version of the Datadog artifact zip file."
  default     = "3.31.0"
}

variable "dd_artifact_url" {
  type        = string
  description = "The url template to format the full url to the Datadog zip artifact."
  # I don't like mixing format with template, I also don't want to create too much nesting in template string which might cause some to miss it if the modify it
  default = "https://github.com/DataDog/$$${module_name}/releases/download/%v-$$${git_ref}/$$${filename}"
}

locals {
  url      = format(var.dd_artifact_url, var.dd_artifact_filename)
  filename = format("%v-%v.zip", var.dd_artifact_filename, var.dd_git_ref)
}

module "artifact" {
  count = local.lambda_enabled ? 1 : 0

  source      = "cloudposse/module-artifact/external"
  version     = "0.7.0"
  filename    = local.filename
  module_name = var.dd_module_name
  module_path = path.module
  git_ref     = var.dd_git_ref
  url         = local.url
}

######################################################################
## Create lambda function

# Lambda env vars locals 
locals {
  dd_api_key_kms = local.dd_api_key_resource == "kms" ? { DD_KMS_API_KEY = var.dd_api_key_kms_ciphertext_blob } : {}
  dd_api_key_asm = local.dd_api_key_resource == "asm" ? { DD_API_KEY_SECRET_ARN = local.dd_api_key_identifier } : {}
  dd_api_key_ssm = local.dd_api_key_resource == "ssm" ? { DD_API_KEY_SSM_NAME = local.dd_api_key_identifier } : {}
  lambda_env     = merge(local.dd_api_key_kms, local.dd_api_key_asm, local.dd_api_key_ssm)
}

resource "aws_lambda_function" "default" {
  count = local.lambda_enabled ? 1 : 0

  description      = "Datadog forwarder for RDS enhanced monitoring"
  filename         = module.artifact[0].file
  function_name    = module.this.id
  role             = aws_iam_role.lambda[0].arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = module.artifact[0].base64sha256
  runtime          = var.lambda_runtime
  tags             = module.this.tags

  dynamic "vpc_config" {
    for_each = var.subnet_ids != null && var.security_group_ids != null ? [true] : []
    content {
      security_group_ids = var.security_group_ids
      subnet_ids         = var.subnet_ids
    }
  }

  environment {
    variables = local.lambda_env
  }

  tracing_config {
    mode = var.tracing_config_mode
  }
}

output "lambda_function_id" {
  value = length(aws_lambda_function.default) > 0 ? aws_lambda_function.default[0].id : null
}

output "lambda_iam_role_id" {
  value = length(aws_iam_role.lambda) > 0 ? aws_iam_role.lambda[0].id : null
}

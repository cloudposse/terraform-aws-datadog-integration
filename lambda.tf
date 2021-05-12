######################################################################
## https://docs.datadoghq.com/integrations/amazon_rds/?tab=enhanced
##
## TODO 
#   - Add some type of enabling feature flag for rds enahnced metrics
#   - Move variables to variables.tf
#   - Watch https://github.com/hashicorp/terraform/issues/15469 for future validation/error checking (variable validation can currently only reference itself)

variable "subnet_ids" {
  description = "List of subnets to use when running in specific VPC"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

variable "tracing_config_mode" {
  type        = string
  description = "Can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service."
  default     = "PassThrough"
}

variable "dd_api_key_source" {
  description = "ARN (kms or asm) or parameter name (for ssm) to retrieve Datadog api key."
  type = object({
    kms = string # kms key arn
    asm = string # asm secret arn
    ssm = string # paramater name
  })

  default = {
    kms = ""
    asm = ""
    ssm = ""
  }

  validation {
    condition     = length(compact(values(var.dd_api_key_source))) == 1
    error_message = "Provide only one ARN (kms or asm) or parameter name (for ssm) to retrieve Datadog api key."
  }
}

variable "dd_api_key_kms_ciphertext_blob" {
  default = ""
}

data "aws_ssm_parameter" "api_key" {
  count = local.dd_api_key_resource == "ssm" ? 1 : 0
  name  = local.dd_api_key_identifier
}

locals {
  dd_api_key_source = {
    for k, v in var.dd_api_key_source :
    k => v if v != ""
  }
  dd_api_key_resource    = keys(local.dd_api_key_source)[0]
  dd_api_key_identifier  = values(local.dd_api_key_source)[0]
  dd_api_key_arn         = local.dd_api_key_resource == "ssm" ? data.aws_ssm_parameter.api_key[0].arn : local.dd_api_key_identifier
  dd_api_key_iam_actions = [lookup({ kms = "kms:Decrypt", asm = "secretsmanager:GetSecretValue", ssm = "ssm:GetParameters" }, local.dd_api_key_resource, "")]
}

######################################################################
## Create base assume policy and lambda role

data "aws_iam_policy_document" "assume" {
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
  name               = "lambda" # module.this.id
  assume_role_policy = data.aws_iam_policy_document.assume.json
  # tags               = module.this.tags
}

######################################################################
## Create lambda logging and secret policy then attach to base lambda role

# TODO review DD specific reqs 
# https://github.com/DataDog/datadog-serverless-functions/blob/cb0e7965636a3ea613325d2d4624926600a436c0/aws/logs_monitoring/template.yaml
data "aws_iam_policy_document" "lambda" {

  statement {
    sid = "WriteLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      # I think these are only needed for other DD lambda forwarder types 
      # https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html#vpc-permissions
      # https://github.com/DataDog/datadog-serverless-functions/blob/cb0e7965636a3ea613325d2d4624926600a436c0/aws/logs_monitoring/template.yaml#L553-L560
      # "ec2:CreateNetworkInterface",
      # "ec2:DescribeNetworkInterfaces",
      # "ec2:DeleteNetworkInterface"
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
  name        = "lambda" # module.this.id
  description = "Allow put logs and access to DD api key"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

######################################################################
## Get DD lambda zip artifact
## https://github.com/DataDog/datadog-serverless-functions/releases
## TODO move variables to variables.tf

variable "dd_artifact_filename" {
  default = "aws-dd-forwarder"
}

variable "dd_module_name" {
  default = "datadog-serverless-functions"
}
variable "dd_git_ref" {
  default = "3.31.0"
}

variable "dd_artifact_url" {
  # I don't like mixing format with template, I also don't want to create too much nesting in template string which might cause some to miss it if the modify it
  default = "https://github.com/DataDog/$$${module_name}/releases/download/%v-$$${git_ref}/$$${filename}"
}

locals {
  url      = format(var.dd_artifact_url, var.dd_artifact_filename)
  filename = format("%v-%v.zip", var.dd_artifact_filename, var.dd_git_ref)
}

module "artifact" {
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
  description      = "Datadog forwarder for RDS enhanced monitoring"
  filename         = module.artifact.file
  function_name    = "datadog" # module.this.id
  role             = aws_iam_role.lambda.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = module.artifact.base64sha256
  runtime          = "python3.7" # var.lambda_runtime
  # tags             = module.this.tags

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

output "lambda_env" {
  value = local.lambda_env
}

output "aws_iam_policy_document" {
  value = data.aws_iam_policy_document.lambda.json
}

######################################################################
## https://docs.datadoghq.com/integrations/amazon_rds/?tab=enhanced

locals {
  lambda_enabled         = module.this.enabled && var.dd_api_key_source.resource != "" ? true : false
  dd_api_key_resource    = var.dd_api_key_source.resource
  dd_api_key_identifier  = var.dd_api_key_source.identifier
  dd_api_key_arn         = local.dd_api_key_resource == "ssm" ? data.aws_ssm_parameter.api_key[0].arn : local.dd_api_key_identifier
  dd_api_key_iam_actions = [lookup({ kms = "kms:Decrypt", asm = "secretsmanager:GetSecretValue", ssm = "ssm:GetParameters" }, local.dd_api_key_resource, "")]
  url                    = format(var.dd_artifact_url, var.dd_artifact_filename)
  filename               = format("%v-%v.zip", var.dd_artifact_filename, var.dd_git_ref)
  dd_api_key_kms         = local.dd_api_key_resource == "kms" ? { DD_KMS_API_KEY = var.dd_api_key_kms_ciphertext_blob } : {}
  dd_api_key_asm         = local.dd_api_key_resource == "asm" ? { DD_API_KEY_SECRET_ARN = local.dd_api_key_identifier } : {}
  dd_api_key_ssm         = local.dd_api_key_resource == "ssm" ? { DD_API_KEY_SSM_NAME = local.dd_api_key_identifier } : {}
  lambda_env             = merge(local.dd_api_key_kms, local.dd_api_key_asm, local.dd_api_key_ssm)
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
  description = "Allow put logs and access to DD api key."
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

resource "aws_lambda_function" "default" {
  count = local.lambda_enabled ? 1 : 0

  description      = "Datadog forwarder for RDS enhanced monitoring."
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

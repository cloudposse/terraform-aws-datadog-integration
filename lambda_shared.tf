######################################################################
## https://docs.datadoghq.com/integrations/amazon_rds/?tab=enhanced

locals {
  lambda_enabled         = module.this.enabled ? (var.forwarder_log_enabled || var.forwarder_rds_enabled || var.forwarder_vpc_enabled ? true : false) : false
  dd_api_key_resource    = var.dd_api_key_source.resource
  dd_api_key_identifier  = var.dd_api_key_source.identifier
  dd_api_key_arn         = local.dd_api_key_resource == "ssm" ? join("", data.aws_ssm_parameter.api_key.*.arn) : local.dd_api_key_identifier
  dd_api_key_iam_actions = [lookup({ kms = "kms:Decrypt", asm = "secretsmanager:GetSecretValue", ssm = "ssm:GetParameter" }, local.dd_api_key_resource, "")]
  dd_api_key_kms         = local.dd_api_key_resource == "kms" ? { DD_KMS_API_KEY = var.dd_api_key_kms_ciphertext_blob } : {}
  dd_api_key_asm         = local.dd_api_key_resource == "asm" ? { DD_API_KEY_SECRET_ARN = local.dd_api_key_identifier } : {}
  dd_api_key_ssm         = local.dd_api_key_resource == "ssm" ? { DD_API_KEY_SSM_NAME = local.dd_api_key_identifier } : {}
  lambda_env             = merge(local.dd_api_key_kms, local.dd_api_key_asm, local.dd_api_key_ssm)

}

# Log Forwarder, RDS Enhanced Forwarder, VPC Flow Log Forwarder

data "aws_ssm_parameter" "api_key" {
  count = local.lambda_enabled && local.dd_api_key_resource == "ssm" ? 1 : 0
  name  = local.dd_api_key_identifier
}

module "lambda_label" {
  source     = "cloudposse/label/null"
  version    = "0.24.1" # requires Terraform >= 0.13.0
  attributes = ["forwarder-lambda"]

  context = module.this.context
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

  name               = module.lambda_label.id
  assume_role_policy = data.aws_iam_policy_document.assume[0].json
  tags               = module.lambda_label.tags
}

######################################################################
## Create lambda logging and secret policy then attach to base lambda role

data "aws_iam_policy_document" "lambda" {
  count = local.lambda_enabled ? 1 : 0

  # #checkov:skip=BC_AWS_IAM_57: (Pertaining to contstraining IAM write access) This policy has not write access and is restricted to one specific ARN.

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

  name        = module.lambda_label.id
  description = "Allow put logs and access to Datadog api key."
  policy      = data.aws_iam_policy_document.lambda[0].json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count = local.lambda_enabled ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.lambda[0].arn
}

variable "artifact_url" {
  type        = string
  description = "URL template for the remote artifact"
  #default     = "https://artifacts.cloudposse.com/$$${module_name}/$$${git_ref}/$$${filename}"
  default     = "https://github.com/DataDog/$$${module_name}/releases/download/$$${filename}-$$${git_ref}/$$${filename}-$$${git_ref}.zip"
}

variable "artifact_filename" {
  default = "aws-dd-forwarder"
}

locals {
  api_key_actions   = ["kms:Decrypt", "secretsmanager:GetSecretValue", "ssm:GetParameter"]
  api_key_resources = ["<KMS ARN>"]
  api_key_env_var   = {}
}

# # Recommended: AWS KMS
# kms DD_KMS_API_KEY

# # AWS Secrets Manager
# DD_API_KEY_SECRET_ARN

# # AWS SSM
# DD_API_KEY_SSM_NAME

# # # Not Recommended: Plaintext
# # DD_API_KEY

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
  name               = module.this.id
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = module.this.tags
}

data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid = "GetApiKey"

    effect = "Allow"

    actions = local.api_key_actions
      
    resources = local.api_key_resources
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = ["${aws_s3_bucket.default.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda" {
  name        = module.this.id
  description = "Allow put logs"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

module "artifact" {
  source      = "cloudposse/module-artifact/external"
  version     = "0.7.0"
  filename    = var.artifact_filename
  module_name = "datadog-serverless-functions"
  module_path = path.module
  url         = var.artifact_url
}

resource "aws_lambda_function" "default" {
  filename         = module.artifact.file
  function_name    = module.this.id
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  source_code_hash = module.artifact.base64sha256
  runtime          = var.lambda_runtime
  tags             = module.this.tags

  environment {
    variables = merge(local.api_key_env_var, {})
  }

  tracing_config {
    mode = var.tracing_config_mode
  }
}

resource "aws_lambda_alias" "default" {
  name             = "default"
  description      = "Use latest version as default"
  function_name    = aws_lambda_function.default.function_name
  function_version = "$LATEST"
}




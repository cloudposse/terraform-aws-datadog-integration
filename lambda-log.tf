locals {
  aws_cloudtrail_bucket_arn = "arn:aws:s3:::${var.aws_cloudtrail_bucket_name}"
}

module "forwarder_log_label" {
  source     = "cloudposse/label/null"
  version    = "0.24.1" # requires Terraform >= 0.13.0
  attributes = ["forwarder-log"]

  context = module.this.context
}

module "forwarder_log" {
  count = local.lambda_enabled && var.forwarder_log_enabled ? 1 : 0

  source      = "cloudposse/module-artifact/external"
  version     = "0.7.0"
  filename    = "forwarder-log.zip"
  module_name = var.dd_module_name
  module_path = path.module
  url         = "https://github.com/DataDog/datadog-serverless-functions/releases/download/aws-dd-forwarder-${var.dd_forwarder_version}/aws-dd-forwarder-${var.dd_forwarder_version}.zip"
}

######################################################################
## Create lambda function

resource "aws_lambda_function" "forwarder_log" {
  count = local.lambda_enabled && var.forwarder_log_enabled ? 1 : 0

  #checkov:skip=BC_AWS_GENERAL_64: (Pertaining to Lambda DLQ) Vendor lambda does not have a means to reprocess failed events.

  description                    = "Datadog forwarder for log forwarding."
  filename                       = module.forwarder_log[0].file
  function_name                  = module.forwarder_log_label.id
  role                           = aws_iam_role.lambda[0].arn
  handler                        = "lambda_function.lambda_handler"
  source_code_hash               = module.forwarder_log[0].base64sha256
  runtime                        = var.lambda_runtime
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  tags                           = module.forwarder_log_label.tags

  dynamic "vpc_config" {
    for_each = try(length(var.subnet_ids), 0) > 0 && try(length(var.security_group_ids), 0) > 0 ? [true] : []
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

resource "aws_lambda_permission" "allow_bucket" {
  count = local.lambda_enabled && var.forwarder_log_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.forwarder_log[0].arn
  principal     = "s3.amazonaws.com"
  source_arn    = local.aws_cloudtrail_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count = local.lambda_enabled && var.forwarder_log_enabled ? 1 : 0
  bucket = var.aws_cloudtrail_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.forwarder_log[0].arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

data "aws_iam_policy_document" "cloudtrail_log_bucket" {
  count = local.lambda_enabled && var.forwarder_log_enabled ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListObjects",
    ]

    resources = [
      local.aws_cloudtrail_bucket_arn,
      "${local.aws_cloudtrail_bucket_arn}/*",
    ]
  }

  dynamic "statement" {
    for_each = try(length(var.aws_cloudtrail_kms_arns), 0) > 0 ? [true] : []
    content {
      effect = "Allow"

      actions = [
        "kms:Decrypt"
      ]

      resources = var.aws_cloudtrail_kms_arns
    }
  }
}

resource "aws_iam_policy" "datadog_cloudtrail" {
  count       = local.lambda_enabled && var.forwarder_log_enabled ? 1 : 0
  name        = module.forwarder_log_label.id
  description = "Policy for Datadog Cloudtrail integration"
  policy      = join("", data.aws_iam_policy_document.cloudtrail_log_bucket.*.json)
}

resource "aws_iam_role_policy_attachment" "datadog_cloudtrail" {
  count      = local.lambda_enabled && var.forwarder_log_enabled ? 1 : 0
  role       = join("", aws_iam_role.lambda.*.name)
  policy_arn = join("", aws_iam_policy.datadog_cloudtrail.*.arn)
}

resource "aws_cloudwatch_log_group" "forwarder_log" {
  count = local.lambda_enabled && var.forwarder_log_enabled ? 1 : 0

  name              = "/aws/lambda/${aws_lambda_function.forwarder_log[0].function_name}"
  retention_in_days = var.forwarder_log_retention_days

  kms_key_id = var.kms_key_id

  tags = module.forwarder_log_label.tags
}

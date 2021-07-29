module "forwarder_vpclogs_label" {
  source     = "cloudposse/label/null"
  version    = "0.24.1" # requires Terraform >= 0.13.0
  attributes = ["forwarder-vpclogs"]

  context = module.this.context
}

module "forwarder_vpclogs" {
  count = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0

  source      = "cloudposse/module-artifact/external"
  version     = "0.7.0"
  filename    = "forwarder-logs.py"
  module_name = var.dd_module_name
  module_path = path.module
  url         = "https://raw.githubusercontent.com/DataDog/datadog-serverless-functions/master/aws/vpc_flow_log_monitoring/lambda_function.py?ref=${var.dd_forwarder_version}"
}

data "archive_file" "forwarder_vpclogs" {
  count       = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0
  type        = "zip"
  source_file = module.forwarder_vpclogs[0].file
  output_path = "${path.module}/lambda.zip"
}

######################################################################
## Create lambda function

resource "aws_lambda_function" "forwarder_vpclogs" {
  count = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0

  #checkov:skip=BC_AWS_GENERAL_64: (Pertaining to Lambda DLQ) Vendor lambda does not have a means to reprocess failed events.

  description                    = "Datadog forwarder for RDS enhanced monitoring."
  filename                       = data.archive_file.forwarder_vpclogs[0].output_path
  function_name                  = module.forwarder_vpclogs_label.id
  role                           = aws_iam_role.lambda[0].arn
  handler                        = "lambda_function.lambda_handler"
  source_code_hash               = data.archive_file.forwarder_vpclogs[0].output_base64sha256
  runtime                        = var.lambda_runtime
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  tags                           = module.forwarder_vpclogs_label.tags

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

resource "aws_lambda_permission" "allow_s3_bucket_vpclogs" {
  count         = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.forwarder_vpclogs[0].arn
  principal     = "s3.amazonaws.com"
  source_arn    = each.value
}

resource "aws_s3_bucket_notification" "s3_bucket_notification_vpclogs" {
  count  = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0
  bucket = each.key

  lambda_function {
    lambda_function_arn = aws_lambda_function.forwarder_vpclogs[0].arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_bucket]
}

data "aws_iam_policy_document" "s3_log_bucket_vpclogs" {
  count = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListObjects",
    ]

    resources = [
      var.vpc_flowlogs_bucket_name,
      "${var.vpc_flowlogs_bucket_name}/*",
    ]
  }

  dynamic "statement" {
    for_each = try(length(var.vpc_flowlogs_bucket_kms_arns), 0) > 0 ? [true] : []
    content {
      effect = "Allow"

      actions = [
        "kms:Decrypt"
      ]

      resources = var.var.vpc_flowlogs_bucket_kms_arns
    }
  }
}

resource "aws_iam_policy" "datadog_s3_vpclogs" {
  count       = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0
  name        = module.forwarder_log_label[0].id
  description = "Policy for Datadog S3 integration"
  policy      = join("", data.aws_iam_policy_document.s3_log_bucket_vpclogs.*.json)
}

resource "aws_iam_role_policy_attachment" "datadog_s3_vpclogs" {
  count      = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0
  role       = join("", aws_iam_role.lambda.*.name)
  policy_arn = join("", aws_iam_policy.datadog_s3_vpclogs.*.arn)
}

resource "aws_cloudwatch_log_group" "forwarder_vpclogs" {

  count = local.lambda_enabled && var.forwarder_vpc_logs_enabled ? 1 : 0

  name              = "/aws/lambda/${aws_lambda_function.forwarder_vpclogs[0].function_name}"
  retention_in_days = var.forwarder_log_retention_days

  kms_key_id = var.kms_key_id

  tags = module.forwarder_vpclogs_label.tags
}

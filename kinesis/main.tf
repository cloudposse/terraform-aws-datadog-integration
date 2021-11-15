# significant inspiration from the following sources:
# https://github.com/magnetikonline/terraform-aws-datadog-metric-stream

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "datadog_api_key" {
  name = var.datadog_api_key_ssm_parameter_name
}

locals {
  backup_bucket_arn = var.backup_bucket_arn
  datadog_api_key = data.aws_ssm_parameter.datadog_api_key.value
}

## Kinesis Firehose
resource "aws_kinesis_firehose_delivery_stream" "datadog" {
  name        = "datadog"
  destination = "http_endpoint"

  http_endpoint_configuration {
    name               = module.this.id
    access_key         = local.datadog_api_key
    buffering_interval = 60 # seconds
    buffering_size     = 4  # MB
    retry_duration     = 60 # seconds
    role_arn           = aws_iam_role.datadog_firehose.arn
    s3_backup_mode     = "FailedDataOnly"
    url                = var.datadog_firehose_endpoint

    cloudwatch_logging_options {
      enabled = false
    }

    processing_configuration {
      enabled = false
    }

    request_configuration {
      content_encoding = "GZIP"
    }
  }

  s3_configuration {
    bucket_arn      = local.backup_bucket_arn
    buffer_interval = 300 # seconds
    buffer_size     = 5   # MB
    prefix          = "metrics/"
    role_arn        = aws_iam_role.datadog_firehose.arn

    cloudwatch_logging_options {
      enabled = false
    }
  }

  server_side_encryption {
    enabled = false
  }
}

# IAM policies and role
data "aws_iam_policy_document" "metrics_sts" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["streams.metrics.cloudwatch.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "stream" {
  name               = module.this.id
  assume_role_policy = data.aws_iam_policy_document.metrics_sts.json
}

data "aws_iam_policy_document" "firehose_delivery" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]

    resources = [aws_kinesis_firehose_delivery_stream.datadog.arn]
  }
}

data "aws_iam_policy_document" "firehose_sts" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["firehose.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "datadog_firehose_s3_backup" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [local.backup_bucket_arn]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["${local.backup_bucket_arn}/*"]
  }
}

## CloudWatch metric stream
resource "aws_cloudwatch_metric_stream" "datadog" {
  name          = module.this.id
  firehose_arn  = aws_kinesis_firehose_delivery_stream.datadog.arn
  output_format = "opentelemetry0.7"
  role_arn      = aws_iam_role.stream.arn

  dynamic "include_filter" {
    for_each = var.datadog_metric_stream_namespace_list
    iterator = item

    content {
      namespace = item.value
    }
  }
}

resource "aws_iam_role_policy" "firehose_delivery" {
  name   = "firehose"
  policy = data.aws_iam_policy_document.firehose_delivery.json
  role   = aws_iam_role.datadog_metric_stream.id
}

resource "aws_iam_role" "datadog_firehose" {
  name               = "datadog-firehose"
  assume_role_policy = data.aws_iam_policy_document.firehose_sts.json
}

resource "aws_iam_role_policy" "datadog_firehose_s3_backup" {
  name   = "s3-backup"
  policy = data.aws_iam_policy_document.datadog_firehose_s3_backup.json
  role   = aws_iam_role.datadog_firehose.id
}

## Kinesis Firehose - S3 error/backup bucket
resource "aws_s3_bucket" "datadog_firehose_backup" {
  bucket = module.this.id
}

# IAM policies and role

## metrics
data "aws_iam_policy_document" "metrics_sts" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["streams.metrics.cloudwatch.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "metrics_delivery" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]

    resources = [aws_kinesis_firehose_delivery_stream.datadog.arn]
  }
}

resource "aws_iam_role" "stream" {
  name               = module.this.id
  assume_role_policy = data.aws_iam_policy_document.metrics_sts.json

  inline_policy {
    name   = "${module.this.id}-metric-delivery"
    policy = data.aws_iam_policy_document.metrics_delivery.json
  }
}

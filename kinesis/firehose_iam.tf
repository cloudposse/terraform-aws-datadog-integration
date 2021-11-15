
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

resource "aws_iam_role" "datadog_firehose" {
  name               = "${module.this.id}-firehose"
  assume_role_policy = data.aws_iam_policy_document.firehose_sts.json

  inline_policy {
    name   = "${module.this.id}-backup"
    policy = data.aws_iam_policy_document.datadog_firehose_s3_backup.json
  }
}

data "aws_iam_policy_document" "trust_relationship" {
  "statement" {
    sid     = "DatadogAWSTrustRelationship"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.datadog_aws_account_id}:root",
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["${var.datadog_external_id}"]
      variable = "sts:ExternalId"
    }
  }
}

data "aws_iam_policy_document" "integration_rds" {
  statement {
    sid    = "DatadogAWSIntegration"
    effect = "Allow"

    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "ec2:Get*",
      "logs:Get*",
      "logs:Describe*",
      "logs:FilterLogEvents",
      "logs:TestMetricFilter",
      "rds:Describe*",
      "rds:List*",
      "tag:getResources",
      "tag:getTagKeys",
      "tag:getTagValues",
    ]

    resources = ["*"]
  }
}

module "rds_label" {
  source    = "git::https://github.com/cloudposse/tf_label.git?ref=0.2.1"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  attributes = ["${compact(concat(var.attributes, list("rds")))}"]
}

resource "aws_iam_role" "default" {
  name               = "${module.rds_label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.trust_relationship.json}"
}

locals {
  rds_count = "${contains(var.integrations, "RDS") ? 1 : 0}"
}

resource "aws_iam_policy" "rds" {
  count  = "${local.rds_count}"
  name   = "${module.rds_label.id}"
  policy = "${data.aws_iam_policy_document.integration_rds.json}"
}

resource "aws_iam_role_policy_attachment" "rds" {
  count      = "${local.rds_count}"
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${aws_iam_policy.rds.arn}"
}

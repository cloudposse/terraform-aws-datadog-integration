data "aws_iam_policy_document" "datadog_trust_relationship" {
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
      values   = ["${var.datadog_integration_key}"]
      variable = "sts:ExternalId"
    }
  }
}

module "datadog_rds_label" {
  source    = "git::https://github.com/cloudposse/tf_label.git?ref=0.2.1"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  attribute = ["rds"]
}

data "aws_iam_policy_document" "datadog_integration_rds" {
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

resource "aws_iam_policy" "datadog_integration_rds" {
  name   = "${module.datadog_rds_label.id}"
  policy = "${data.aws_iam_policy_document.datadog_integration_rds.json}"
}

resource "aws_iam_role" "datadog_trust_relationship" {
  name               = "${module.datadog_rds_label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.datadog_trust_relationship.json}"
}

resource "aws_iam_role_policy_attachment" "ap_infra_datadog_integration" {
  role       = "${aws_iam_role.datadog_trust_relationship.name}"
  policy_arn = "${aws_iam_policy.datadog_integration_rds.arn}"
}

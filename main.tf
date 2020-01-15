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

module "role_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.16/master"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["${var.attributes}"]
}

resource "aws_iam_role" "default" {
  name               = "${module.role_label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.trust_relationship.json}"
}

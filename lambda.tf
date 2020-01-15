data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "DatadogLambd"
    effect = "Allow"

    actions = [
      "lambda:List*",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents",
      "tag:GetResources",
    ]

    resources = ["*"]
  }
}

module "lambda_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.16/master"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["${compact(concat(var.attributes, list("lambda")))}"]
}

locals {
  lambda_count = "${contains(split(",", lower(join(",", var.integrations))), "lambda") ? 1 : 0}"
}

resource "aws_iam_policy" "lambda" {
  count  = "${local.lambda_count}"
  name   = "${module.lambda_label.id}"
  policy = "${data.aws_iam_policy_document.lambda.json}"
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count      = "${local.lambda_count}"
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${join("", aws_iam_policy.lambda.*.arn)}"
}

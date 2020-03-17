data "aws_iam_policy_document" "core" {
  statement {
    sid    = "DatadogCore"
    effect = "Allow"

    actions = [
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "support:*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
    ]

    resources = ["*"]
  }
}

module "core_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.16.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = compact(concat(var.attributes, ["core"]))
}

locals {
  core_count = contains(split(",", lower(join(",", var.integrations))), "core") ? 1 : 0
}

resource "aws_iam_policy" "core" {
  count  = local.core_count
  name   = module.core_label.id
  policy = data.aws_iam_policy_document.core.json
}

resource "aws_iam_role_policy_attachment" "core" {
  count      = local.core_count
  role       = aws_iam_role.default.name
  policy_arn = join("", aws_iam_policy.core.*.arn)
}


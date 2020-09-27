data "aws_iam_policy_document" "core" {
  count = module.this.enabled ? 1 : 0

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
      "tag:GetTagValues"
    ]

    resources = ["*"]
  }
}

module "core_label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.19.2"

  attributes = compact(concat(module.this.attributes, ["core"]))

  context = module.this.context
}

locals {
  core_count = module.this.enabled && contains(split(",", lower(join(",", var.integrations))), "core") ? 1 : 0
}

resource "aws_iam_policy" "core" {
  count  = local.core_count
  name   = module.core_label.id
  policy = join("", data.aws_iam_policy_document.core.*.json)
}

resource "aws_iam_role_policy_attachment" "core" {
  count      = local.core_count
  role       = aws_iam_role.default.name
  policy_arn = join("", aws_iam_policy.core.*.arn)
}

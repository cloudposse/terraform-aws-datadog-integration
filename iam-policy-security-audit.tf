locals {
  security_audit_count = local.enabled && (contains(var.policies, "CSPM") || contains(var.policies, "SecurityAudit")) || var.security_audit_policy_enabled ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "security_audit" {
  count      = local.security_audit_count
  role       = one(aws_iam_role.default[*].name)
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

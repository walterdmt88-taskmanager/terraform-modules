locals {
  name = "${var.prefix}-${var.project}-${var.environment}-role-${var.region_code}-${var.purpose}"

  # arn:aws:iam::<acct>:oidc-provider/token.actions.githubusercontent.com -> token.actions.githubusercontent.com
  oidc_host = element(split("oidc-provider/", var.oidc_provider_arn), 1)
}

# Trust policy: only a token issued by GitHub, for AWS STS, with an allowed subject.
data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_host}:sub"
      values   = var.allowed_subjects
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = local.name
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = var.max_session_duration

  tags = merge(var.tags, {
    Name            = local.name
    ApplicationRole = "GitHub Actions role ${var.purpose}"
    SensitiveData   = "false"
  })
}

resource "aws_iam_role_policy" "this" {
  count = var.policy_json == null ? 0 : 1

  name   = "${local.name}-inline"
  role   = aws_iam_role.this.id
  policy = var.policy_json
}

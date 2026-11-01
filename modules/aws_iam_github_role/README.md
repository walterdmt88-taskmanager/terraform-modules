# aws_iam_github_role module

An IAM role that GitHub Actions assumes through the account's OIDC provider — no long-lived access keys.
The trust policy requires `aud = sts.amazonaws.com` and a `sub` that matches `allowed_subjects`.

The OIDC provider itself is account-wide and lives in `platform-infra/github-oidc`; this module only
creates the per-service role that trusts it.

## Usage

```hcl
module "ci_role" {
  source = "git::https://github.com/walterdmt88-taskmanager/terraform-modules.git//modules/aws_iam_github_role?ref=v1.1.0"

  prefix      = "proops"
  project     = "taskmanager"
  environment = "shared"
  region_code = "apse1"
  region      = "ap-southeast-1"
  purpose     = "user-service-ci"

  oidc_provider_arn = data.terraform_remote_state.github_oidc.outputs.provider_arn
  allowed_subjects  = ["repo:walterdmt88-taskmanager/user-service:ref:refs/heads/main"]
  policy_json       = data.aws_iam_policy_document.ecr_push.json

  tags = local.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| prefix | Org / customer shortcode | string | - | yes |
| project | Project shortcode | string | - | yes |
| environment | dev / staging / test / prod / shared | string | - | yes |
| region_code | Compact region (apse1) | string | - | yes |
| region | Full AWS region | string | - | yes |
| purpose | Name suffix | string | - | yes |
| tags | Common tags | map(string) | - | yes |
| oidc_provider_arn | ARN of the GitHub OIDC provider | string | - | yes |
| allowed_subjects | GitHub `sub` claims allowed to assume the role | list(string) | - | yes |
| policy_json | Inline permissions policy (JSON); null = none | string | null | no |
| max_session_duration | Credential lifetime in seconds | number | 3600 | no |

## Outputs

| Name | Description |
|---|---|
| arn | Role ARN |
| name | Role name |

## Subject examples

| Workflow runs on | `sub` claim |
|---|---|
| push to main | `repo:<org>/<repo>:ref:refs/heads/main` |
| a job with `environment: prod` | `repo:<org>/<repo>:environment:prod` |
| a pull request | `repo:<org>/<repo>:pull_request` |

Validation rejects a subject that does not name one org and one repo, so `repo:<org>/*` is not accepted.

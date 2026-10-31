# terraform-modules

Versioned library of single-purpose Terraform modules for the Task Management System.
No state, no environments, no provider configuration lives here — callers own those.

## Modules

| Module | Purpose |
|---|---|
| `aws_ec2` | EC2 instance, facade over `terraform-aws-modules/ec2-instance/aws` |

## Consuming a module

Always pin to a release tag, never a branch:

```hcl
module "example" {
  source = "git::https://github.com/walterdmt88-taskmanager/terraform-modules.git//modules/aws_ec2?ref=v1.0.0"
  # ...
}
```

## Rules for every module

- Takes the standard 6 inputs: `prefix`, `project`, `environment`, `region_code`, `region`, `tags`
- Files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`
- Declares `required_providers`; never configures a `provider` block
- Names resources `{prefix}-{project}-{environment}-{type}-{region_code}-{purpose}`
- Two-layer tags: caller passes common tags, module merges per-resource tags

## Versioning

Semver tags on `main`. Removing or renaming an input or output is a breaking change (major bump):
add the new name alongside the old one first, and remove the old one in the next major.

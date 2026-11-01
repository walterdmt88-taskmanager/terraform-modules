# aws_ecr module

One ECR repository with immutable tags, scan-on-push, AES256 encryption and a keep-last-N lifecycle policy.

## Usage

```hcl
module "ecr" {
  source = "git::https://github.com/walterdmt88-taskmanager/terraform-modules.git//modules/aws_ecr?ref=v1.1.0"

  prefix      = "proops"
  project     = "taskmanager"
  environment = "shared"
  region_code = "apse1"
  region      = "ap-southeast-1"
  purpose     = "user-service"

  tags = local.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| prefix | Org / customer shortcode | string | - | yes |
| project | Project shortcode, first segment of the repo name | string | - | yes |
| environment | dev / staging / test / prod / shared | string | - | yes |
| region_code | Compact region (apse1) | string | - | yes |
| region | Full AWS region | string | - | yes |
| purpose | Service name, second segment of the repo name | string | - | yes |
| tags | Common tags | map(string) | - | yes |
| image_tag_mutability | IMMUTABLE or MUTABLE | string | IMMUTABLE | no |
| scan_on_push | Basic vulnerability scan on push | bool | true | no |
| max_image_count | Images kept before older ones expire (rollback window) | number | 30 | no |

## Outputs

| Name | Description |
|---|---|
| repository | Full aws_ecr_repository object |
| name | Repository name (`taskmanager/user-service`) |
| arn | Repository ARN |
| repository_url | Push/pull URL |

## Naming

Repository name is `{project}/{purpose}` — path-style, as ECR expects. One repository serves every
environment: the image is built once and the same tag is promoted dev -> staging -> prod.

## Notes

- `IMMUTABLE` tags: pushing an existing tag fails with `ImageTagAlreadyExistsException`. CI should check
  for the tag first and skip the push on a re-run.
- `force_delete` is not exposed: a repo that still holds images cannot be destroyed by accident.
- Lifecycle keeps the last `max_image_count` images. A rollback target older than that is gone.

# aws_ec2 module

Wraps `terraform-aws-modules/ec2-instance/aws` with proops2026 naming + tagging conventions.

## Usage

```hcl
module "api_server" {
  source = "git::https://github.com/walterdmt88-taskmanager/terraform-modules.git//modules/aws_ec2?ref=v1.0.0"

  prefix      = "proops"
  project     = "taskmanager"
  environment = "dev"
  region_code = "apse1"
  region      = "ap-southeast-1"
  purpose     = "api-server"

  instance_type          = "t3.small"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.sg.id]

  tags = local.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| prefix | Org / customer shortcode | string | - | yes |
| project | Project shortcode | string | - | yes |
| environment | dev / test / prod | string | - | yes |
| region_code | Compact region (apse1) | string | - | yes |
| region | Full AWS region | string | - | yes |
| purpose | Suffix in resource name | string | - | yes |
| instance_type | EC2 type | string | t3.micro | no |
| subnet_id | Subnet ID | string | null | no |
| vpc_security_group_ids | Security group IDs | list(string) | [] | no |
| key_name | Existing EC2 key pair name | string | null | no |
| iam_instance_profile_name | IAM instance profile to attach | string | null | no |
| ami_id | Pin an AMI; if null, latest AL2023 at apply time (see variables.tf warning) | string | null | no |
| tags | Common tags (Project, Environment, ResponsibleParty, Owner) | map(string) | - | yes |

## Outputs

| Name | Description |
|---|---|
| instance | Full ec2-instance module object |
| id | EC2 instance ID |
| public_ip | Public IP |
| private_ip | Private IP |
| name | Generated resource name |

## Naming convention applied

Resources created by this module are named:
`{prefix}-{project}-{environment}-ec2-{region_code}-{purpose}`

Example: `proops-blogcms-dev-ec2-apse1-api-server`

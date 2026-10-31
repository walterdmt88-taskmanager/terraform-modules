# Look up Amazon Linux 2023 AMI dynamically (don't hardcode AMI IDs)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Build the resource name once, reuse it
locals {
  name = "${var.prefix}-${var.project}-${var.environment}-ec2-${var.region_code}-${var.purpose}"
}

# The facade: wrap terraform-aws-modules and add YOUR conventions
module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.6" # <-- always pin version

  name = local.name

  ami           = coalesce(var.ami_id, data.aws_ami.amazon_linux.id)
  instance_type = var.instance_type

  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile_name

  # Two-layer tag merge — common tags from env + per-resource tags
  tags = merge(var.tags, {
    Name            = local.name
    ApplicationRole = "EC2 ${var.purpose}"
    SensitiveData   = "false"
  })
}
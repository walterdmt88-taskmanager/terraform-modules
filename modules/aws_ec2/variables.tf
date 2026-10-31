# ===== STANDARD MODULE CONTRACT (every module takes these) =====

variable "prefix" {
  description = "Org or customer shortcode used in resource names (e.g. 'proops')"
  type        = string
}

variable "project" {
  description = "Project shortcode (e.g. 'blogcms')"
  type        = string
}

variable "environment" {
  description = "Environment name: dev / test / prod"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "region_code" {
  description = "Compact region code (e.g. 'apse2' for ap-southeast-2)"
  type        = string
}

variable "region" {
  description = "Full AWS region name (e.g. 'ap-southeast-2'). Used by data sources."
  type        = string
}

variable "tags" {
  description = "Common tags applied to every resource (Project, Environment, ResponsibleParty, Owner)"
  type        = map(string)
}

# ===== EC2-SPECIFIC INPUTS =====

variable "purpose" {
  description = "What this EC2 is for — used in the name suffix (e.g. 'api-server', 'vpn')"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to attach"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "Subnet ID where the instance is launched"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of an existing EC2 key pair to attach for SSH access"
  type        = string
  default     = null
}

variable "iam_instance_profile_name" {
  description = "Name of an IAM instance profile to attach (e.g. for SSM Session Manager access)"
  type        = string
  default     = null
}

variable "ami_id" {
  description = <<-EOT
    Pin to a specific AMI ID. If null, falls back to the most-recent Amazon
    Linux 2023 AMI at apply time — fine for a brand-new environment, but NEVER
    leave unset on a live instance: `ami` is a ForceNew attribute, so if a
    newer AMI becomes "most recent" between applies (patch releases roll out
    over time), the NEXT apply silently destroys and recreates the instance,
    even for an unrelated change like a security-group rule. Pin once the
    instance exists.
  EOT
  type        = string
  default     = null
}
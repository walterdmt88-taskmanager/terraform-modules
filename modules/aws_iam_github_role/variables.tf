# ===== STANDARD MODULE CONTRACT (every module takes these) =====

variable "prefix" {
  description = "Org or customer shortcode used in resource names (e.g. 'proops')"
  type        = string
}

variable "project" {
  description = "Project shortcode (e.g. 'taskmanager')"
  type        = string
}

variable "environment" {
  description = "Environment name. A role used by one build-once pipeline across all envs is 'shared'."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "test", "prod", "shared"], var.environment)
    error_message = "Environment must be one of: dev, staging, test, prod, shared."
  }
}

variable "region_code" {
  description = "Compact region code (e.g. 'apse1')"
  type        = string
}

variable "region" {
  description = "Full AWS region name (e.g. 'ap-southeast-1')"
  type        = string
}

variable "tags" {
  description = "Common tags applied to every resource (Project, Environment, ResponsibleParty, Owner)"
  type        = map(string)
}

# ===== ROLE-SPECIFIC INPUTS =====

variable "purpose" {
  description = "What the role is for — used in the name suffix (e.g. 'user-service-ci')"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the account's GitHub OIDC provider (output of platform-infra/github-oidc)"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:oidc-provider/", var.oidc_provider_arn))
    error_message = "oidc_provider_arn must be an IAM OIDC provider ARN."
  }
}

variable "allowed_subjects" {
  description = <<-EOT
    GitHub OIDC `sub` claims allowed to assume this role. Be as narrow as the pipeline allows, e.g.
      repo:walterdmt88-taskmanager/user-service:ref:refs/heads/main
      repo:walterdmt88-taskmanager/user-service:environment:prod
    A wildcard over the whole org would let any repo in it assume the role.
  EOT
  type        = list(string)
  validation {
    condition     = length(var.allowed_subjects) > 0 && alltrue([for s in var.allowed_subjects : can(regex("^repo:[^/*]+/[^/*]+:", s))])
    error_message = "Each subject must name one org and one repo (repo:<org>/<repo>:...); wildcards are only allowed after the repo name."
  }
}

variable "policy_json" {
  description = "Inline permissions policy (JSON) granting what the role may do. Null attaches no permissions."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Seconds the temporary credentials last (3600 to 43200)"
  type        = number
  default     = 3600
  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200."
  }
}

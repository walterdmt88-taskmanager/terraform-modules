# ===== STANDARD MODULE CONTRACT (every module takes these) =====

variable "prefix" {
  description = "Org or customer shortcode (e.g. 'proops')"
  type        = string
}

variable "project" {
  description = "Project shortcode (e.g. 'taskmanager'). First segment of the repository name."
  type        = string
}

variable "environment" {
  description = <<-EOT
    Environment name. One image repository serves every environment (build once,
    promote the same tag), so a service repo normally uses 'shared'.
  EOT
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

# ===== ECR-SPECIFIC INPUTS =====

variable "purpose" {
  description = "Service this repository holds images for — second segment of the repository name (e.g. 'user-service')"
  type        = string
}

variable "image_tag_mutability" {
  description = <<-EOT
    IMMUTABLE (default) makes a pushed tag permanent: the same commit-SHA tag can never point
    at a different image, which is what makes build-once-promote and SHA rollback trustworthy.
    CI must therefore skip the push when the tag already exists.
  EOT
  type        = string
  default     = "IMMUTABLE"
  validation {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

variable "scan_on_push" {
  description = "Run ECR basic vulnerability scanning on every push"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Keep at most this many images; older ones expire. This is also the rollback window."
  type        = number
  default     = 30
  validation {
    condition     = var.max_image_count >= 1
    error_message = "max_image_count must be at least 1."
  }
}

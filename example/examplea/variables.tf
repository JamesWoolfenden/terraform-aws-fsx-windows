variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map(string)

  validation {
    condition     = length(var.common_tags) > 0
    error_message = "common_tags must contain at least one tag."
  }
}

variable "vpc_id" {
  description = "VPC to deploy into"
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "vpc_id must be a VPC ID such as vpc-0123456789abcdef0."
  }
}

variable "subnet_ids" {
  description = "Two subnets in different AZs for the MULTI_AZ_1 file system"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) == 2 && alltrue([for s in var.subnet_ids : can(regex("^subnet-[0-9a-f]{8,17}$", s))])
    error_message = "subnet_ids must be two subnet IDs."
  }
}

variable "active_directory_id" {
  description = "AWS Managed Microsoft AD directory ID"
  type        = string

  validation {
    condition     = can(regex("^d-[0-9a-f]{10}$", var.active_directory_id))
    error_message = "active_directory_id must be a directory ID such as d-1234567890."
  }
}

variable "client_cidrs" {
  description = "Private CIDR ranges allowed SMB access"
  type        = list(string)

  validation {
    condition     = length(var.client_cidrs) > 0 && alltrue([for c in var.client_cidrs : can(cidrhost(c, 0)) && c != "0.0.0.0/0"])
    error_message = "client_cidrs must be valid CIDR blocks and must not include 0.0.0.0/0."
  }
}

variable "admin_cidrs" {
  description = "Private CIDR ranges allowed remote PowerShell administration"
  type        = list(string)

  validation {
    condition     = length(var.admin_cidrs) > 0 && alltrue([for c in var.admin_cidrs : can(cidrhost(c, 0)) && c != "0.0.0.0/0"])
    error_message = "admin_cidrs must be valid CIDR blocks and must not include 0.0.0.0/0."
  }
}

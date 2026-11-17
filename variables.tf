variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map(string)

  validation {
    condition     = length(var.common_tags) > 0
    error_message = "common_tags must contain at least one tag."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs. The first is the preferred subnet; MULTI_AZ_1 needs exactly two"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1 && length(var.subnet_ids) <= 2 && alltrue([for s in var.subnet_ids : can(regex("^subnet-[0-9a-f]{8,17}$", s))])
    error_message = "subnet_ids must be one or two subnet IDs."
  }
}

variable "security_group_ids" {
  description = "Security groups to attach to the file system network interfaces"
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) > 0 && alltrue([for s in var.security_group_ids : can(regex("^sg-[0-9a-f]{8,17}$", s))])
    error_message = "At least one security group ID (sg-...) must be supplied."
  }
}

variable "kms_key_id" {
  description = "ARN of the customer managed KMS key used to encrypt data at rest"
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:kms:[a-z0-9-]+:[0-9]{12}:key/.+$", var.kms_key_id))
    error_message = "kms_key_id must be a customer managed KMS key ARN."
  }
}

variable "file_system" {
  description = "Core Windows file system settings"
  type = object({
    deployment_type     = optional(string, "MULTI_AZ_1")
    storage_type        = optional(string, "SSD")
    storage_capacity    = optional(number, 32)
    throughput_capacity = optional(number, 32)
    disk_iops_mode      = optional(string, "AUTOMATIC")
    disk_iops           = optional(number)
  })
  default = {}

  validation {
    condition     = contains(["MULTI_AZ_1", "SINGLE_AZ_1", "SINGLE_AZ_2"], var.file_system.deployment_type)
    error_message = "deployment_type must be MULTI_AZ_1, SINGLE_AZ_1 or SINGLE_AZ_2."
  }

  validation {
    condition     = contains(["SSD", "HDD"], var.file_system.storage_type)
    error_message = "storage_type must be SSD or HDD."
  }

  validation {
    condition     = var.file_system.storage_capacity >= 32 && var.file_system.throughput_capacity >= 8
    error_message = "storage_capacity must be >= 32 GiB and throughput_capacity >= 8 MBps."
  }

  validation {
    condition     = contains(["AUTOMATIC", "USER_PROVISIONED"], var.file_system.disk_iops_mode)
    error_message = "disk_iops_mode must be AUTOMATIC or USER_PROVISIONED."
  }
}

variable "active_directory_id" {
  description = "ID of an AWS Managed Microsoft AD directory to join. Set this or self_managed_active_directory"
  type        = string
  default     = null

  validation {
    condition     = var.active_directory_id == null || can(regex("^d-[0-9a-f]{10}$", coalesce(var.active_directory_id, "x")))
    error_message = "active_directory_id must be a directory ID such as d-1234567890."
  }
}

variable "self_managed_active_directory" {
  description = "Self-managed AD join. Prefer domain_join_service_account_secret (Secrets Manager ARN) over username/password. Set this or active_directory_id"
  type = object({
    dns_ips                                = list(string)
    domain_name                            = string
    domain_join_service_account_secret     = optional(string)
    username                               = optional(string)
    password                               = optional(string)
    file_system_administrators_group       = optional(string)
    organizational_unit_distinguished_name = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.self_managed_active_directory == null || (
      length(try(var.self_managed_active_directory.dns_ips, [])) > 0 &&
      (try(var.self_managed_active_directory.domain_join_service_account_secret, null) != null ||
      (try(var.self_managed_active_directory.username, null) != null && try(var.self_managed_active_directory.password, null) != null))
    )
    error_message = "self_managed_active_directory needs dns_ips and either domain_join_service_account_secret or username and password."
  }
}

variable "aliases" {
  description = "DNS aliases (FQDNs) for the file system"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for a in var.aliases : can(regex("^[a-zA-Z0-9.-]{4,253}$", a))])
    error_message = "aliases must be fully qualified DNS names."
  }
}

variable "audit_log_configuration" {
  description = "File access auditing. Levels: SUCCESS_ONLY, FAILURE_ONLY or SUCCESS_AND_FAILURE. audit_log_destination: CloudWatch log group or Firehose ARN (null uses /aws/fsx/windows)"
  type = object({
    audit_log_destination             = optional(string)
    file_access_audit_log_level       = optional(string, "SUCCESS_AND_FAILURE")
    file_share_access_audit_log_level = optional(string, "SUCCESS_AND_FAILURE")
  })
  default = {}

  validation {
    condition = alltrue([for l in [var.audit_log_configuration.file_access_audit_log_level, var.audit_log_configuration.file_share_access_audit_log_level] :
    contains(["SUCCESS_ONLY", "FAILURE_ONLY", "SUCCESS_AND_FAILURE"], l)])
    error_message = "Audit logging must be enabled: levels must be SUCCESS_ONLY, FAILURE_ONLY or SUCCESS_AND_FAILURE."
  }
}

variable "automatic_backup_retention_days" {
  description = "Days to retain automatic backups"
  type        = number
  default     = 7

  validation {
    condition     = var.automatic_backup_retention_days >= 1 && var.automatic_backup_retention_days <= 90
    error_message = "Automatic backups must be enabled with a retention of 1-90 days."
  }
}

variable "daily_automatic_backup_start_time" {
  description = "Daily backup start time in HH:MM (UTC)"
  type        = string
  default     = "01:00"

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.daily_automatic_backup_start_time))
    error_message = "daily_automatic_backup_start_time must be HH:MM."
  }
}

variable "weekly_maintenance_start_time" {
  description = "Weekly maintenance window in d:HH:MM (UTC)"
  type        = string
  default     = "7:03:00"

  validation {
    condition     = can(regex("^[1-7]:([01][0-9]|2[0-3]):[0-5][0-9]$", var.weekly_maintenance_start_time))
    error_message = "weekly_maintenance_start_time must be d:HH:MM."
  }
}

variable "copy_tags_to_backups" {
  description = "Copy file system tags to backups"
  type        = bool
  default     = true
}

variable "skip_final_backup" {
  description = "Skip the final backup on deletion"
  type        = bool
  default     = false
}

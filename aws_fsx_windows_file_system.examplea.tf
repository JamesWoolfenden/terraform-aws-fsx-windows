resource "aws_fsx_windows_file_system" "examplea" {
  deployment_type                   = var.file_system.deployment_type
  storage_type                      = var.file_system.storage_type
  storage_capacity                  = var.file_system.storage_capacity
  throughput_capacity               = var.file_system.throughput_capacity
  subnet_ids                        = var.subnet_ids
  preferred_subnet_id               = var.subnet_ids[0]
  security_group_ids                = var.security_group_ids
  kms_key_id                        = var.kms_key_id
  active_directory_id               = var.active_directory_id
  aliases                           = var.aliases
  automatic_backup_retention_days   = var.automatic_backup_retention_days
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  copy_tags_to_backups              = var.copy_tags_to_backups
  skip_final_backup                 = var.skip_final_backup
  final_backup_tags                 = var.common_tags

  audit_log_configuration {
    audit_log_destination             = var.audit_log_configuration.audit_log_destination
    file_access_audit_log_level       = var.audit_log_configuration.file_access_audit_log_level
    file_share_access_audit_log_level = var.audit_log_configuration.file_share_access_audit_log_level
  }

  disk_iops_configuration {
    mode = var.file_system.disk_iops_mode
    iops = var.file_system.disk_iops
  }

  dynamic "self_managed_active_directory" {
    for_each = var.self_managed_active_directory == null ? [] : [var.self_managed_active_directory]
    content {
      dns_ips                                = self_managed_active_directory.value.dns_ips
      domain_name                            = self_managed_active_directory.value.domain_name
      domain_join_service_account_secret     = self_managed_active_directory.value.domain_join_service_account_secret
      username                               = self_managed_active_directory.value.username
      password                               = self_managed_active_directory.value.password
      file_system_administrators_group       = self_managed_active_directory.value.file_system_administrators_group
      organizational_unit_distinguished_name = self_managed_active_directory.value.organizational_unit_distinguished_name
    }
  }

  tags = var.common_tags

  lifecycle {
    precondition {
      condition     = (var.active_directory_id == null) != (var.self_managed_active_directory == null)
      error_message = "Set exactly one of active_directory_id (AWS Managed Microsoft AD) or self_managed_active_directory."
    }
  }
}

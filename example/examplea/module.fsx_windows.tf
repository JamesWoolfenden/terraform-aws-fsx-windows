# holden:ignore:HLD_TF_026 the example intentionally calls the module under test via ../../ so it always exercises the working tree
# holden:ignore:HLD_TF_065 single-resource module by design: it wraps aws_fsx_windows_file_system to enforce secure defaults and input validation (CMK, audit logging, backups, AD choice)
module "fsx_windows" {
  source              = "../../"
  common_tags         = var.common_tags
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.windows.id]
  kms_key_id          = aws_kms_key.examplea.arn
  active_directory_id = var.active_directory_id

  audit_log_configuration = {
    audit_log_destination = aws_cloudwatch_log_group.windows.arn
  }
}

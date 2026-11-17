resource "aws_cloudwatch_log_group" "windows" {
  # FSx for Windows File Server requires the log group name to start with /aws/fsx/
  name                        = "/aws/fsx/windows-examplea"
  retention_in_days           = 365
  kms_key_id                  = aws_kms_key.examplea.arn
  deletion_protection_enabled = true
}

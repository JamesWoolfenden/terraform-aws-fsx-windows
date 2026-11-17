resource "aws_kms_key" "examplea" {
  description             = "FSx for Windows File Server example key"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "EnableIAMUserPermissions"
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "kms:*"
      Resource  = "*"
    }]
  })

  lifecycle {
    prevent_destroy = true
  }
}

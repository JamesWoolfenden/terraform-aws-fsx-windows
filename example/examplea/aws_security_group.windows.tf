resource "aws_security_group" "windows" {
  name        = "fsx-windows-examplea"
  description = "FSx for Windows File Server client access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = var.client_cidrs
  }

  ingress {
    description = "PowerShell remote administration (WinRM)"
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = var.admin_cidrs
  }

  egress {
    description = "Active Directory and clients"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.client_cidrs
  }
}

output "file_system" {
  description = "The FSx for Windows File Server file system"
  value       = aws_fsx_windows_file_system.examplea
  sensitive   = true
}

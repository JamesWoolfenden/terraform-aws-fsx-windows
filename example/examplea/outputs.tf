output "file_system" {
  description = "The FSx for Windows File Server file system"
  value       = module.fsx_windows.file_system
  sensitive   = true
}

common_tags = {
  "createdby" = "terraform"
  module      = "terraform-aws-fsx-windows"
}
vpc_id              = "vpc-0123456789abcdef0"
subnet_ids          = ["subnet-04338b6369d8288a5", "subnet-0a1b2c3d4e5f60718"]
active_directory_id = "d-1234567890"
client_cidrs        = ["10.0.0.0/16"]
admin_cidrs         = ["10.0.10.0/24"]

# terraform-aws-fsx-windows

[![Build Status](https://github.com/JamesWoolfenden/terraform-aws-fsx-windows/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-aws-fsx-windows)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-aws-fsx-windows.svg)](https://github.com/JamesWoolfenden/terraform-aws-fsx-windows/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-aws-fsx-windows.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-aws-fsx-windows/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Amazon FSx for Windows File Server. Joins either an AWS Managed Microsoft AD (active_directory_id) or a self-managed AD (self_managed_active_directory, preferably via a Secrets Manager service-account secret) - exactly one is enforced. Secure defaults: MULTI_AZ_1 deployment, customer managed KMS key required, file and file-share access auditing (SUCCESS_AND_FAILURE), automatic backups (7 days) with final backup on delete.

---

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

## Usage

Include this repository as a module in your existing Terraform code:

```hcl
module "fsx_windows" {
  source              = "JamesWoolfenden/fsx-windows/aws"
  version             = "0.0.1"
  common_tags         = var.common_tags
  subnet_ids          = ["subnet-04338b6369d8288a5", "subnet-0a1b2c3d4e5f60718"]
  security_group_ids  = [aws_security_group.windows.id]
  kms_key_id          = aws_kms_key.examplea.arn
  active_directory_id = "d-1234567890"

  audit_log_configuration = {
    audit_log_destination = aws_cloudwatch_log_group.windows.arn
  }
}
```

The example in the **examplea** folder creates the supporting KMS key, log group and security group.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_fsx_windows_file_system.examplea](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_windows_file_system) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_active_directory_id"></a> [active\_directory\_id](#input\_active\_directory\_id) | ID of an AWS Managed Microsoft AD directory to join. Set this or self\_managed\_active\_directory | `string` | `null` | no |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | DNS aliases (FQDNs) for the file system | `list(string)` | `[]` | no |
| <a name="input_audit_log_configuration"></a> [audit\_log\_configuration](#input\_audit\_log\_configuration) | File access auditing. Levels: SUCCESS\_ONLY, FAILURE\_ONLY or SUCCESS\_AND\_FAILURE. audit\_log\_destination: CloudWatch log group or Firehose ARN (null uses /aws/fsx/windows) | <pre>object({<br/>    audit_log_destination             = optional(string)<br/>    file_access_audit_log_level       = optional(string, "SUCCESS_AND_FAILURE")<br/>    file_share_access_audit_log_level = optional(string, "SUCCESS_AND_FAILURE")<br/>  })</pre> | `{}` | no |
| <a name="input_automatic_backup_retention_days"></a> [automatic\_backup\_retention\_days](#input\_automatic\_backup\_retention\_days) | Days to retain automatic backups | `number` | `7` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | This is to help you add tags to your cloud objects | `map(string)` | n/a | yes |
| <a name="input_copy_tags_to_backups"></a> [copy\_tags\_to\_backups](#input\_copy\_tags\_to\_backups) | Copy file system tags to backups | `bool` | `true` | no |
| <a name="input_daily_automatic_backup_start_time"></a> [daily\_automatic\_backup\_start\_time](#input\_daily\_automatic\_backup\_start\_time) | Daily backup start time in HH:MM (UTC) | `string` | `"01:00"` | no |
| <a name="input_file_system"></a> [file\_system](#input\_file\_system) | Core Windows file system settings | <pre>object({<br/>    deployment_type     = optional(string, "MULTI_AZ_1")<br/>    storage_type        = optional(string, "SSD")<br/>    storage_capacity    = optional(number, 32)<br/>    throughput_capacity = optional(number, 32)<br/>    disk_iops_mode      = optional(string, "AUTOMATIC")<br/>    disk_iops           = optional(number)<br/>  })</pre> | `{}` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the customer managed KMS key used to encrypt data at rest | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security groups to attach to the file system network interfaces | `list(string)` | n/a | yes |
| <a name="input_self_managed_active_directory"></a> [self\_managed\_active\_directory](#input\_self\_managed\_active\_directory) | Self-managed AD join. Prefer domain\_join\_service\_account\_secret (Secrets Manager ARN) over username/password. Set this or active\_directory\_id | <pre>object({<br/>    dns_ips                                = list(string)<br/>    domain_name                            = string<br/>    domain_join_service_account_secret     = optional(string)<br/>    username                               = optional(string)<br/>    password                               = optional(string)<br/>    file_system_administrators_group       = optional(string)<br/>    organizational_unit_distinguished_name = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_skip_final_backup"></a> [skip\_final\_backup](#input\_skip\_final\_backup) | Skip the final backup on deletion | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs. The first is the preferred subnet; MULTI\_AZ\_1 needs exactly two | `list(string)` | n/a | yes |
| <a name="input_weekly_maintenance_start_time"></a> [weekly\_maintenance\_start\_time](#input\_weekly\_maintenance\_start\_time) | Weekly maintenance window in d:HH:MM (UTC) | `string` | `"7:03:00"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_file_system"></a> [file\_system](#output\_file\_system) | The FSx for Windows File Server file system |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Policy

This is the policy required to build this project:

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role — full permissions for terraform apply
resource "aws_iam_policy" "terraform_pike" {
  name_prefix = "terraform_pike"
  path        = "/"
  description = "Pike Autogenerated policy from IAC"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "fsx:CreateFileSystem",
                "fsx:DeleteFileSystem",
                "fsx:DescribeFileSystems",
                "fsx:TagResource",
                "fsx:UntagResource",
                "fsx:UpdateFileSystem"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Related Projects

Check out these related projects.

- [terraform-aws-fsx-openzfs](https://github.com/jameswoolfenden/terraform-aws-fsx-openzfs) - FSx for OpenZFS

## Help

**Got a question?**

File a GitHub [issue](https://github.com/JamesWoolfenden/terraform-aws-fsx-windows/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/JamesWoolfenden/terraform-aws-fsx-windows/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2019-2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150

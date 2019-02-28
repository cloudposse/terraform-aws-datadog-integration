## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| datadog_aws_account_id | The AWS account ID Datadog's integration servers use for all integrations | string | `464622532012` | no |
| datadog_external_id | AWS External ID for this Datadog integration | string | - | yes |
| integrations | List of AWS permission names to apply for different integrations (`all`, `core`, `rds`) | list | - | yes |
| name | The Name of the application or solution  (e.g. `bastion` or `portal`) | string | `datadog` | no |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | - | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| role | Name of the AWS IAM Role for Datadog to use for this integration |


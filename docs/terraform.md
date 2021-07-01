<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.0 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 2.13 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.0 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 2.13 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_all_label"></a> [all\_label](#module\_all\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_core_label"></a> [core\_label](#module\_core\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_forwarder_rds"></a> [forwarder\_rds](#module\_forwarder\_rds) | cloudposse/module-artifact/external | 0.7.0 |
| <a name="module_forwarder_rds_label"></a> [forwarder\_rds\_label](#module\_forwarder\_rds\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_lambda_label"></a> [lambda\_label](#module\_lambda\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.forwarder_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_subscription_filter.datadog_log_subscription_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_policy.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.forwarder_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [datadog_integration_aws.integration](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws) | resource |
| [archive_file.forwarder_rds](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_specific_namespace_rules"></a> [account\_specific\_namespace\_rules](#input\_account\_specific\_namespace\_rules) | An object, (in the form {"namespace1":true/false, "namespace2":true/false} ), that enables or disables metric collection for specific AWS namespaces for this AWS account only | `map(string)` | `null` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_datadog_aws_account_id"></a> [datadog\_aws\_account\_id](#input\_datadog\_aws\_account\_id) | The AWS account ID Datadog's integration servers use for all integrations | `string` | `"464622532012"` | no |
| <a name="input_dd_api_key_kms_ciphertext_blob"></a> [dd\_api\_key\_kms\_ciphertext\_blob](#input\_dd\_api\_key\_kms\_ciphertext\_blob) | CiphertextBlob stored in environment variable DD\_KMS\_API\_KEY used by the lambda function, along with the KMS key, to decrypt Datadog API key | `string` | `""` | no |
| <a name="input_dd_api_key_source"></a> [dd\_api\_key\_source](#input\_dd\_api\_key\_source) | One of: ARN for AWS Secrets Manager (asm) to retrieve the Datadog (DD) api key, ARN for the KMS (kms) key used to decrypt the ciphertext\_blob of the api key, or the name of the SSM (ssm) parameter used to retrieve the Datadog API key. | <pre>object({<br>    resource   = string<br>    identifier = string<br>  })</pre> | <pre>{<br>  "identifier": "",<br>  "resource": ""<br>}</pre> | no |
| <a name="input_dd_artifact_filename"></a> [dd\_artifact\_filename](#input\_dd\_artifact\_filename) | The Datadog artifact filename minus extension | `string` | `"aws-dd-forwarder"` | no |
| <a name="input_dd_artifact_url"></a> [dd\_artifact\_url](#input\_dd\_artifact\_url) | The URL template to format the full URL to the Datadog zip artifact | `string` | `"https://github.com/DataDog/$${module_name}/releases/download/%v-$${git_ref}/$${filename}"` | no |
| <a name="input_dd_forwarder_version"></a> [dd\_forwarder\_version](#input\_dd\_forwarder\_version) | Version tag of datadog lambdas to use. https://github.com/DataDog/datadog-serverless-functions/releases | `string` | `"3.34.0"` | no |
| <a name="input_dd_git_ref"></a> [dd\_git\_ref](#input\_dd\_git\_ref) | The version of the Datadog artifact zip file | `string` | `"3.34.0"` | no |
| <a name="input_dd_module_name"></a> [dd\_module\_name](#input\_dd\_module\_name) | The Datadog GitHub repository name | `string` | `"datadog-serverless-functions"` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_excluded_regions"></a> [excluded\_regions](#input\_excluded\_regions) | An array of AWS regions to exclude from metrics collection | `list(string)` | `null` | no |
| <a name="input_filter_tags"></a> [filter\_tags](#input\_filter\_tags) | An array of EC2 tags (in the form `key:value`) that defines a filter that Datadog use when collecting metrics from EC2. Wildcards, such as ? (for single characters) and * (for multiple characters) can also be used | `list(string)` | `null` | no |
| <a name="input_forwarder_log_enabled"></a> [forwarder\_log\_enabled](#input\_forwarder\_log\_enabled) | Enable to add Datadog log forwarder | `bool` | `false` | no |
| <a name="input_forwarder_log_retention_days"></a> [forwarder\_log\_retention\_days](#input\_forwarder\_log\_retention\_days) | Number of days to retain Datadog forwarder lambda execution logs. One of [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653] | `number` | `14` | no |
| <a name="input_forwarder_rds_enabled"></a> [forwarder\_rds\_enabled](#input\_forwarder\_rds\_enabled) | Enable to add Datadog RDS enhanced monitoring forwarder | `bool` | `true` | no |
| <a name="input_forwarder_vpc_enabled"></a> [forwarder\_vpc\_enabled](#input\_forwarder\_vpc\_enabled) | Enable to add Datadog VPC flow log forwarder | `bool` | `false` | no |
| <a name="input_host_tags"></a> [host\_tags](#input\_host\_tags) | An array of tags (in the form `key:value`) to add to all hosts and metrics reporting through this integration | `list(string)` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_integrations"></a> [integrations](#input\_integrations) | List of AWS permission names to apply for different integrations (e.g. 'all', 'core') | `list(string)` | n/a | yes |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_lambda_reserved_concurrent_executions"></a> [lambda\_reserved\_concurrent\_executions](#input\_lambda\_reserved\_concurrent\_executions) | Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. | `number` | `-1` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Runtime environment for Datadog lambda. | `string` | `"python3.7"` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs used when Lambda Function should run in the VPC | `list(string)` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to use when running in a specific VPC. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_tracing_config_mode"></a> [tracing\_config\_mode](#input\_tracing\_config\_mode) | Can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service. | `string` | `"PassThrough"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_account_id"></a> [aws\_account\_id](#output\_aws\_account\_id) | AWS Account ID of the IAM Role for Datadog to use for this integration |
| <a name="output_aws_role_name"></a> [aws\_role\_name](#output\_aws\_role\_name) | Name of the AWS IAM Role for Datadog to use for this integration |
| <a name="output_datadog_external_id"></a> [datadog\_external\_id](#output\_datadog\_external\_id) | Datadog integration external ID |
| <a name="output_lambda_rds_function_id"></a> [lambda\_rds\_function\_id](#output\_lambda\_rds\_function\_id) | Lambda resource ID |
<!-- markdownlint-restore -->

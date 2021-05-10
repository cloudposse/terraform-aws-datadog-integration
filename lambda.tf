######################################################################
## https://docs.datadoghq.com/integrations/amazon_rds/?tab=enhanced
##
## TODO 
#   - Add some type of enabling feature flag for rds enahnced metrics
#   - Find explicit way to check for presence of multiple conflicting api kiey secret options (there should only be one of kms, asm, ssm)
#   - Move variables to variables.tf

variable "api_key_kms_arn" {
    default = "arn:aws-cn:kms:us-west-2:123456789012:key/mykey"
}

variable "api_key_kms_ciphertext_blob" {
    default = "1234"
}

variable "api_key_asm_arn" {
    default = ""
}

variable "api_key_ssm_parameter_name" {
    default = ""
}

data "aws_ssm_parameter" "api_key" {
    count = var.api_key_ssm_parameter_name != "" ? 1 : 0
    name  = var.api_key_ssm_parameter_name
}

######################################################################
## Create base assume policy and lambda role

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "lambda" # module.this.id
  assume_role_policy = data.aws_iam_policy_document.assume.json
  # tags               = module.this.tags
}

######################################################################
## Create lambda logging and secret policy then attach to base lambda role

# IAM policy locals
locals {
    api_key_kms_actions = var.api_key_kms_ciphertext_blob != "" ? ["kms:Decrypt"] : []
    api_key_asm_actions = var.api_key_asm_arn != "" ? ["secretsmanager:GetSecretValue"] : []
    api_key_ssm_actions = var.api_key_ssm_parameter_name != "" ? ["ssm:GetParameters"] : []
    api_key_ssm_arn     = var.api_key_ssm_parameter_name != "" ? data.aws_ssm_parameter.api_key[0].arn : ""
    api_iam_actions     = coalesce(local.api_key_kms_actions, local.api_key_asm_actions, local.api_key_ssm_actions)
    api_iam_resource    = coalesce(var.api_key_kms_arn, var.api_key_asm_arn, local.api_key_ssm_arn)
}

# TODO review DD specific reqs 
# https://github.com/DataDog/datadog-serverless-functions/blob/cb0e7965636a3ea613325d2d4624926600a436c0/aws/logs_monitoring/template.yaml
data "aws_iam_policy_document" "lambda" {

    statement {
        sid = "WriteLogs"

        effect = "Allow"
        
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            # I think these are only needed for other DD lambda forwarder types 
            # https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html#vpc-permissions
            # https://github.com/DataDog/datadog-serverless-functions/blob/cb0e7965636a3ea613325d2d4624926600a436c0/aws/logs_monitoring/template.yaml#L553-L560
            # "ec2:CreateNetworkInterface",
            # "ec2:DescribeNetworkInterfaces",
            # "ec2:DeleteNetworkInterface"
        ]

        resources = ["*"]
    }
    
    statement {
        sid = "GetApiKey"

        effect = "Allow"
        
        actions = local.api_iam_actions

        resources = [local.api_iam_resource]
    }

}

resource "aws_iam_policy" "lambda" {
  name        = "lambda" # module.this.id
  description = "Allow put logs and access to DD api key"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

######################################################################
## Get DD lambda zip artifact
## https://github.com/DataDog/datadog-serverless-functions/releases
## TODO move variables to variables.tf

variable "dd_artifact_filename" {
  default = "aws-dd-forwarder"
}

variable "dd_module_name" {
    default = "datadog-serverless-functions"
}
variable "dd_git_ref" {
    default = "3.31.0"
}

variable "dd_artifact_url" {
    # I don't like mixing format with template, I also don't want to create too much nesting in template string which might cause some to miss it if the modify it
    default = "https://github.com/DataDog/$$${module_name}/releases/download/%v-$$${git_ref}/$$${filename}"
}

locals {
    url      = format(var.dd_artifact_url, var.dd_artifact_filename)
    filename = format("%v-%v.zip", var.dd_artifact_filename, var.dd_git_ref)
}

module "artifact" {
  source      = "cloudposse/module-artifact/external"
  version     = "0.7.0"
  filename    = local.filename
  module_name = var.dd_module_name
  module_path = path.module
  git_ref     = var.dd_git_ref
  url         = local.url
}

######################################################################
## Create lambda function

# Lambda env vars locals 
locals {
    dd_api_key_kms = var.api_key_kms_ciphertext_blob != "" ? { DD_KMS_API_KEY = var.api_key_kms_ciphertext_blob } : {}
    dd_api_key_asm = var.api_key_asm_arn != "" ? { DD_API_KEY_SECRET_ARN = var.api_key_asm_arn } : {}
    dd_api_key_ssm = var.api_key_ssm_parameter_name != "" ? { DD_API_KEY_SSM_NAME = var.api_key_ssm_parameter_name } : {}
    lambda_env     = coalesce(local.dd_api_key_kms, local.dd_api_key_asm, local.dd_api_key_ssm)
}

resource "aws_lambda_function" "default" {
    description      = "Datadog forwarder for RDS enhanced monitoring"
    filename         = module.artifact.file
    function_name    = "datadog" # module.this.id
    role             = aws_iam_role.lambda.arn
    handler          = "lambda_function.lambda_handler"
    source_code_hash = module.artifact.base64sha256
    runtime          = "python3.7" # var.lambda_runtime
    # tags             = module.this.tags

    # vpc_config # do we need this based of implementation?

    environment {
        variables = local.lambda_env
    }

# Do we use this as a standard
#   tracing_config {
#     mode = var.tracing_config_mode
#   }
}

output "lambda_env" {
    value = local.lambda_env
}

output "aws_iam_policy_document" {
    value = data.aws_iam_policy_document.lambda.json
}

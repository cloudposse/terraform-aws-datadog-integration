provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

provider "aws" {
  region = var.region
}

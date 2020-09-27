enabled = true

region = "us-east-2"

namespace = "eg"

stage = "test"

name = "datadog-integration"

datadog_api_key = "test"

datadog_app_key = "test"

integrations = ["all"]

# Set to false to prevent the tests from failing since Datadog provider requires valid API and App keys
datadog_integration_enabled = false

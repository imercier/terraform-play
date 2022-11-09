resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "mydemoapi"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
  path_part   = "ep1"
}

resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.MyDemoResource.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id          = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id          = aws_api_gateway_resource.MyDemoResource.id
  http_method          = aws_api_gateway_method.MyDemoMethod.http_method
  type                 = "MOCK"

   request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_deployment" "MyDeployment" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.MyDemoResource.id,
      aws_api_gateway_method.MyDemoMethod.id,
      aws_api_gateway_integration.MyDemoIntegration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "MyStage" {
  deployment_id = aws_api_gateway_deployment.MyDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name    = "v1"
}

resource "aws_api_gateway_method_settings" "MyStage" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name  = aws_api_gateway_stage.MyStage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    data_trace_enabled = true
  }
}

resource "random_string" "MyKeyString" {
  length           = 30
  special          = false
}

resource "aws_api_gateway_api_key" "MyApiKey" {
  name = "myapikey"
  value = random_string.MyKeyString.result
}

resource "aws_api_gateway_usage_plan_key" "MyUsagePlanKey" {
  key_id        = aws_api_gateway_api_key.MyApiKey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.MyUsagePlan.id
}

resource "aws_api_gateway_usage_plan" "MyUsagePlan" {
  name         = "myusageplan"
  api_stages {
    api_id = aws_api_gateway_rest_api.MyDemoAPI.id
    stage  = aws_api_gateway_stage.MyStage.stage_name
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

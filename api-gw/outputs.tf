output "curl_stage_invoke_url" {
  value       = "curl -H 'x-api-key: ${random_string.MyKeyString.result}' ${aws_api_gateway_stage.MyStage.invoke_url}/${aws_api_gateway_resource.MyDemoResource.path_part}"
}

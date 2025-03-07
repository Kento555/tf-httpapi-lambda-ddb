output "invoke_url" {
  value = trimsuffix(aws_apigatewayv2_stage.default.invoke_url, "/")
}

# Output for the Invoke URL
output "invoke_url_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
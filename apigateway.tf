resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name_prefix}-topmovies-api"
  protocol_type = "HTTP"
}

# Define the API Gateway stage with logging
resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.http_api.id
  name   = "$default"
  auto_deploy = true
}


resource "aws_apigatewayv2_integration" "apigw_lambda" {
  api_id = aws_apigatewayv2_api.http_api.id
  integration_uri        = aws_lambda_function.http_api_lambda.invoke_arn # todo: fill with apporpriate value
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# GET /topmovies
resource "aws_apigatewayv2_route" "get_topmovies" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /topmovies"
  target    = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
}

# GET /topmovies/{year}
resource "aws_apigatewayv2_route" "get_topmovies_by_year" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /topmovies/{year}"
  target    = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
}

# PUT /topmovies
resource "aws_apigatewayv2_route" "put_topmovies" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "PUT /topmovies"
  target    = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
}

# DELETE /topmovies/{year}
resource "aws_apigatewayv2_route" "delete_topmovies_by_year" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "DELETE /topmovies/{year}"
  target    = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
}


resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http_api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# # API Gateway custom domain
# resource "aws_apigatewayv2_domain_name" "custom_domain" {
#   domain_name = "ws.sctp-sandbox.com"  # Replace with your custom domain

#   domain_name_configuration {
#     certificate_arn = aws_acm_certificate.custom_domain_cert.arn  # Replace with your ACM certificate ARN
#     endpoint_type   = "REGIONAL"
#     security_policy = "TLS_1_2"
#   }
#   depends_on = [aws_acm_certificate_validation.cert_validation]
# }

# # API Gateway mapping to custom domain
# resource "aws_apigatewayv2_api_mapping" "default" {
#   api_id      = aws_apigatewayv2_api.http_api.id
#   domain_name = aws_apigatewayv2_domain_name.custom_domain.domain_name
#   stage       = aws_apigatewayv2_stage.default.name
# }

# # CloudWatch log group for API Gateway with retention of 7 days
# resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
#   name              = "/aws/apigateway/${aws_apigatewayv2_api.http_api.id}"
#   retention_in_days = 7
# }


# Alternative for API route
# # API Routes
# locals {
#   routes = [
#     { method = "GET",    path = "/topmovies" },
#     { method = "GET",    path = "/topmovies/{year}" },
#     { method = "PUT",    path = "/topmovies" },
#     { method = "DELETE", path = "/topmovies/{year}" }
#   ]
# }

# resource "aws_apigatewayv2_route" "routes" {
#   for_each = { for route in local.routes : "${route.method} ${route.path}" => route }

#   api_id    = aws_apigatewayv2_api.http_api.id
#   route_key = "${each.value.method} ${each.value.path}"
#   target    = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
# }

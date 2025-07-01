# API Gateway
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API for ${var.project_name} ${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.common_tags
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_integration.contacts,
    aws_api_gateway_integration.countries,
    aws_api_gateway_integration.options_contacts,
    aws_api_gateway_integration.options_countries
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment
  
  tags = var.common_tags
}

# CORS configuration for all methods
resource "aws_api_gateway_gateway_response" "cors" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
  }
}

# Contacts Resource
resource "aws_api_gateway_resource" "contacts" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "contacts"
}

# Contacts GET Method
resource "aws_api_gateway_method" "contacts" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "GET"
  authorization = "NONE"
}

# Contacts Integration
resource "aws_api_gateway_integration" "contacts" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.contacts.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.contacts_lambda_invoke_arn
}

# Contacts OPTIONS Method for CORS
resource "aws_api_gateway_method" "options_contacts" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Contacts OPTIONS Integration
resource "aws_api_gateway_integration" "options_contacts" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options_contacts.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Contacts OPTIONS Method Response
resource "aws_api_gateway_method_response" "options_contacts" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options_contacts.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Contacts OPTIONS Integration Response
resource "aws_api_gateway_integration_response" "options_contacts" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options_contacts.http_method
  status_code = aws_api_gateway_method_response.options_contacts.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Countries Resource
resource "aws_api_gateway_resource" "countries" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "countries"
}

# Countries GET Method
resource "aws_api_gateway_method" "countries" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.countries.id
  http_method   = "GET"
  authorization = "NONE"
}

# Countries Integration
resource "aws_api_gateway_integration" "countries" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.countries.id
  http_method = aws_api_gateway_method.countries.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.countries_lambda_invoke_arn
}

# Countries OPTIONS Method for CORS
resource "aws_api_gateway_method" "options_countries" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.countries.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Countries OPTIONS Integration
resource "aws_api_gateway_integration" "options_countries" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.countries.id
  http_method = aws_api_gateway_method.options_countries.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Countries OPTIONS Method Response
resource "aws_api_gateway_method_response" "options_countries" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.countries.id
  http_method = aws_api_gateway_method.options_countries.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Countries OPTIONS Integration Response
resource "aws_api_gateway_integration_response" "options_countries" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.countries.id
  http_method = aws_api_gateway_method.options_countries.http_method
  status_code = aws_api_gateway_method_response.options_countries.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Lambda permissions
resource "aws_lambda_permission" "contacts" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.contacts_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "countries" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.countries_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

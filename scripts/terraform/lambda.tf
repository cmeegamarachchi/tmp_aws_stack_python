# Lambda function IAM role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Lambda function IAM policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy" "lambda_cognito" {
  name = "${var.project_name}-${var.environment}-lambda-cognito-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:GetUser",
          "cognito-idp:AdminGetUser"
        ]
        Resource = aws_cognito_user_pool.main.arn
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "api" {
  filename         = "../api/lambda-deployment.zip"
  function_name    = "${var.project_name}-${var.environment}-api"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  source_code_hash = filebase64sha256("../api/lambda-deployment.zip")
  runtime         = "nodejs18.x"
  timeout         = 30

  environment {
    variables = {
      NODE_ENV           = var.environment
      USER_POOL_ID       = aws_cognito_user_pool.main.id
      USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.main.id
      AWS_REGION         = var.aws_region
    }
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-api"
  retention_in_days = 14
  tags              = local.common_tags
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
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

  tags = var.common_tags
}

# Attach basic execution policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Lambda function for contacts
resource "aws_lambda_function" "contacts" {
  filename         = var.contacts_lambda_zip
  function_name    = "${var.project_name}-${var.environment}-contacts"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "handlers/contacts.handler"
  runtime         = "nodejs20.x"
  timeout         = 30
  
  source_code_hash = filebase64sha256(var.contacts_lambda_zip)

  environment {
    variables = {
      NODE_ENV = var.environment
    }
  }

  tags = var.common_tags
}

# Lambda function for countries
resource "aws_lambda_function" "countries" {
  filename         = var.countries_lambda_zip
  function_name    = "${var.project_name}-${var.environment}-countries"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "handlers/countries.handler"
  runtime         = "nodejs20.x"
  timeout         = 30
  
  source_code_hash = filebase64sha256(var.countries_lambda_zip)

  environment {
    variables = {
      NODE_ENV = var.environment
    }
  }

  tags = var.common_tags
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "contacts_logs" {
  name              = "/aws/lambda/${aws_lambda_function.contacts.function_name}"
  retention_in_days = 14
  tags              = var.common_tags
}

resource "aws_cloudwatch_log_group" "countries_logs" {
  name              = "/aws/lambda/${aws_lambda_function.countries.function_name}"
  retention_in_days = 14
  tags              = var.common_tags
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "contact-manager"
}

# Create zip file for contact layer
data "archive_file" "contact_layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../backend/src/layers/contact_layer"
  output_path = "${path.module}/contact-layer.zip"
}

# Create zip files for Lambda functions
data "archive_file" "list_contacts_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/src/lambda_functions/list_contacts.py"
  output_path = "${path.module}/list-contacts.zip"
}

data "archive_file" "get_contact_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/src/lambda_functions/get_contact.py"
  output_path = "${path.module}/get-contact.zip"
}

data "archive_file" "create_contact_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/src/lambda_functions/create_contact.py"
  output_path = "${path.module}/create-contact.zip"
}

data "archive_file" "update_contact_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/src/lambda_functions/update_contact.py"
  output_path = "${path.module}/update-contact.zip"
}

data "archive_file" "delete_contact_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/src/lambda_functions/delete_contact.py"
  output_path = "${path.module}/delete-contact.zip"
}

# IAM role for Lambda functions
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
}

# IAM policy attachment for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Layer
resource "aws_lambda_layer_version" "contact_layer" {
  filename            = data.archive_file.contact_layer_zip.output_path
  layer_name          = "${var.project_name}-${var.environment}-contact-layer"
  compatible_runtimes = ["python3.9"]
  source_code_hash    = data.archive_file.contact_layer_zip.output_base64sha256

  description = "Contact management business logic layer"
}

# Lambda Functions
resource "aws_lambda_function" "list_contacts" {
  filename         = data.archive_file.list_contacts_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-list-contacts"
  role            = aws_iam_role.lambda_role.arn
  handler         = "list_contacts.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  source_code_hash = data.archive_file.list_contacts_zip.output_base64sha256

  layers = [aws_lambda_layer_version.contact_layer.arn]

  environment {
    variables = {
      PYTHONPATH = "/opt/python"
    }
  }
}

resource "aws_lambda_function" "get_contact" {
  filename         = data.archive_file.get_contact_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-get-contact"
  role            = aws_iam_role.lambda_role.arn
  handler         = "get_contact.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  source_code_hash = data.archive_file.get_contact_zip.output_base64sha256

  layers = [aws_lambda_layer_version.contact_layer.arn]

  environment {
    variables = {
      PYTHONPATH = "/opt/python"
    }
  }
}

resource "aws_lambda_function" "create_contact" {
  filename         = data.archive_file.create_contact_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-create-contact"
  role            = aws_iam_role.lambda_role.arn
  handler         = "create_contact.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  source_code_hash = data.archive_file.create_contact_zip.output_base64sha256

  layers = [aws_lambda_layer_version.contact_layer.arn]

  environment {
    variables = {
      PYTHONPATH = "/opt/python"
    }
  }
}

resource "aws_lambda_function" "update_contact" {
  filename         = data.archive_file.update_contact_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-update-contact"
  role            = aws_iam_role.lambda_role.arn
  handler         = "update_contact.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  source_code_hash = data.archive_file.update_contact_zip.output_base64sha256

  layers = [aws_lambda_layer_version.contact_layer.arn]

  environment {
    variables = {
      PYTHONPATH = "/opt/python"
    }
  }
}

resource "aws_lambda_function" "delete_contact" {
  filename         = data.archive_file.delete_contact_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-delete-contact"
  role            = aws_iam_role.lambda_role.arn
  handler         = "delete_contact.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  source_code_hash = data.archive_file.delete_contact_zip.output_base64sha256

  layers = [aws_lambda_layer_version.contact_layer.arn]

  environment {
    variables = {
      PYTHONPATH = "/opt/python"
    }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "contact_api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "Contact Management API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resources
resource "aws_api_gateway_resource" "contacts" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  parent_id   = aws_api_gateway_rest_api.contact_api.root_resource_id
  path_part   = "contacts"
}

resource "aws_api_gateway_resource" "contact_by_id" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  parent_id   = aws_api_gateway_resource.contacts.id
  path_part   = "{id}"
}

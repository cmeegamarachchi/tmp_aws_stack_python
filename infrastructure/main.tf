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

data "archive_file" "health_check_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/src/lambda_functions/health_check.py"
  output_path = "${path.module}/health-check.zip"
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

resource "aws_lambda_function" "health_check" {
  filename         = data.archive_file.health_check_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-health-check"
  role            = aws_iam_role.lambda_role.arn
  handler         = "health_check.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  source_code_hash = data.archive_file.health_check_zip.output_base64sha256

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

resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  parent_id   = aws_api_gateway_rest_api.contact_api.root_resource_id
  path_part   = "health"
}

# S3 bucket for frontend hosting
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.project_name}-${var.environment}-frontend-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_pab" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.frontend_bucket_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      },
    ]
  })
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "Origin Access Control for Frontend S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
    origin_id                = "S3-${aws_s3_bucket.frontend_bucket.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.project_name} frontend"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.frontend_bucket.bucket}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Custom error response for SPA routing
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-distribution"
    Environment = var.environment
  }
}

# Update S3 bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "frontend_bucket_policy_cloudfront" {
  bucket = aws_s3_bucket.frontend_bucket.id
  depends_on = [
    aws_s3_bucket_public_access_block.frontend_bucket_pab,
    aws_cloudfront_distribution.frontend_distribution
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend_distribution.arn
          }
        }
      }
    ]
  })
}

# Output values
output "frontend_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend"
  value       = aws_s3_bucket.frontend_bucket.bucket
}

output "frontend_url" {
  description = "URL of the frontend via CloudFront"
  value       = "https://${aws_cloudfront_distribution.frontend_distribution.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.frontend_distribution.id
}

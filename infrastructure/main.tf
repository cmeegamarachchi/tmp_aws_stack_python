terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Build API first
resource "null_resource" "api_build" {
  triggers = {
    # Rebuild when API source changes
    api_package_hash = filemd5("${path.root}/../api/package.json")
    api_src_hash     = sha256(join("", [for f in fileset("${path.root}/../api/src", "**") : filesha256("${path.root}/../api/src/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = "${path.root}/../api"
    command = <<-EOT
      echo "Building API for deployment..."
      npm ci --production
      npm run build
    EOT
  }
}

# Data source for Lambda function zip files
data "archive_file" "contacts_lambda" {
  depends_on = [null_resource.api_build]
  type        = "zip"
  source_dir  = "${path.root}/../api/dist"
  output_path = "${path.root}/lambda_packages/contacts.zip"
}

data "archive_file" "countries_lambda" {
  depends_on = [null_resource.api_build]
  type        = "zip"
  source_dir  = "${path.root}/../api/dist"
  output_path = "${path.root}/lambda_packages/countries.zip"
}

# Lambda functions module
module "lambda" {
  source = "./modules/lambda"
  
  project_name           = var.project_name
  environment           = var.environment
  common_tags           = local.common_tags
  contacts_lambda_zip   = data.archive_file.contacts_lambda.output_path
  countries_lambda_zip  = data.archive_file.countries_lambda.output_path
}

# API Gateway module
module "api_gateway" {
  source = "./modules/api_gateway"
  
  project_name                     = var.project_name
  environment                     = var.environment
  common_tags                     = local.common_tags
  contacts_lambda_invoke_arn      = module.lambda.contacts_invoke_arn
  countries_lambda_invoke_arn     = module.lambda.countries_invoke_arn
  contacts_lambda_function_name   = module.lambda.contacts_function_name
  countries_lambda_function_name  = module.lambda.countries_function_name
}

# S3 bucket for website hosting
module "s3" {
  source = "./modules/s3"
  
  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

# CloudFront distribution
module "cloudfront" {
  source = "./modules/cloudfront"
  
  project_name         = var.project_name
  environment         = var.environment
  common_tags         = local.common_tags
  s3_bucket_name      = module.s3.bucket_name
  s3_website_endpoint = module.s3.website_endpoint
}

# Build and deploy React app
resource "null_resource" "react_app_build_deploy" {
  depends_on = [
    module.api_gateway,
    module.s3,
    module.cloudfront
  ]

  triggers = {
    # Rebuild when API Gateway URL changes
    api_gateway_url = module.api_gateway.api_gateway_url
    # Rebuild when app source changes (you can add more specific triggers if needed)
    app_build_hash = filemd5("${path.root}/../app/package.json")
  }

  provisioner "local-exec" {
    working_dir = "${path.root}/../app"
    command = <<-EOT
      echo "Building React app with API URL: ${module.api_gateway.api_gateway_url}"
      echo "VITE_API_URL=${module.api_gateway.api_gateway_url}" > .env.production
      npm install
      npm run build
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Uploading React app to S3 bucket: ${module.s3.bucket_name}"
      aws s3 sync ${path.root}/../app/dist/ s3://${module.s3.bucket_name} --delete
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Creating CloudFront invalidation for distribution: ${module.cloudfront.distribution_id}"
      aws cloudfront create-invalidation --distribution-id ${module.cloudfront.distribution_id} --paths "/*"
    EOT
  }
}

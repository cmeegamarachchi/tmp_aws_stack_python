#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Environment configuration
ENVIRONMENT=${1:-dev}
AWS_REGION=${AWS_REGION:-us-east-1}

# Check AWS CLI configuration
check_aws_config() {
    print_header "Checking AWS configuration..."
    
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        print_error "AWS CLI is not configured or credentials are invalid"
        print_error "Please run 'aws configure' to set up your credentials"
        exit 1
    fi
    
    print_status "AWS credentials are configured"
}

# Build the API
build_api() {
    print_header "Building API for deployment..."
    
    cd api || exit 1
    
    # Install production dependencies
    print_status "Installing production dependencies..."
    npm ci --production
    
    # Build the TypeScript code
    print_status "Building TypeScript code..."
    npm run build
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build API"
        exit 1
    fi
    
    cd ..
    print_status "API build completed"
}

# Build the React app
build_app() {
    print_header "Building React app for deployment..."
    
    cd app || exit 1
    
    # Get the API Gateway URL from Terraform output
    cd ../infrastructure
    API_URL=$(terraform output -raw api_gateway_url 2>/dev/null)
    cd ../app
    
    if [ ! -z "$API_URL" ]; then
        print_status "Using API URL: $API_URL"
        echo "VITE_API_URL=$API_URL" > .env.production
    else
        print_warning "Could not get API URL from Terraform. Using default configuration."
    fi
    
    # Build the React app
    print_status "Building React app..."
    npm run build
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build React app"
        exit 1
    fi
    
    cd ..
    print_status "React app build completed"
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    print_header "Deploying infrastructure with Terraform..."
    
    cd infrastructure || exit 1
    
    # Create lambda packages directory
    mkdir -p lambda_packages
    
    # Plan the deployment
    print_status "Planning Terraform deployment..."
    terraform plan -var="environment=$ENVIRONMENT" -var="aws_region=$AWS_REGION"
    
    if [ $? -ne 0 ]; then
        print_error "Terraform plan failed"
        exit 1
    fi
    
    # Apply the deployment
    print_status "Applying Terraform deployment..."
    terraform apply -var="environment=$ENVIRONMENT" -var="aws_region=$AWS_REGION" -auto-approve
    
    if [ $? -ne 0 ]; then
        print_error "Terraform apply failed"
        exit 1
    fi
    
    cd ..
    print_status "Infrastructure deployment completed"
}

# Upload React app to S3
upload_app() {
    print_header "Uploading React app to S3..."
    
    cd infrastructure || exit 1
    
    # Get the S3 bucket name from Terraform output
    BUCKET_NAME=$(terraform output -raw s3_bucket_name)
    
    if [ -z "$BUCKET_NAME" ]; then
        print_error "Could not get S3 bucket name from Terraform output"
        exit 1
    fi
    
    cd ..
    
    print_status "Uploading to bucket: $BUCKET_NAME"
    
    # Upload the built React app
    aws s3 sync app/dist/ s3://$BUCKET_NAME --delete
    
    if [ $? -ne 0 ]; then
        print_error "Failed to upload React app to S3"
        exit 1
    fi
    
    print_status "React app uploaded successfully"
}

# Invalidate CloudFront cache
invalidate_cloudfront() {
    print_header "Invalidating CloudFront cache..."
    
    cd infrastructure || exit 1
    
    # Get the CloudFront distribution ID from Terraform output
    DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_domain 2>/dev/null)
    
    if [ ! -z "$DISTRIBUTION_ID" ]; then
        print_status "Invalidating CloudFront cache for distribution: $DISTRIBUTION_ID"
        aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
        
        if [ $? -eq 0 ]; then
            print_status "CloudFront cache invalidated"
        else
            print_warning "Failed to invalidate CloudFront cache"
        fi
    else
        print_warning "Could not get CloudFront distribution ID"
    fi
    
    cd ..
}

# Display deployment information
show_deployment_info() {
    print_header "=== Deployment Information ==="
    
    cd infrastructure || exit 1
    
    echo
    print_status "API Gateway URL:"
    terraform output api_gateway_url
    
    echo
    print_status "Website URL:"
    terraform output website_url
    
    echo
    print_status "S3 Bucket:"
    terraform output s3_bucket_name
    
    echo
    print_status "CloudFront Distribution:"
    terraform output cloudfront_distribution_domain
    
    cd ..
}

# Main deployment function
main() {
    print_header "=== Deploying Contact Management System to AWS ==="
    print_status "Environment: $ENVIRONMENT"
    print_status "AWS Region: $AWS_REGION"
    echo
    
    check_aws_config
    build_api
    deploy_infrastructure
    build_app
    upload_app
    invalidate_cloudfront
    
    print_header "=== Deployment completed successfully! ==="
    show_deployment_info
}

# Run main function
main "$@"

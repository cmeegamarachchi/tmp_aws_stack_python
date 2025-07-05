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

build_api(){
    print_header "Building API..."
    
    cd api || exit 1

    node build-lambdas.js
    
    if [ $? -ne 0 ]; then
        print_error "API build failed"
        exit 1
    fi
    
    print_status "API build completed successfully"
    cd ..
}

build_react_app() {
    print_header "Building React app..."
    
    cd app || exit 1
    
    npm install
    npm run build
    
    if [ $? -ne 0 ]; then
        print_error "React app build failed"
        exit 1
    fi
    
    print_status "React app build completed successfully"
    cd ..
}

# Main deployment function
main() {
    print_header "=== Deploying Contact Management System to AWS ==="
    print_status "Environment: $ENVIRONMENT"
    print_status "AWS Region: $AWS_REGION"
    echo

    build_api
    build_react_app

    check_aws_config
    deploy_infrastructure
    
    print_header "=== Deployment completed successfully! ==="
    show_deployment_info
}

# Run main function
main "$@"

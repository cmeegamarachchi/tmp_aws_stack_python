#!/bin/bash

# Complete deployment script for the Contact Manager application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
AWS_REGION="us-east-1"
PROJECT_NAME="contact-manager"
DEPLOY_FRONTEND=true
DEPLOY_INFRASTRUCTURE=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    -r|--region)
      AWS_REGION="$2"
      shift 2
      ;;
    -p|--project)
      PROJECT_NAME="$2"
      shift 2
      ;;
    --frontend-only)
      DEPLOY_INFRASTRUCTURE=false
      shift
      ;;
    --infrastructure-only)
      DEPLOY_FRONTEND=false
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  -e, --environment        Environment name (default: dev)"
      echo "  -r, --region            AWS region (default: us-east-1)"
      echo "  -p, --project           Project name (default: contact-manager)"
      echo "  --frontend-only         Deploy only the frontend"
      echo "  --infrastructure-only   Deploy only the infrastructure"
      echo "  -h, --help              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}=== Contact Manager Deployment ===${NC}"
echo "Environment: $ENVIRONMENT"
echo "Region: $AWS_REGION"
echo "Project: $PROJECT_NAME"
echo "Deploy Infrastructure: $DEPLOY_INFRASTRUCTURE"
echo "Deploy Frontend: $DEPLOY_FRONTEND"
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INFRASTRUCTURE_DIR="$PROJECT_ROOT/infrastructure"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# Check AWS CLI and credentials
echo -e "${YELLOW}Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${RED}Error: AWS credentials not configured or invalid${NC}"
    echo "Please run 'aws configure' or set AWS environment variables"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo ""

# Deploy Infrastructure
if [ "$DEPLOY_INFRASTRUCTURE" = true ]; then
    echo -e "${BLUE}=== Deploying Infrastructure ===${NC}"
    
    if [ ! -d "$INFRASTRUCTURE_DIR" ] || [ ! -f "$INFRASTRUCTURE_DIR/main.tf" ]; then
        echo -e "${RED}Error: Infrastructure directory not found${NC}"
        exit 1
    fi
    
    cd "$INFRASTRUCTURE_DIR"
    
    # Initialize Terraform
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
    
    # Validate Terraform configuration
    echo -e "${YELLOW}Validating Terraform configuration...${NC}"
    terraform validate
    
    # Plan the deployment
    echo -e "${YELLOW}Planning Terraform deployment...${NC}"
    terraform plan \
        -var="aws_region=$AWS_REGION" \
        -var="environment=$ENVIRONMENT" \
        -var="project_name=$PROJECT_NAME"
    
    # Apply the deployment
    echo -e "${YELLOW}Applying Terraform configuration...${NC}"
    terraform apply \
        -var="aws_region=$AWS_REGION" \
        -var="environment=$ENVIRONMENT" \
        -var="project_name=$PROJECT_NAME" \
        -auto-approve
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Infrastructure deployment completed successfully${NC}"
    else
        echo -e "${RED}Infrastructure deployment failed${NC}"
        exit 1
    fi
    
    echo ""
fi

# Deploy Frontend
if [ "$DEPLOY_FRONTEND" = true ]; then
    echo -e "${BLUE}=== Deploying Frontend ===${NC}"
    
    # Check if infrastructure outputs are available
    if [ ! -f "$INFRASTRUCTURE_DIR/terraform.tfstate" ]; then
        echo -e "${RED}Error: Infrastructure must be deployed first${NC}"
        echo "Run the script with --infrastructure-only first, or without --frontend-only"
        exit 1
    fi
    
    # Run the frontend deployment script
    "$SCRIPT_DIR/deploy-frontend.sh" \
        --environment "$ENVIRONMENT" \
        --region "$AWS_REGION" \
        --project "$PROJECT_NAME"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Frontend deployment completed successfully${NC}"
    else
        echo -e "${RED}Frontend deployment failed${NC}"
        exit 1
    fi
fi

# Final summary
echo ""
echo -e "${BLUE}=== Deployment Summary ===${NC}"

if [ -f "$INFRASTRUCTURE_DIR/terraform.tfstate" ]; then
    cd "$INFRASTRUCTURE_DIR"
    
    API_GATEWAY_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "Not available")
    FRONTEND_URL=$(terraform output -raw frontend_url 2>/dev/null || echo "Not available")
    S3_BUCKET=$(terraform output -raw frontend_bucket_name 2>/dev/null || echo "Not available")
    
    echo -e "${GREEN}API Gateway URL: $API_GATEWAY_URL${NC}"
    echo -e "${GREEN}Frontend URL: $FRONTEND_URL${NC}"
    echo -e "${GREEN}S3 Bucket: $S3_BUCKET${NC}"
    
    if [ "$DEPLOY_FRONTEND" = true ]; then
        echo ""
        echo -e "${YELLOW}Note: CloudFront propagation may take 5-15 minutes to complete globally.${NC}"
    fi
else
    echo -e "${YELLOW}No infrastructure state found${NC}"
fi

echo ""
echo -e "${GREEN}Deployment completed successfully!${NC}"

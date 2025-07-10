#!/bin/bash

# Frontend deployment script for AWS S3 and CloudFront

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
AWS_REGION="us-east-1"
PROJECT_NAME="contact-manager"

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
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  -e, --environment   Environment name (default: dev)"
      echo "  -r, --region        AWS region (default: us-east-1)"
      echo "  -p, --project       Project name (default: contact-manager)"
      echo "  -h, --help          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo -e "${GREEN}Starting frontend deployment...${NC}"
echo "Environment: $ENVIRONMENT"
echo "Region: $AWS_REGION"
echo "Project: $PROJECT_NAME"
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
INFRASTRUCTURE_DIR="$PROJECT_ROOT/infrastructure"

# Check if we're in the right directory
if [ ! -d "$FRONTEND_DIR" ] || [ ! -f "$FRONTEND_DIR/package.json" ]; then
    echo -e "${RED}Error: Frontend directory not found or invalid${NC}"
    echo "Expected: $FRONTEND_DIR"
    exit 1
fi

if [ ! -d "$INFRASTRUCTURE_DIR" ] || [ ! -f "$INFRASTRUCTURE_DIR/main.tf" ]; then
    echo -e "${RED}Error: Infrastructure directory not found or invalid${NC}"
    echo "Expected: $INFRASTRUCTURE_DIR"
    exit 1
fi

# Get API Gateway URL from Terraform output
echo -e "${YELLOW}Getting API Gateway URL from Terraform...${NC}"
cd "$INFRASTRUCTURE_DIR"

if [ ! -f "terraform.tfstate" ]; then
    echo -e "${RED}Error: Terraform state not found. Please run 'terraform apply' first.${NC}"
    exit 1
fi

API_GATEWAY_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")
S3_BUCKET=$(terraform output -raw frontend_bucket_name 2>/dev/null || echo "")
CLOUDFRONT_DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null || echo "")

if [ -z "$API_GATEWAY_URL" ] || [ -z "$S3_BUCKET" ] || [ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo -e "${RED}Error: Could not get required values from Terraform output${NC}"
    echo "API Gateway URL: $API_GATEWAY_URL"
    echo "S3 Bucket: $S3_BUCKET"
    echo "CloudFront Distribution ID: $CLOUDFRONT_DISTRIBUTION_ID"
    exit 1
fi

echo "API Gateway URL: $API_GATEWAY_URL"
echo "S3 Bucket: $S3_BUCKET"
echo "CloudFront Distribution ID: $CLOUDFRONT_DISTRIBUTION_ID"
echo ""

# Create environment file for frontend
echo -e "${YELLOW}Creating environment configuration...${NC}"
cd "$FRONTEND_DIR"

cat > .env.production << EOF
VITE_API_BASE_URL=${API_GATEWAY_URL}
VITE_ENVIRONMENT=${ENVIRONMENT}
EOF

echo "Created .env.production with API URL: ${API_GATEWAY_URL}"

# Install dependencies
echo -e "${YELLOW}Installing frontend dependencies...${NC}"
npm install

# Build the frontend
echo -e "${YELLOW}Building frontend...${NC}"
npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}Error: Build failed - dist directory not found${NC}"
    exit 1
fi

# Upload to S3
echo -e "${YELLOW}Uploading to S3 bucket: $S3_BUCKET${NC}"
aws s3 sync dist/ s3://$S3_BUCKET --delete --region $AWS_REGION

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully uploaded to S3${NC}"
else
    echo -e "${RED}Error: Failed to upload to S3${NC}"
    exit 1
fi

# Invalidate CloudFront cache
echo -e "${YELLOW}Invalidating CloudFront cache...${NC}"
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
    --paths "/*" \
    --region $AWS_REGION \
    --query 'Invalidation.Id' \
    --output text)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}CloudFront invalidation created: $INVALIDATION_ID${NC}"
    echo -e "${YELLOW}Waiting for invalidation to complete...${NC}"
    
    aws cloudfront wait invalidation-completed \
        --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
        --id $INVALIDATION_ID \
        --region $AWS_REGION
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}CloudFront invalidation completed${NC}"
    else
        echo -e "${YELLOW}Warning: Timeout waiting for invalidation to complete${NC}"
        echo "You can check the status manually in the AWS Console"
    fi
else
    echo -e "${RED}Error: Failed to create CloudFront invalidation${NC}"
    exit 1
fi

# Get the frontend URL
FRONTEND_URL=$(cd "$INFRASTRUCTURE_DIR" && terraform output -raw frontend_url)

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo -e "${GREEN}Frontend URL: $FRONTEND_URL${NC}"
echo -e "${GREEN}API URL: ${API_GATEWAY_URL}/${ENVIRONMENT}${NC}"
echo ""
echo "Note: CloudFront propagation may take 5-15 minutes to complete globally."

#!/bin/bash

# Script to destroy the Contact Manager infrastructure

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
FORCE=false

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
    -f|--force)
      FORCE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  -e, --environment   Environment name (default: dev)"
      echo "  -r, --region        AWS region (default: us-east-1)"
      echo "  -p, --project       Project name (default: contact-manager)"
      echo "  -f, --force         Skip confirmation prompt"
      echo "  -h, --help          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}=== Contact Manager Infrastructure Destruction ===${NC}"
echo "Environment: $ENVIRONMENT"
echo "Region: $AWS_REGION"
echo "Project: $PROJECT_NAME"
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INFRASTRUCTURE_DIR="$PROJECT_ROOT/infrastructure"

# Check if infrastructure directory exists
if [ ! -d "$INFRASTRUCTURE_DIR" ] || [ ! -f "$INFRASTRUCTURE_DIR/main.tf" ]; then
    echo -e "${RED}Error: Infrastructure directory not found${NC}"
    exit 1
fi

cd "$INFRASTRUCTURE_DIR"

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${YELLOW}No Terraform state found. Nothing to destroy.${NC}"
    exit 0
fi

# Show what will be destroyed
echo -e "${YELLOW}Running terraform plan to show what will be destroyed...${NC}"
terraform plan -destroy \
    -var="aws_region=$AWS_REGION" \
    -var="environment=$ENVIRONMENT" \
    -var="project_name=$PROJECT_NAME"

echo ""

# Confirmation prompt
if [ "$FORCE" = false ]; then
    echo -e "${RED}WARNING: This will destroy all infrastructure for this project!${NC}"
    echo -e "${RED}This action cannot be undone.${NC}"
    echo ""
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Operation cancelled.${NC}"
        exit 0
    fi
fi

# Empty S3 bucket first (if it exists)
echo -e "${YELLOW}Checking for S3 bucket to empty...${NC}"
S3_BUCKET=$(terraform output -raw frontend_bucket_name 2>/dev/null || echo "")

if [ -n "$S3_BUCKET" ]; then
    echo "Emptying S3 bucket: $S3_BUCKET"
    aws s3 rm s3://$S3_BUCKET --recursive --region $AWS_REGION 2>/dev/null || true
    echo "S3 bucket emptied"
fi

# Destroy infrastructure
echo -e "${YELLOW}Destroying infrastructure...${NC}"
terraform destroy \
    -var="aws_region=$AWS_REGION" \
    -var="environment=$ENVIRONMENT" \
    -var="project_name=$PROJECT_NAME" \
    -auto-approve

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Infrastructure destroyed successfully${NC}"
    
    # Clean up local files
    echo -e "${YELLOW}Cleaning up local files...${NC}"
    rm -f *.zip
    rm -f terraform.tfstate*
    rm -f .terraform.lock.hcl
    rm -rf .terraform/
    
    echo -e "${GREEN}Cleanup completed${NC}"
else
    echo -e "${RED}Infrastructure destruction failed${NC}"
    echo "You may need to manually clean up some resources in the AWS console"
    exit 1
fi

echo ""
echo -e "${GREEN}All resources have been destroyed successfully!${NC}"

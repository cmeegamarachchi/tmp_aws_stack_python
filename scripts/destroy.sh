#!/bin/bash

# Destroy infrastructure script for AWS Stack project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning "This will destroy all AWS resources created by this project!"
read -p "Are you sure you want to continue? (y/N): " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    print_status "Aborted."
    exit 0
fi

# Set working directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

print_status "Destroying infrastructure..."
cd "$TERRAFORM_DIR"

# Get S3 bucket name before destroying
S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")

# Empty S3 bucket if it exists
if [ ! -z "$S3_BUCKET_NAME" ]; then
    print_status "Emptying S3 bucket: $S3_BUCKET_NAME"
    aws s3 rm s3://$S3_BUCKET_NAME --recursive || true
fi

# Destroy infrastructure
terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    print_status "Infrastructure destroyed successfully!"
else
    print_error "Failed to destroy some resources. Please check the Terraform state and AWS console."
fi

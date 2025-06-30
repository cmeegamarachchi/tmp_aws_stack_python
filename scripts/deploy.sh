#!/bin/bash

# Build and deploy script for AWS Stack project

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

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install it first."
    exit 1
fi

print_status "Starting AWS Stack deployment..."

# Set working directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
API_DIR="$PROJECT_ROOT/api"
APP_DIR="$PROJECT_ROOT/app"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

print_status "Project root: $PROJECT_ROOT"

# Step 1: Build Lambda function
print_status "Building Lambda function..."
cd "$API_DIR"

if [ ! -f "package.json" ]; then
    print_error "package.json not found in API directory"
    exit 1
fi

npm install
npm run build
npm run package

if [ ! -f "lambda-deployment.zip" ]; then
    print_error "Lambda deployment package not created"
    exit 1
fi

print_status "Lambda function built successfully"

# Step 2: Deploy infrastructure with Terraform
print_status "Deploying infrastructure with Terraform..."
cd "$TERRAFORM_DIR"

terraform init
terraform plan
terraform apply -auto-approve

if [ $? -ne 0 ]; then
    print_error "Terraform deployment failed"
    exit 1
fi

print_status "Infrastructure deployed successfully"

# Step 3: Get Terraform outputs
print_status "Getting infrastructure outputs..."
USER_POOL_ID=$(terraform output -raw user_pool_id)
USER_POOL_CLIENT_ID=$(terraform output -raw user_pool_client_id)
IDENTITY_POOL_ID=$(terraform output -raw identity_pool_id)
API_GATEWAY_URL=$(terraform output -raw api_gateway_url)
S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
CLOUDFRONT_DOMAIN=$(terraform output -raw cloudfront_distribution_domain)
COGNITO_DOMAIN=$(terraform output -raw cognito_domain)
AUTH_URL=$(terraform output -raw auth_url)

print_status "Retrieved infrastructure details"

# Step 4: Create environment file for frontend
print_status "Creating environment configuration for frontend..."
cd "$APP_DIR"

cat > .env << EOF
VITE_USER_POOL_ID=$USER_POOL_ID
VITE_USER_POOL_CLIENT_ID=$USER_POOL_CLIENT_ID
VITE_OAUTH_DOMAIN=$COGNITO_DOMAIN
VITE_API_GATEWAY_URL=$API_GATEWAY_URL
EOF

print_status "Environment file created"

# Step 5: Build frontend
print_status "Building frontend application..."
npm install
npm run build

if [ ! -d "dist" ]; then
    print_error "Frontend build failed - dist directory not found"
    exit 1
fi

print_status "Frontend built successfully"

# Step 6: Deploy frontend to S3
print_status "Deploying frontend to S3..."
aws s3 sync dist/ s3://$S3_BUCKET_NAME --delete

if [ $? -ne 0 ]; then
    print_error "Frontend deployment to S3 failed"
    exit 1
fi

print_status "Frontend deployed to S3 successfully"

# Step 7: Invalidate CloudFront cache
print_status "Invalidating CloudFront cache..."
DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[0].DomainName=='$S3_BUCKET_NAME.s3-website-us-east-1.amazonaws.com'].Id" --output text)

if [ ! -z "$DISTRIBUTION_ID" ]; then
    aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
    print_status "CloudFront cache invalidated"
else
    print_warning "Could not find CloudFront distribution ID"
fi

print_status "Deployment completed successfully!"
echo ""
print_status "🎉 Application URLs:"
print_status "Frontend App: https://$CLOUDFRONT_DOMAIN"
print_status "API Gateway: $API_GATEWAY_URL"
echo ""
print_status "🔐 Authentication Details:"
print_status "Cognito Domain: $COGNITO_DOMAIN"
print_status "Auth URL: $AUTH_URL"
print_status "User Pool ID: $USER_POOL_ID"
print_status "User Pool Client ID: $USER_POOL_CLIENT_ID"
echo ""
print_status "🚀 Next Steps:"
echo "1. Visit your app at: https://$CLOUDFRONT_DOMAIN"
echo "2. Click 'Sign Up' to create a new account"
echo "3. Try the protected API endpoints from the dashboard"
echo ""
print_status "🔒 Security: All API requests are automatically authenticated by API Gateway!"

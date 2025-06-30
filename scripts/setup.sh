#!/bin/bash

# Setup script for AWS Stack project

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

print_status "Setting up AWS Stack project..."

# Set working directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
API_DIR="$PROJECT_ROOT/api"
APP_DIR="$PROJECT_ROOT/app"

# Install API dependencies
print_status "Installing API dependencies..."
cd "$API_DIR"
npm install

# Install Frontend dependencies
print_status "Installing Frontend dependencies..."
cd "$APP_DIR"
npm install

# Create environment file from example
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    print_status "Creating .env file from .env.example..."
    cp .env.example .env
    print_warning "Please update the .env file with your actual AWS resource IDs after running terraform"
fi

print_status "Setup completed successfully!"
print_status "Next steps:"
echo "1. Configure your AWS credentials: aws configure"
echo "2. Update terraform variables if needed in scripts/terraform/main.tf"
echo "3. Run the deployment script: ./scripts/deploy.sh"

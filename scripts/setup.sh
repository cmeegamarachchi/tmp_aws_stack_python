#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking prerequisites..."
    
    local missing_deps=()
    
    if ! command_exists node; then
        missing_deps+=("Node.js")
    fi
    
    if ! command_exists npm; then
        missing_deps+=("npm")
    fi
    
    if ! command_exists terraform; then
        missing_deps+=("Terraform")
    fi
    
    if ! command_exists aws; then
        missing_deps+=("AWS CLI")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_error "Please install the missing dependencies and try again."
        exit 1
    fi
    
    print_status "All prerequisites are installed."
}

# Setup API dependencies
setup_api() {
    print_header "Setting up API dependencies..."
    
    cd api || exit 1
    
    if [ ! -f "package.json" ]; then
        print_error "package.json not found in api directory"
        exit 1
    fi
    
    print_status "Installing API dependencies..."
    npm install
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install API dependencies"
        exit 1
    fi
    
    print_status "Building API..."
    npm run build
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build API"
        exit 1
    fi
    
    cd ..
    print_status "API setup completed."
}

# Setup React app dependencies
setup_app() {
    print_header "Setting up React app dependencies..."
    
    cd app || exit 1
    
    if [ ! -f "package.json" ]; then
        print_error "package.json not found in app directory"
        exit 1
    fi
    
    print_status "Installing React app dependencies..."
    npm install
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install React app dependencies"
        exit 1
    fi
    
    cd ..
    print_status "React app setup completed."
}

# Initialize Terraform
setup_terraform() {
    print_header "Setting up Terraform..."
    
    cd infrastructure || exit 1
    
    print_status "Initializing Terraform..."
    terraform init
    
    if [ $? -ne 0 ]; then
        print_error "Failed to initialize Terraform"
        exit 1
    fi
    
    print_status "Validating Terraform configuration..."
    terraform validate
    
    if [ $? -ne 0 ]; then
        print_error "Terraform configuration is invalid"
        exit 1
    fi
    
    cd ..
    print_status "Terraform setup completed."
}

# Main setup function
main() {
    print_header "=== Contact Management System Setup ==="
    
    check_prerequisites
    setup_api
    setup_app
    setup_terraform
    
    print_header "=== Setup completed successfully! ==="
    echo
    print_status "Next steps:"
    echo "  1. For local development: ./scripts/dev.sh"
    echo "  2. To deploy to AWS: ./scripts/deploy.sh"
    echo "  3. To start local development servers: ./scripts/start-dev.sh"
}

# Run main function
main "$@"

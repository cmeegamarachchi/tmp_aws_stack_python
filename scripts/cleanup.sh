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

# Destroy Terraform infrastructure
destroy_infrastructure() {
    print_header "Destroying infrastructure with Terraform..."
    
    cd infrastructure || exit 1
    
    print_warning "This will destroy all AWS resources created by Terraform."
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Destroy cancelled"
        exit 0
    fi
    
    # Destroy the infrastructure
    print_status "Destroying Terraform infrastructure..."
    terraform destroy -var="environment=$ENVIRONMENT" -auto-approve
    
    if [ $? -ne 0 ]; then
        print_error "Terraform destroy failed"
        exit 1
    fi
    
    cd ..
    print_status "Infrastructure destroyed successfully"
}

# Clean local build artifacts
clean_local() {
    print_header "Cleaning local build artifacts..."
    
    # Clean API build
    if [ -d "api/dist" ]; then
        rm -rf api/dist
        print_status "Cleaned API build artifacts"
    fi
    
    if [ -d "api/node_modules" ]; then
        rm -rf api/node_modules
        print_status "Cleaned API node_modules"
    fi
    
    # Clean React app build
    if [ -d "app/dist" ]; then
        rm -rf app/dist
        print_status "Cleaned React app build artifacts"
    fi
    
    if [ -d "app/node_modules" ]; then
        rm -rf app/node_modules
        print_status "Cleaned React app node_modules"
    fi
    
    # Clean Terraform artifacts
    if [ -d "infrastructure/.terraform" ]; then
        rm -rf infrastructure/.terraform
        print_status "Cleaned Terraform cache"
    fi
    
    if [ -f "infrastructure/terraform.tfstate" ]; then
        rm -f infrastructure/terraform.tfstate
        print_status "Cleaned Terraform state file"
    fi
    
    if [ -f "infrastructure/terraform.tfstate.backup" ]; then
        rm -f infrastructure/terraform.tfstate.backup
        print_status "Cleaned Terraform state backup"
    fi
    
    if [ -d "infrastructure/lambda_packages" ]; then
        rm -rf infrastructure/lambda_packages
        print_status "Cleaned Lambda packages"
    fi
}

# Main cleanup function
main() {
    print_header "=== Cleaning up Contact Management System ==="
    print_status "Environment: $ENVIRONMENT"
    echo
    
    case "${2:-all}" in
        "local")
            clean_local
            ;;
        "aws")
            destroy_infrastructure
            ;;
        "all")
            destroy_infrastructure
            clean_local
            ;;
        *)
            print_error "Invalid cleanup option. Use: local, aws, or all"
            echo "Usage: $0 [environment] [local|aws|all]"
            exit 1
            ;;
    esac
    
    print_header "=== Cleanup completed! ==="
}

# Run main function
main "$@"

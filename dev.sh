#!/bin/bash

# Contact Manager - Development Scripts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function for colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists node; then
        print_error "Node.js is not installed"
        exit 1
    fi
    
    if ! command_exists npm; then
        print_error "npm is not installed"
        exit 1
    fi
    
    if ! command_exists python3; then
        print_error "Python 3 is not installed"
        exit 1
    fi
    
    if ! command_exists sam; then
        print_warning "SAM CLI is not installed - backend testing will not be available"
    fi
    
    if ! command_exists terraform; then
        print_warning "Terraform is not installed - infrastructure deployment will not be available"
    fi
    
    print_status "Prerequisites check completed"
}

# Setup frontend
setup_frontend() {
    print_status "Setting up frontend..."
    cd frontend
    
    if [ ! -f "package.json" ]; then
        print_error "package.json not found in frontend directory"
        exit 1
    fi
    
    npm install
    
    # Copy environment file if it doesn't exist
    if [ ! -f ".env.local" ]; then
        cp .env.example .env.local
        print_status "Created .env.local from .env.example"
    fi
    
    cd ..
    print_status "Frontend setup completed"
}

# Start frontend development server
start_frontend() {
    print_status "Starting frontend development server..."
    cd frontend
    npm run dev &
    FRONTEND_PID=$!
    cd ..
    print_status "Frontend server started (PID: $FRONTEND_PID)"
}

# Start backend with SAM
start_backend() {
    if ! command_exists sam; then
        print_error "SAM CLI is required to start the backend"
        exit 1
    fi
    
    print_status "Starting backend with SAM..."
    cd backend
    
    # Set default AWS region for SAM
    export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
    
    print_status "Building SAM application..."
    sam build
    
    print_status "Starting local API..."
    sam local start-api --port 3001 &
    BACKEND_PID=$!
    cd ..
    print_status "Backend API started on port 3001 (PID: $BACKEND_PID)"
}

# Deploy infrastructure
deploy_infrastructure() {
    if ! command_exists terraform; then
        print_error "Terraform is required to deploy infrastructure"
        exit 1
    fi
    
    print_status "Deploying infrastructure with Terraform..."
    cd infrastructure
    
    if [ ! -f ".terraform/terraform.tfstate" ]; then
        print_status "Initializing Terraform..."
        terraform init
    fi
    
    print_status "Planning deployment..."
    terraform plan
    
    read -p "Do you want to apply these changes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply
        print_status "Infrastructure deployed successfully"
    else
        print_status "Deployment cancelled"
    fi
    
    cd ..
}

# Destroy infrastructure
destroy_infrastructure() {
    if ! command_exists terraform; then
        print_error "Terraform is required to destroy infrastructure"
        exit 1
    fi
    
    cd infrastructure
    
    print_warning "This will destroy all infrastructure resources!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform destroy
        print_status "Infrastructure destroyed successfully"
    else
        print_status "Destruction cancelled"
    fi
    
    cd ..
}

# Show help
show_help() {
    echo "Contact Manager - Development Scripts"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup           Setup the entire project"
    echo "  frontend        Start frontend development server"
    echo "  backend         Start backend with SAM local"
    echo "  dev             Start both frontend and backend"
    echo "  deploy          Deploy infrastructure to AWS"
    echo "  destroy         Destroy AWS infrastructure"
    echo "  check           Check prerequisites"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup        # Setup the project for the first time"
    echo "  $0 dev          # Start local development environment"
    echo "  $0 deploy       # Deploy to AWS"
}

# Cleanup function
cleanup() {
    if [ ! -z "$FRONTEND_PID" ]; then
        print_status "Stopping frontend server (PID: $FRONTEND_PID)"
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$BACKEND_PID" ]; then
        print_status "Stopping backend server (PID: $BACKEND_PID)"
        kill $BACKEND_PID 2>/dev/null || true
    fi
}

# Trap cleanup function on script exit
trap cleanup EXIT

# Main script logic
case "${1:-help}" in
    setup)
        check_prerequisites
        setup_frontend
        print_status "Project setup completed successfully!"
        print_status "Run '$0 dev' to start development servers"
        ;;
    frontend)
        start_frontend
        print_status "Frontend is running on http://localhost:5173"
        print_status "Press Ctrl+C to stop"
        wait
        ;;
    backend)
        start_backend
        print_status "Backend API is running on http://localhost:3001"
        print_status "Press Ctrl+C to stop"
        wait
        ;;
    dev)
        start_backend
        sleep 5  # Give backend time to start
        start_frontend
        print_status "Development environment is ready!"
        print_status "Frontend: http://localhost:5173"
        print_status "Backend API: http://localhost:3001"
        print_status "Press Ctrl+C to stop both servers"
        wait
        ;;
    deploy)
        deploy_infrastructure
        ;;
    destroy)
        destroy_infrastructure
        ;;
    check)
        check_prerequisites
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

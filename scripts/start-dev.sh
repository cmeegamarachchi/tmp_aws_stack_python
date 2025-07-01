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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to start the API server
start_api() {
    print_header "Starting API server..."
    
    cd api || exit 1
    
    print_status "Starting API server on http://localhost:3001"
    npm run dev &
    API_PID=$!
    
    cd ..
    
    # Wait a moment for the server to start
    sleep 3
    
    # Check if the server is running
    if curl -s http://localhost:3001/health > /dev/null; then
        print_status "API server is running successfully"
    else
        print_error "API server failed to start"
        kill $API_PID 2>/dev/null
        exit 1
    fi
}

# Function to start the React development server
start_app() {
    print_header "Starting React development server..."
    
    cd app || exit 1
    
    print_status "Starting React app on http://localhost:5173"
    npm run dev &
    APP_PID=$!
    
    cd ..
    
    # Wait a moment for the server to start
    sleep 5
}

# Function to handle cleanup on exit
cleanup() {
    print_header "Stopping development servers..."
    
    if [ ! -z "$API_PID" ]; then
        kill $API_PID 2>/dev/null
        print_status "API server stopped"
    fi
    
    if [ ! -z "$APP_PID" ]; then
        kill $APP_PID 2>/dev/null
        print_status "React app stopped"
    fi
    
    # Kill any remaining node processes on the expected ports
    pkill -f "node.*3001" 2>/dev/null
    pkill -f "node.*5173" 2>/dev/null
    
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main function
main() {
    print_header "=== Starting Development Environment ==="
    
    # Check if ports are available
    if lsof -i :3001 >/dev/null 2>&1; then
        print_error "Port 3001 is already in use. Please stop the process using this port."
        exit 1
    fi
    
    if lsof -i :5173 >/dev/null 2>&1; then
        print_error "Port 5173 is already in use. Please stop the process using this port."
        exit 1
    fi
    
    start_api
    start_app
    
    print_header "=== Development servers are running ==="
    echo
    print_status "API Server: http://localhost:3001"
    print_status "React App: http://localhost:5173"
    echo
    print_status "API Endpoints:"
    echo "  - GET http://localhost:3001/contacts"
    echo "  - GET http://localhost:3001/countries"
    echo "  - GET http://localhost:3001/health"
    echo
    print_status "Press Ctrl+C to stop all servers"
    
    # Wait for user to interrupt
    while true; do
        sleep 1
    done
}

# Run main function
main "$@"

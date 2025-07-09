#!/bin/bash

# Test script for Contact Manager API

API_URL="http://localhost:3001"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Test if API is running
test_api_health() {
    print_test "Testing API health..."
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/contacts")
    
    if [ "$response" = "200" ]; then
        print_success "API is responding"
        return 0
    else
        print_error "API is not responding (HTTP $response)"
        return 1
    fi
}

# Test listing contacts
test_list_contacts() {
    print_test "Testing list contacts..."
    
    response=$(curl -s "$API_URL/contacts")
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "List contacts works"
        return 0
    else
        print_error "List contacts failed"
        echo "Response: $response"
        return 1
    fi
}

# Test creating a contact
test_create_contact() {
    print_test "Testing create contact..."
    
    response=$(curl -s -X POST "$API_URL/contacts" \
        -H "Content-Type: application/json" \
        -d '{
            "first_name": "Test",
            "last_name": "User",
            "email": "test@example.com",
            "street_address": "123 Test St",
            "city": "Test City",
            "country": "Test Country"
        }')
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "Create contact works"
        # Extract ID for future tests
        CONTACT_ID=$(echo "$response" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
        return 0
    else
        print_error "Create contact failed"
        echo "Response: $response"
        return 1
    fi
}

# Test getting a specific contact
test_get_contact() {
    if [ -z "$CONTACT_ID" ]; then
        print_error "No contact ID available for testing"
        return 1
    fi
    
    print_test "Testing get contact..."
    
    response=$(curl -s "$API_URL/contacts/$CONTACT_ID")
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "Get contact works"
        return 0
    else
        print_error "Get contact failed"
        echo "Response: $response"
        return 1
    fi
}

# Test updating a contact
test_update_contact() {
    if [ -z "$CONTACT_ID" ]; then
        print_error "No contact ID available for testing"
        return 1
    fi
    
    print_test "Testing update contact..."
    
    response=$(curl -s -X PUT "$API_URL/contacts/$CONTACT_ID" \
        -H "Content-Type: application/json" \
        -d '{
            "first_name": "Updated",
            "last_name": "User",
            "email": "updated@example.com",
            "street_address": "456 Updated St",
            "city": "Updated City",
            "country": "Updated Country"
        }')
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "Update contact works"
        return 0
    else
        print_error "Update contact failed"
        echo "Response: $response"
        return 1
    fi
}

# Test deleting a contact
test_delete_contact() {
    if [ -z "$CONTACT_ID" ]; then
        print_error "No contact ID available for testing"
        return 1
    fi
    
    print_test "Testing delete contact..."
    
    response=$(curl -s -X DELETE "$API_URL/contacts/$CONTACT_ID")
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "Delete contact works"
        return 0
    else
        print_error "Delete contact failed"
        echo "Response: $response"
        return 1
    fi
}

# Main test execution
main() {
    echo "Contact Manager API Tests"
    echo "========================="
    echo ""
    
    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl is required for testing"
        exit 1
    fi
    
    # Run tests
    test_api_health || exit 1
    test_list_contacts || exit 1
    test_create_contact || exit 1
    test_get_contact || exit 1
    test_update_contact || exit 1
    test_delete_contact || exit 1
    
    echo ""
    print_success "All tests passed!"
}

# Run main function
main "$@"

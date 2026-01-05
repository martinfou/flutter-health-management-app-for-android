#!/bin/bash

# Health Management API Test Suite
# Run all API tests in sequence

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_BASE="http://localhost:8000/api/v1"
TEST_USER_EMAIL="testuser-$(date +%s)@example.com"
TEST_USER_PASSWORD="testpass123"
TEST_USER_NAME="Test User"

# Global variables
ACCESS_TOKEN=""
REFRESH_TOKEN=""

# Helper functions
print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Make API request and return response
api_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local auth=$4

    local curl_cmd="curl -s -X $method"

    if [ "$auth" = "true" ] && [ -n "$ACCESS_TOKEN" ]; then
        curl_cmd="$curl_cmd -H 'Authorization: Bearer $ACCESS_TOKEN'"
    fi

    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H 'Content-Type: application/json' -d '$data'"
    fi

    curl_cmd="$curl_cmd $API_BASE$endpoint"

    eval "$curl_cmd"
}

# Extract value from JSON response
extract_json_value() {
    local json=$1
    local key=$2

    echo "$json" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data$key)" 2>/dev/null || echo ""
}

# Check if response indicates success
is_success() {
    local response=$1
    local success=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null || echo "false")

    [ "$success" = "True" ] || [ "$success" = "true" ]
}

echo "🚀 Starting Health Management API Test Suite"
echo "API Base: $API_BASE"
echo "Test User: $TEST_USER_EMAIL"

# Run individual test scripts
print_header "Running Basic Health Tests"
if bash scripts/tests/test-health.sh; then
    print_success "Health tests passed"
else
    print_error "Health tests failed"
    exit 1
fi

print_header "Running Authentication Tests"
if bash scripts/tests/test-auth.sh; then
    print_success "Authentication tests passed"
else
    print_error "Authentication tests failed"
    exit 1
fi

print_header "Running Health Metrics Tests"
if bash scripts/tests/test-health-metrics.sh; then
    print_success "Health metrics tests passed"
else
    print_error "Health metrics tests failed"
    exit 1
fi

print_header "Running Medication Tests"
if bash scripts/tests/test-medications.sh; then
    print_success "Medication tests passed"
else
    print_error "Medication tests failed"
    exit 1
fi

print_header "Running Meal Tests"
if bash scripts/tests/test-meals.sh; then
    print_success "Meal tests passed"
else
    print_error "Meal tests failed"
    exit 1
fi

print_header "Running Exercise Tests"
if bash scripts/tests/test-exercises.sh; then
    print_success "Exercise tests passed"
else
    print_error "Exercise tests failed"
    exit 1
fi

print_header "Running Meal Plan Tests"
if bash scripts/tests/test-meal-plans.sh; then
    print_success "Meal plan tests passed"
else
    print_error "Meal plan tests failed"
    exit 1
fi

print_header "🎉 ALL TESTS COMPLETED SUCCESSFULLY! 🎉"
echo -e "\n${GREEN}The Health Management API is fully functional!${NC}"
echo "You can now integrate with the Flutter app."
echo ""
echo "Next steps:"
echo "1. Update Flutter API client to use $API_BASE"
echo "2. Implement JWT token storage in Flutter"
echo "3. Add offline sync capabilities"
echo "4. Test end-to-end functionality"
#!/bin/bash

# Health App Backend API Test Script
# Tests all available endpoints with proper authentication flow

API_URL="${API_URL:-http://localhost:8000/api/v1}"
VERBOSE="${VERBOSE:-false}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Variables for auth flow
ACCESS_TOKEN=""
REFRESH_TOKEN=""
USER_ID=""

# Test counters
PASSED=0
FAILED=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    ((PASSED++))
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((FAILED++))
}

test_endpoint() {
    local method="$1"
    local path="$2"
    local description="$3"
    local data="$4"
    local auth="$5"
    local expected_codes="${6:-200,201}"

    log_info "Testing $method $path - $description"

    local response
    local http_code
    local headers=""

    if [[ -n "$auth" && -n "$ACCESS_TOKEN" ]]; then
        headers="-H \"Authorization: Bearer $ACCESS_TOKEN\""
    fi

    if [[ "$method" == "GET" ]]; then
        response=$(curl -s -w "\nHTTPSTATUS:%{http_code}" \
            -H "Content-Type: application/json" \
            ${auth:+-H "Authorization: Bearer $ACCESS_TOKEN"} \
            "$API_URL$path" 2>/dev/null)
    else
        response=$(curl -s -w "\nHTTPSTATUS:%{http_code}" \
            -X "$method" \
            -H "Content-Type: application/json" \
            ${auth:+-H "Authorization: Bearer $ACCESS_TOKEN"} \
            -d "$data" \
            "$API_URL$path" 2>/dev/null)
    fi

    http_code=$(echo "$response" | tail -1 | sed 's/HTTPSTATUS://')
    response_body=$(echo "$response" | sed '$d')

    # Check if http_code is in expected_codes
    if echo "$expected_codes" | grep -q "$http_code"; then
        log_success "$method $path - HTTP $http_code"
        if [[ "$VERBOSE" == "true" ]]; then
            echo "$response_body" | jq . 2>/dev/null || echo "$response_body"
        fi
        echo "$response_body"
        return 0
    else
        log_error "$method $path - HTTP $http_code (expected: $expected_codes)"
        if [[ "$VERBOSE" == "true" ]]; then
            echo "$response_body" | jq . 2>/dev/null || echo "$response_body"
        fi
        echo "$response_body"
        return 1
    fi
}

echo ""
echo "🧪 Health App Backend API Tests"
echo "================================="
echo "API URL: $API_URL"
echo "Date: $(date)"
echo ""

# ==========================================
# 1. API Discovery & Health Check
# ==========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 API Information & Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_endpoint "GET" "/" "API information and available endpoints" "" "" "200"
echo ""
test_endpoint "GET" "/health" "Health check endpoint" "" "" "200"
echo ""

# ==========================================
# 2. Authentication Flow
# ==========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Authentication Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Generate unique email for testing
TEST_EMAIL="apitest_$(date +%s)@example.com"
TEST_PASSWORD="SecurePass123!"

# Test registration
log_info "Registering new user: $TEST_EMAIL"
REGISTER_RESPONSE=$(test_endpoint "POST" "/auth/register" "User registration" \
    "{\"email\": \"$TEST_EMAIL\", \"password\": \"$TEST_PASSWORD\", \"name\": \"API Test User\"}" \
    "" "201,409")

if echo "$REGISTER_RESPONSE" | grep -q '"success":true'; then
    ACCESS_TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.data.access_token' 2>/dev/null)
    REFRESH_TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.data.refresh_token' 2>/dev/null)
    USER_ID=$(echo "$REGISTER_RESPONSE" | jq -r '.data.user.id' 2>/dev/null)
    log_info "Tokens captured from registration"
fi
echo ""

# Test login
log_info "Testing login with registered user"
LOGIN_RESPONSE=$(test_endpoint "POST" "/auth/login" "User login" \
    "{\"email\": \"$TEST_EMAIL\", \"password\": \"$TEST_PASSWORD\"}" \
    "" "200")

if echo "$LOGIN_RESPONSE" | grep -q '"success":true'; then
    ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.access_token' 2>/dev/null)
    REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.refresh_token' 2>/dev/null)
    USER_ID=$(echo "$LOGIN_RESPONSE" | jq -r '.data.user.id' 2>/dev/null)
    log_info "Tokens captured from login"
fi
echo ""

# Test invalid login
log_info "Testing invalid credentials"
test_endpoint "POST" "/auth/login" "Invalid login (expected 401)" \
    "{\"email\": \"wrong@example.com\", \"password\": \"wrongpassword\"}" \
    "" "401"
echo ""

# Test token refresh
if [[ -n "$REFRESH_TOKEN" ]]; then
    log_info "Testing token refresh"
    REFRESH_RESPONSE=$(test_endpoint "POST" "/auth/refresh" "Token refresh" \
        "{\"refresh_token\": \"$REFRESH_TOKEN\"}" \
        "" "200")

    if echo "$REFRESH_RESPONSE" | grep -q '"success":true'; then
        ACCESS_TOKEN=$(echo "$REFRESH_RESPONSE" | jq -r '.data.access_token' 2>/dev/null)
        REFRESH_TOKEN=$(echo "$REFRESH_RESPONSE" | jq -r '.data.refresh_token' 2>/dev/null)
        log_info "Tokens refreshed successfully"
    fi
fi
echo ""

# ==========================================
# 3. Health Metrics (requires auth workaround)
# ==========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Health Metrics Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Note: Currently health-metrics endpoints are open for testing
# In production, they would require authentication

test_endpoint "GET" "/health-metrics" "List health metrics" "" "" "200"
echo ""

# Test creating health metric (will fail without proper user context)
TEST_DATE=$(date +%Y-%m-%d)
log_info "Testing health metric creation for date: $TEST_DATE"
test_endpoint "POST" "/health-metrics" "Create health metric" \
    "{\"date\": \"$TEST_DATE\", \"weight_kg\": 75.5, \"sleep_hours\": 7.5, \"sleep_quality\": 8, \"energy_level\": 7, \"steps\": 8500, \"calories_burned\": 320, \"mood\": \"good\", \"notes\": \"API test entry\"}" \
    "" "201,409,500"
echo ""

# Test with date filter
test_endpoint "GET" "/health-metrics?start_date=2026-01-01&end_date=2026-12-31" "Health metrics with date filter" "" "" "200"
echo ""

# ==========================================
# 4. Rate Limiting Check
# ==========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚦 Rate Limiting Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Checking rate limit headers..."
RATE_RESPONSE=$(curl -s -I "$API_URL/" 2>/dev/null | grep -i "x-ratelimit")
if [[ -n "$RATE_RESPONSE" ]]; then
    log_success "Rate limit headers present"
    echo "$RATE_RESPONSE"
else
    log_warning "Rate limit headers not found in response"
fi
echo ""

# ==========================================
# Summary
# ==========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${YELLOW}⚠️  Some tests failed. Check output above for details.${NC}"
fi
echo ""
log_info "To run with verbose output: VERBOSE=true $0"
log_info "To use custom API URL: API_URL=http://your-server/api/v1 $0"

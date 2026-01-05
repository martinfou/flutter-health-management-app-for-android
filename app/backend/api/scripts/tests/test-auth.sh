#!/bin/bash

# Authentication Tests
# Tests user registration, login, and token refresh

API_BASE="http://localhost:8000/api/v1"
TEST_USER_EMAIL="testuser-$(date +%s)@example.com"
TEST_USER_PASSWORD="testpass123"
TEST_USER_NAME="Test User"

echo "Testing Authentication Endpoints..."

# Helper function to extract JSON values
extract_value() {
    local json=$1
    local key=$2
    echo "$json" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data$key)" 2>/dev/null || echo ""
}

# Test 1: User Registration
echo -e "\n1. Testing User Registration:"
register_data="{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\",\"name\":\"$TEST_USER_NAME\"}"
response=$(curl -s -X POST "$API_BASE/auth/register" \
    -H "Content-Type: application/json" \
    -d "$register_data")

if echo "$response" | grep -q 'success.*true' && echo "$response" | grep -q 'user'; then
    echo "✓ User registration successful"
else
    echo "✗ User registration failed"
    echo "Response: $response"
    exit 1
fi

# Test 2: User Login
echo -e "\n2. Testing User Login:"
login_data="{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\"}"
response=$(curl -s -X POST "$API_BASE/auth/login" \
    -H "Content-Type: application/json" \
    -d "$login_data")

if echo "$response" | grep -q 'success.*true' && echo "$response" | grep -q 'access_token'; then
    echo "✓ User login successful"
    ACCESS_TOKEN=$(extract_value "$response" "['data']['access_token']")
    REFRESH_TOKEN=$(extract_value "$response" "['data']['refresh_token']")
else
    echo "✗ User login failed"
    echo "Response: $response"
    exit 1
fi

# Test 3: Access Protected Endpoint
echo -e "\n3. Testing Protected Endpoint Access:"
response=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "$API_BASE/health-metrics")

if echo "$response" | grep -q 'success.*true'; then
    echo "✓ Protected endpoint access successful"
else
    echo "✗ Protected endpoint access failed"
    echo "Response: $response"
    exit 1
fi

# Test 4: Invalid Token
echo -e "\n4. Testing Invalid Token Rejection:"
response=$(curl -s -H "Authorization: Bearer invalid_token" "$API_BASE/health-metrics")

if echo "$response" | grep -q 'success.*false' && echo "$response" | grep -q 'message'; then
    echo "✓ Invalid token properly rejected"
else
    echo "✗ Invalid token not rejected properly"
    echo "Response: $response"
    exit 1
fi

# Test 5: No Token
echo -e "\n5. Testing No Token Rejection:"
response=$(curl -s "$API_BASE/health-metrics")

if echo "$response" | grep -q 'success.*false' && echo "$response" | grep -q 'message'; then
    echo "✓ No token properly rejected"
else
    echo "✗ No token not rejected properly"
    echo "Response: $response"
    exit 1
fi

# Test 6: Token Refresh
echo -e "\n6. Testing Token Refresh:"
refresh_data="{\"refresh_token\":\"$REFRESH_TOKEN\"}"
response=$(curl -s -X POST "$API_BASE/auth/refresh" \
    -H "Content-Type: application/json" \
    -d "$refresh_data")

if echo "$response" | grep -q 'success.*true' && echo "$response" | grep -q 'access_token'; then
    echo "✓ Token refresh successful"
    NEW_ACCESS_TOKEN=$(extract_value "$response" "['data']['access_token']")
    NEW_REFRESH_TOKEN=$(extract_value "$response" "['data']['refresh_token']")

    # Test new token
    response=$(curl -s -H "Authorization: Bearer $NEW_ACCESS_TOKEN" "$API_BASE/health-metrics")
    if echo "$response" | grep -q 'success.*true'; then
        echo "✓ New access token working"
    else
        echo "✗ New access token not working"
        exit 1
    fi
else
    echo "✗ Token refresh failed"
    echo "Response: $response"
    exit 1
fi

# Test 7: Duplicate Email Registration
echo -e "\n7. Testing Duplicate Email Rejection:"
response=$(curl -s -X POST "$API_BASE/auth/register" \
    -H "Content-Type: application/json" \
    -d "$register_data")

if echo "$response" | grep -q 'success.*false' && echo "$response" | grep -q 'message'; then
    echo "✓ Duplicate email properly rejected"
else
    echo "✗ Duplicate email not rejected properly"
    echo "Response: $response"
    exit 1
fi

# Export tokens for other test scripts
echo "export ACCESS_TOKEN='$NEW_ACCESS_TOKEN'" > /tmp/api_test_tokens.sh
echo "export REFRESH_TOKEN='$NEW_REFRESH_TOKEN'" >> /tmp/api_test_tokens.sh
echo "export TEST_USER_EMAIL='$TEST_USER_EMAIL'" >> /tmp/api_test_tokens.sh

echo -e "\n✅ All authentication tests passed!"
echo "Tokens saved to /tmp/api_test_tokens.sh for other tests"
#!/bin/bash

# Health Check Tests
# Tests basic API health and availability

API_BASE="http://localhost:8000/api/v1"

echo "Testing API Health and Basic Endpoints..."

# Test 1: API Info
echo -e "\n1. Testing API Info (/):"
response=$(curl -s "$API_BASE/")
if echo "$response" | grep -q '"success":true'; then
    echo "✓ API Info endpoint working"
else
    echo "✗ API Info endpoint failed"
    echo "Response: $response"
    exit 1
fi

# Test 2: Health Check
echo -e "\n2. Testing Health Check (/health):"
response=$(curl -s "$API_BASE/health")
if echo "$response" | grep -q '"success":true' && echo "$response" | grep -q '"status":"healthy"'; then
    echo "✓ Health check endpoint working"
    echo "✓ Database connection confirmed"
else
    echo "✗ Health check endpoint failed"
    echo "Response: $response"
    exit 1
fi

# Test 3: Invalid Endpoint
echo -e "\n3. Testing Invalid Endpoint (should return 404):"
response=$(curl -s "$API_BASE/nonexistent")
if echo "$response" | grep -q "Not found"; then
    echo "✓ Error handling working correctly (404 response)"
else
    echo "✗ Error handling not working properly"
    echo "Response: $response"
    exit 1
fi

# Test 4: CORS Headers
echo -e "\n4. Testing CORS Headers:"
response=$(curl -s -I "$API_BASE/health")
if echo "$response" | grep -q "Access-Control-Allow-Origin"; then
    echo "✓ CORS headers configured"
else
    echo "✗ CORS headers missing"
    echo "Response: $response"
    exit 1
fi

echo -e "\n✅ All health tests passed!"
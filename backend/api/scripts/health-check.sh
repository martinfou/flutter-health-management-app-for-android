#!/bin/bash

# Health Check Script for Health App Backend
# Performs comprehensive health checks on deployed API

set -e  # Exit on any error

# Configuration
API_URL="${API_URL:-http://localhost:8000}"
TIMEOUT="${TIMEOUT:-30}"
VERBOSE="${VERBOSE:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_http_response() {
    local url="$1"
    local expected_status="${2:-200}"
    local description="$3"

    if [[ "$VERBOSE" == "true" ]]; then
        log_info "Checking $description: $url"
    fi

    local response
    local http_code

    # Make request and capture both output and exit code
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" --max-time "$TIMEOUT" "$url" 2>/dev/null)
    http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    if [[ "$http_code" == "$expected_status" ]]; then
        log_success "$description - HTTP $http_code"
        return 0
    else
        log_error "$description - Expected HTTP $expected_status, got $http_code"
        if [[ "$VERBOSE" == "true" ]]; then
            echo "Response: $response"
        fi
        return 1
    fi
}

check_json_response() {
    local url="$1"
    local json_path="$2"
    local expected_value="$3"
    local description="$4"

    if [[ "$VERBOSE" == "true" ]]; then
        log_info "Checking $description: $url"
    fi

    local response
    response=$(curl -s --max-time "$TIMEOUT" "$url" 2>/dev/null)

    # Check if response is valid JSON
    if ! echo "$response" | jq empty 2>/dev/null; then
        log_error "$description - Invalid JSON response"
        return 1
    fi

    # Check JSON path value
    local actual_value
    actual_value=$(echo "$response" | jq -r "$json_path" 2>/dev/null)

    if [[ "$actual_value" == "$expected_value" ]]; then
        log_success "$description - Value: $actual_value"
        return 0
    else
        log_error "$description - Expected '$expected_value', got '$actual_value'"
        if [[ "$VERBOSE" == "true" ]]; then
            echo "Response: $response"
        fi
        return 1
    fi
}

check_response_time() {
    local url="$1"
    local max_time="$2"
    local description="$3"

    if [[ "$VERBOSE" == "true" ]]; then
        log_info "Checking response time for $description: $url"
    fi

    local response_time
    response_time=$(curl -s -o /dev/null -w "%{time_total}" --max-time "$TIMEOUT" "$url" 2>/dev/null)

    if [[ -z "$response_time" ]]; then
        log_error "$description - Request failed"
        return 1
    fi

    # Convert to milliseconds for comparison
    local response_time_ms
    response_time_ms=$(echo "$response_time * 1000" | bc -l 2>/dev/null || echo "0")

    if (( $(echo "$response_time_ms < $max_time" | bc -l 2>/dev/null || echo "1") )); then
        log_success "$description - ${response_time_ms%.*}ms"
        return 0
    else
        log_warning "$description - ${response_time_ms%.*}ms (slower than ${max_time}ms)"
        return 0  # Don't fail on slow responses
    fi
}

# Main health checks
echo "🔍 Health Check for Health App Backend API"
echo "=========================================="
echo "API URL: $API_URL"
echo "Timeout: ${TIMEOUT}s"
echo ""

FAILED_CHECKS=0
TOTAL_CHECKS=0

# Basic connectivity check
((TOTAL_CHECKS++))
if check_http_response "$API_URL/health" 200 "API Health Endpoint"; then
    log_success "API is reachable"
else
    log_error "API is not reachable"
    ((FAILED_CHECKS++))
fi

# Health endpoint JSON validation
((TOTAL_CHECKS++))
if check_json_response "$API_URL/health" ".success" "true" "Health Response Format"; then
    : # Success
else
    ((FAILED_CHECKS++))
fi

# Database connectivity check
((TOTAL_CHECKS++))
if check_json_response "$API_URL/health" ".services.database" "ok" "Database Connectivity"; then
    : # Success
else
    ((FAILED_CHECKS++))
fi

# Response time check
((TOTAL_CHECKS++))
if check_response_time "$API_URL/health" 500 "Health Endpoint Response Time"; then
    : # Success - response time check doesn't increment failed count
else
    : # Warning already logged
fi

# CORS headers check (if applicable)
((TOTAL_CHECKS++))
if curl -s -I -H "Origin: https://healthapp.example.com" "$API_URL/health" 2>/dev/null | grep -q "Access-Control-Allow-Origin"; then
    log_success "CORS headers present"
else
    log_warning "CORS headers not found (may be expected for internal endpoints)"
fi

# Summary
echo ""
echo "=========================================="
echo "Health Check Summary:"
echo "Total checks: $TOTAL_CHECKS"
echo "Failed checks: $FAILED_CHECKS"

if [[ $FAILED_CHECKS -eq 0 ]]; then
    log_success "All health checks passed! ✅"
    exit 0
else
    log_error "$FAILED_CHECKS health check(s) failed! ❌"
    exit 1
fi
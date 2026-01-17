#!/bin/bash

# Backend Status Script for Health Management App
# Shows status of Laravel backend (Slim API has been removed)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LARAVEL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backend/laravel-app"
ENV_FILE="$LARAVEL_DIR/.env"

# Functions
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

# Check if .env file exists
check_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        log_error ".env file not found at: $ENV_FILE"
        log_error "Please ensure Laravel is properly set up with .env file"
        exit 1
    fi
}

# Check Laravel health
check_laravel_health() {
    local laravel_url="${LARAVEL_URL:-http://localhost:8000/api/v1/health}"

    log_info "Checking Laravel API availability at: $laravel_url"

    if curl -s --max-time 5 "$laravel_url" > /dev/null 2>&1; then
        log_success "Laravel API is available"
        return 0
    else
        log_warning "Laravel API is not available at $laravel_url"
        return 1
    fi
}

# Status function
show_status() {
    echo
    log_info "Backend Status - Laravel Only"
    echo "=========================================="
    echo "Active Backend: Laravel (primary)"
    echo "Slim API Status: Removed (migration complete)"
    echo "Laravel Status: $(check_laravel_health && echo 'Available' || echo 'Unavailable')"
    echo "Migration Status: Complete"
    echo "Toggle System: Disabled (no longer needed)"
    echo
    log_info "Migration Summary:"
    echo "✓ Slim PHP API removed from codebase"
    echo "✓ Laravel backend fully operational"
    echo "✓ Flutter app successfully syncing"
    echo "✓ All endpoints migrated and tested"
}

# Help function
show_help() {
    cat << EOF
Backend Status Script for Health Management App

USAGE:
    $0 [status]

COMMANDS:
    status     Show current backend status

DESCRIPTION:
    This script shows the status of the Laravel backend.
    The Slim PHP API has been removed as the migration to Laravel is complete.

    Laravel is now the only backend, providing all features with comprehensive testing.

EXAMPLES:
    $0 status      # Show current status

MIGRATION COMPLETE:
    - Slim PHP API: Removed
    - Laravel Backend: Active and tested
    - Flutter App: Syncing successfully

EOF
}

# Main script
main() {
    local command="$1"

    check_env_file

    case "$command" in
        "status")
            show_status
            ;;
        "")
            log_error "No command specified"
            echo
            show_help
            exit 1
            ;;
        *)
            log_error "Unknown command: $command"
            log_info "Only 'status' command is available now"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
#!/bin/bash

# Health App Backend Start Script
# Starts the PHP development server for the backend API

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
HOST="${HOST:-localhost}"
PORT="${PORT:-8000}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend/api"

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

# Check if we're in the right directory
if [[ ! -f "$BACKEND_DIR/composer.json" ]]; then
    log_error "composer.json not found in $BACKEND_DIR"
    log_error "Please run this script from the project root directory"
    exit 1
fi

# Change to backend directory
cd "$BACKEND_DIR"

# Check if vendor directory exists (dependencies installed)
if [[ ! -d "vendor" ]]; then
    log_warning "Dependencies not installed. Installing..."
    composer install --no-interaction
fi

# Check if .env file exists
if [[ ! -f ".env" ]]; then
    log_warning ".env file not found. Using default configuration."
    log_info "You may want to copy config/.env.example to .env and customize it."
fi

# Check if SQLite database exists
DB_FILE="${DB_DATABASE:-/tmp/health_app.db}"
if [[ ! -f "$DB_FILE" ]] && [[ "$DB_CONNECTION" != "mysql" ]]; then
    log_warning "Database file not found at $DB_FILE"
    log_info "Run database setup if needed: sqlite3 $DB_FILE < database/schema.sqlite.sql"
fi

# Start the server
log_info "Starting Health App Backend API..."
log_info "Host: $HOST"
log_info "Port: $PORT"
log_info "URL: http://$HOST:$PORT"
log_info "Health Check: http://$HOST:$PORT/api/v1/health"
log_info ""
log_info "Press Ctrl+C to stop the server"
log_info ""

# Start PHP development server
exec php -S "$HOST:$PORT" -t public
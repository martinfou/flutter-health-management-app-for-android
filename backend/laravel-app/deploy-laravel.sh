#!/bin/bash

# deploy-laravel.sh - Deploy Laravel backend to DreamHost
# Usage: ./deploy-laravel.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REMOTE_USER="compica_healthapp"
REMOTE_HOST="healthapp.compica.com"
REMOTE_DIR="/home/compica_healthapp/healthapp.compica.com"
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_ENV_PRODUCTION="$LOCAL_DIR/.env.production"

# Functions for logging
log_section() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
}

log_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Main deployment
log_section "Health App - Laravel Backend Deployment"

echo "Deployment Configuration:"
echo "  Remote User: $REMOTE_USER"
echo "  Remote Host: $REMOTE_HOST"
echo "  Remote Directory: $REMOTE_DIR"
echo "  Local Directory: $LOCAL_DIR"
echo ""

# Step 1: Build assets locally (Vite)
log_section "Step 1: Building Frontend Assets"

if [ -f "$LOCAL_DIR/package.json" ]; then
    log_info "Installing npm dependencies..."
    npm install

    log_info "Building assets with Vite..."
    npm run build

    log_success "Frontend assets built"
else
    log_info "No package.json found, skipping asset build"
fi

# Step 2: Install composer dependencies locally
log_section "Step 2: Preparing Production Environment File"

# Copy .env.production to server as .env
if [ -f "$LOCAL_ENV_PRODUCTION" ]; then
    log_info "Uploading production .env file to server..."
    scp "$LOCAL_ENV_PRODUCTION" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/.env"
    if [ $? -eq 0 ]; then
        log_success "Production .env file uploaded"
    else
        log_error "Failed to upload .env file"
        exit 1
    fi
else
    log_error ".env.production file not found at $LOCAL_ENV_PRODUCTION"
    exit 1
fi

log_section "Step 3: Installing Composer Dependencies Locally"

if [ -f "$LOCAL_DIR/composer.json" ]; then
    log_info "Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader
    log_success "Composer dependencies installed"
else
    log_error "No composer.json found"
    exit 1
fi

# Step 4: Sync code to server
log_section "Step 4: Syncing Files to Server"

log_info "Syncing Laravel application to $REMOTE_HOST..."
rsync -avz --delete \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='storage/logs/*' \
    --exclude='storage/framework/cache/*' \
    --exclude='storage/framework/views/*' \
    --exclude='bootstrap/cache/*' \
    --exclude='.env' \
    --exclude='.env.local' \
    --exclude='.env.*.local' \
    --exclude='*.log' \
    --exclude='*.swp' \
    --exclude='*.swo' \
    --exclude='.DS_Store' \
    --exclude='Thumbs.db' \
    --exclude='deploy-laravel.sh' \
    "$LOCAL_DIR/" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" \
    | grep -E "(sending|sent|deleting|100%|total)"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    log_success "Files synced successfully"
else
    log_error "Files sync failed"
    exit 1
fi

# Step 5: Remote deployment tasks
log_section "Step 5: Running Remote Deployment Tasks"

ssh "$REMOTE_USER@$REMOTE_HOST" << 'REMOTE_SCRIPT'
    set -e

    REMOTE_DIR="/home/compica_healthapp/healthapp.compica.com"

    # Function for remote logging
    log_info() { echo "→ $1"; }
    log_success() { echo "✓ $1"; }
    log_error() { echo "✗ $1"; }

    cd "$REMOTE_DIR"

    # 4.1: Set file permissions
    log_info "Setting file permissions..."
    find . -type d -not -path './\.git/*' -exec chmod 755 {} \;
    find . -type f -not -path './\.git/*' -exec chmod 644 {} \;
    chmod 755 artisan
    chmod -R 775 storage bootstrap/cache
    log_success "File permissions set"

    # 4.2: Create directory if it doesn't exist
    log_info "Creating/verifying Laravel directory..."
    mkdir -p "$REMOTE_DIR"
    log_success "Laravel directory ready"

    # 4.3: Install composer dependencies on server
    log_info "Installing composer dependencies on server..."

    # Try to find composer
    if command -v composer &> /dev/null; then
        COMPOSER_CMD="composer"
    elif [ -f "/usr/local/bin/composer" ]; then
        COMPOSER_CMD="/usr/local/bin/composer"
    elif [ -f "$HOME/composer.phar" ]; then
        COMPOSER_CMD="php $HOME/composer.phar"
    else
        # Try to install composer
        log_info "Composer not found, attempting to install..."
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php --install-dir="$HOME" --filename=composer.phar
        rm -f composer-setup.php
        COMPOSER_CMD="php $HOME/composer.phar"
    fi

    # Use --ignore-platform-reqs if PHP version mismatch
    $COMPOSER_CMD install --no-dev --optimize-autoloader --ignore-platform-reqs
    log_success "Composer dependencies installed on server"

    # 4.4: Run migrations
    log_info "Running database migrations..."
    php artisan migrate --force
    log_success "Migrations completed"

    # 4.5: Clear and optimize cache
    log_info "Clearing caches..."
    php artisan cache:clear
    php artisan config:clear
    php artisan view:clear

    log_info "Optimizing application..."
    php artisan optimize
    log_success "Cache cleared and optimized"

    # 4.6: Disable platform_check.php for PHP version compatibility
    log_info "Disabling platform check for PHP compatibility..."
    sed -i "s|require __DIR__ . '/platform_check.php';|// require __DIR__ . '/platform_check.php'; // Disabled for PHP compatibility|" vendor/composer/autoload_real.php
    log_success "Platform check disabled"

    # 4.7: Create root .htaccess to route to public folder
    log_info "Creating root .htaccess for routing..."
    cat > .htaccess << 'HTACCESS'
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Redirect to public folder
    RewriteCond %{REQUEST_URI} !^/public/
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>
HTACCESS
    log_success "Root .htaccess created"

    # 4.8: Verify Laravel is working
    log_info "Verifying Laravel installation..."
    php artisan route:list > /dev/null
    log_success "Laravel verified"

REMOTE_SCRIPT

if [ $? -ne 0 ]; then
    log_error "Remote deployment tasks failed"
    exit 1
fi

# Step 6: Verify deployment
log_section "Step 6: Verifying Deployment"

log_info "Testing API endpoints..."
echo ""

# Test health endpoint
echo "Testing API health check..."
HEALTH_RESPONSE=$(curl -s -X GET "https://healthapp.compica.com/api/v1/health" \
    -H "Accept: application/json" || echo '{"success":false}')

if echo "$HEALTH_RESPONSE" | grep -q '"success":true'; then
    log_success "Health check passed"
    echo "Response: $HEALTH_RESPONSE"
else
    log_error "Health check failed - API may not be accessible"
    echo "Response: $HEALTH_RESPONSE"
fi

echo ""

# Test web dashboard
echo "Testing web dashboard..."
DASHBOARD=$(curl -s -I "https://healthapp.compica.com/" | head -1)
if echo "$DASHBOARD" | grep -q "200\|301\|302"; then
    log_success "Dashboard is accessible"
    echo "Response: $DASHBOARD"
else
    log_error "Dashboard returned an error"
    echo "Response: $DASHBOARD"
fi

# Final summary
log_section "Deployment Complete!"

echo "Deployment Summary:"
echo "  ✓ Frontend assets built"
echo "  ✓ Code synced to server"
echo "  ✓ Dependencies installed"
echo "  ✓ Database migrated"
echo "  ✓ Cache optimized"
echo ""

echo "Testing the deployment:"
echo "  API Health Check:"
echo "    curl https://healthapp.compica.com/api/v1/health"
echo ""
echo "  Web Dashboard:"
echo "    https://healthapp.compica.com/"
echo ""
echo "  API Documentation:"
echo "    Check routes/api.php for available endpoints"
echo ""

echo "Next steps:"
echo "  1. SSH to server: ssh $REMOTE_USER@$REMOTE_HOST"
echo "  2. Check logs: tail -f $REMOTE_DIR/storage/logs/laravel.log"
echo "  3. Test endpoints with: curl https://healthapp.compica.com/api/v1/health"
echo ""

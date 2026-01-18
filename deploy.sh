#!/bin/bash

# deploy.sh - Master deployment script for Health Management App
# Orchestrates deployment of all components: Laravel backend, API, web app, and database migrations
# Usage: ./deploy.sh [environment]
# environment: 'development' or 'production' (default: 'production')

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
ENV="${1:-production}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LARAVEL_DIR="$PROJECT_ROOT/backend/laravel-app"

# Remote server configuration
REMOTE_USER="compica_healthapp"
REMOTE_HOST="healthapp.compica.com"
REMOTE_BASE_DIR="/home/compica_healthapp"
REMOTE_WEB_ROOT="$REMOTE_BASE_DIR/healthapp.compica.com"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Logging functions
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

log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

log_backup() {
    echo -e "${BLUE}💾 $1${NC}"
}

# Backup current production deployment
create_backup() {
    log_section "Creating Production Backup"

    log_backup "Creating backup of current production deployment..."

    # Create backup directory with timestamp
    BACKUP_DIR="$REMOTE_BASE_DIR/backups/$TIMESTAMP"

    ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
        # Create backups directory if it doesn't exist
        mkdir -p "$REMOTE_BASE_DIR/backups"

        # Create timestamped backup
        cp -r "$REMOTE_WEB_ROOT" "$BACKUP_DIR"

        # Verify backup was created
        if [ -d "$BACKUP_DIR" ]; then
            echo "✓ Backup created: $BACKUP_DIR"
            ls -la "$BACKUP_DIR" | head -5
        else
            echo "✗ Backup creation failed"
            exit 1
        fi
EOF

    if [ $? -eq 0 ]; then
        log_success "Production backup completed: $TIMESTAMP"
        echo "  Backup location: $REMOTE_USER@$REMOTE_HOST:$BACKUP_DIR"
        echo "  To restore manually: cp -r $BACKUP_DIR/* $REMOTE_WEB_ROOT/"
        echo ""
    else
        log_error "Backup creation failed"
        exit 1
    fi
}

# Setup symbolic link structure for easy rollback
setup_symlinks() {
    log_section "Setting Up Symbolic Link Structure"

    # Create new deployment directory with timestamp
    NEW_DEPLOY_DIR="$REMOTE_BASE_DIR/releases/$TIMESTAMP"

    ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
        # Create releases directory
        mkdir -p "$REMOTE_BASE_DIR/releases"

        # Create new deployment directory
        mkdir -p "$NEW_DEPLOY_DIR"

        # Set proper permissions
        chown -R $REMOTE_USER:$REMOTE_USER "$NEW_DEPLOY_DIR"
        chmod 755 "$NEW_DEPLOY_DIR"

        echo "✓ Deployment directory created: $NEW_DEPLOY_DIR"
EOF

    if [ $? -eq 0 ]; then
        log_success "Symbolic link structure ready"
        DEPLOY_DIR="$NEW_DEPLOY_DIR"
    else
        log_error "Failed to setup deployment structure"
        exit 1
    fi
}

# Switch symbolic link to new deployment
activate_deployment() {
    log_section "Activating New Deployment"

    local new_deploy_dir="$1"

    ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
        if [ -e "$REMOTE_WEB_ROOT" ]; then
            if [ -L "$REMOTE_WEB_ROOT" ]; then
                CURRENT_TARGET=\$(readlink "$REMOTE_WEB_ROOT")
                echo "Current deployment: \$CURRENT_TARGET"
                rm -f "$REMOTE_WEB_ROOT"
            else
                echo "Warning: $REMOTE_WEB_ROOT is a real directory. Backing it up..."
                mv "$REMOTE_WEB_ROOT" "${REMOTE_WEB_ROOT}_bak_\$(date +%Y%m%d_%H%M%S)"
            fi
        fi

        ln -s "$new_deploy_dir/public" "$REMOTE_WEB_ROOT"

        if [ -L "$REMOTE_WEB_ROOT" ] && [ "\$(readlink "$REMOTE_WEB_ROOT")" = "$new_deploy_dir/public" ]; then
            echo "✓ Symlink created: $REMOTE_WEB_ROOT -> $new_deploy_dir/public"
        else
            echo "✗ Symlink creation failed"
            exit 1
        fi
EOF

    if [ $? -eq 0 ]; then
        log_success "New deployment activated"
        echo "  Active deployment: $new_deploy_dir"
        echo ""
    else
        log_error "Failed to activate deployment"
        exit 1
    fi
}

# Rollback to previous deployment
rollback_deployment() {
    log_section "Rolling Back Deployment"

    ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
        # Find the previous deployment
        PREVIOUS_DEPLOY=\$(ls -t "$REMOTE_BASE_DIR/releases/" | head -2 | tail -1)

        if [ -z "\$PREVIOUS_DEPLOY" ]; then
            echo "✗ No previous deployment found for rollback"
            exit 1
        fi

        PREVIOUS_DIR="$REMOTE_BASE_DIR/releases/\$PREVIOUS_DEPLOY"

        if [ ! -d "\$PREVIOUS_DIR" ]; then
            echo "✗ Previous deployment directory not found: \$PREVIOUS_DIR"
            exit 1
        fi

        echo "Rolling back to: \$PREVIOUS_DIR"

        # Switch symlink
        rm -f "$REMOTE_WEB_ROOT"
        ln -s "\$PREVIOUS_DIR" "$REMOTE_WEB_ROOT"

        # Verify rollback
        if [ -L "$REMOTE_WEB_ROOT" ] && [ "\$(readlink "$REMOTE_WEB_ROOT")" = "\$PREVIOUS_DIR" ]; then
            echo "✓ Rollback successful: $REMOTE_WEB_ROOT -> \$PREVIOUS_DIR"
        else
            echo "✗ Rollback failed"
            exit 1
        fi
EOF

    if [ $? -eq 0 ]; then
        log_success "Rollback completed successfully"
        echo "  Check: https://healthapp.compica.com/"
        echo ""
    else
        log_error "Rollback failed"
        exit 1
    fi
}

# List available deployments for rollback selection
list_deployments() {
    log_section "Available Deployments"

    ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
        echo "Current active deployment:"
        if [ -L "$REMOTE_WEB_ROOT" ]; then
            CURRENT=\$(readlink "$REMOTE_WEB_ROOT")
            echo "  → \$CURRENT"
            echo "    Created: \$(stat -c '%y' "\$CURRENT" 2>/dev/null || stat -f '%Sm' "\$CURRENT")"
        else
            echo "  → No symlink found (direct directory)"
        fi

        echo ""
        echo "Available releases:"
        if [ -d "$REMOTE_BASE_DIR/releases" ]; then
            ls -la "$REMOTE_BASE_DIR/releases/" | grep -v "^total" | tail -10 | while read line; do
                DIR_NAME=\$(echo \$line | awk '{print \$9}')
                if [ -n "\$DIR_NAME" ] && [ "\$DIR_NAME" != "." ] && [ "\$DIR_NAME" != ".." ]; then
                    DIR_PATH="$REMOTE_BASE_DIR/releases/\$DIR_NAME"
                    if [ -L "$REMOTE_WEB_ROOT" ] && [ "\$(readlink "$REMOTE_WEB_ROOT")" = "\$DIR_PATH" ]; then
                        echo "  ✓ \$DIR_NAME (ACTIVE)"
                    else
                        echo "    \$DIR_NAME"
                    fi
                fi
            done
        else
            echo "  No releases directory found"
        fi

        echo ""
        echo "Available backups:"
        if [ -d "$REMOTE_BASE_DIR/backups" ]; then
            ls -la "$REMOTE_BASE_DIR/backups/" | grep -v "^total" | tail -5 | while read line; do
                DIR_NAME=\$(echo \$line | awk '{print \$9}')
                if [ -n "\$DIR_NAME" ]; then
                    echo "    \$DIR_NAME"
                fi
            done
        else
            echo "  No backups directory found"
        fi
EOF
}

# Pre-deployment checks
check_dependencies() {
    log_section "Pre-Deployment Checks"

    # Check if we're in the right directory (project root should have app/ and backend/ dirs)
    if [ ! -d "$PROJECT_ROOT/app" ] || [ ! -d "$PROJECT_ROOT/backend" ]; then
        log_error "Not in project root directory. Please run from project root (should contain app/ and backend/ directories)."
        exit 1
    fi

    # Check for required tools
    if ! command -v rsync &> /dev/null; then
        log_error "rsync is required but not installed. Please install rsync."
        exit 1
    fi

    if ! command -v ssh &> /dev/null; then
        log_error "ssh is required but not installed. Please install openssh-client."
        exit 1
    fi

    # Check for Laravel deployment script
    if [ ! -f "$LARAVEL_DIR/deploy-laravel.sh" ]; then
        log_error "Laravel deployment script not found: $LARAVEL_DIR/deploy-laravel.sh"
        exit 1
    fi

    # Web app removed - no separate deployment script needed
    # Dashboard now served by Laravel web routes

    log_success "All dependencies and scripts found"
}

# Deploy Laravel backend
deploy_laravel() {
    local deploy_dir="$1"

    log_section "Deploying Laravel Backend"

    log_info "Deploying Laravel to: $deploy_dir"

    # Build assets locally first
    if [ -f "$LARAVEL_DIR/package.json" ]; then
        log_info "Building frontend assets..."
        cd "$LARAVEL_DIR"
        npm install
        npm run build
    fi

    # Install composer dependencies locally
    if [ -f "$LARAVEL_DIR/composer.json" ]; then
        log_info "Installing composer dependencies..."
        cd "$LARAVEL_DIR"
        composer install --no-dev --optimize-autoloader
    fi

    # Sync Laravel files to deployment directory
    log_info "Syncing Laravel files..."
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
        --exclude='deploy-laravel.sh' \
        "$LARAVEL_DIR/" \
        "$REMOTE_USER@$REMOTE_HOST:$deploy_dir/" \
        | grep -E "(sending|sent|deleting|100%|total)"

    # Upload production .env file
    if [ -f "$LARAVEL_DIR/.env.production" ]; then
        log_info "Uploading production .env file..."
        scp "$LARAVEL_DIR/.env.production" "$REMOTE_USER@$REMOTE_HOST:$deploy_dir/.env"
    fi

    # Run remote Laravel setup
    ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
        cd "$deploy_dir"

        # Set file permissions
        find . -type d -exec chmod 755 {} \;
        find . -type f -exec chmod 644 {} \;
        chmod 755 artisan
        chmod -R 775 storage bootstrap/cache

        # Install composer dependencies on server
        if command -v composer &> /dev/null; then
            composer install --no-dev --optimize-autoloader --ignore-platform-reqs
        fi

        # Run migrations
        php artisan migrate --force

        # Clear and optimize cache
        php artisan cache:clear
        php artisan config:clear
        php artisan route:clear
        php artisan view:clear
        php artisan optimize

        echo "✓ Laravel backend deployed and caches cleared"
EOF

    if [ $? -eq 0 ]; then
        log_success "Laravel backend deployed successfully"
    else
        log_error "Laravel deployment failed"
        exit 1
    fi
}


# Web app removed - using Laravel web dashboard instead
deploy_webapp() {
    log_section "Web Dashboard Configuration"

    log_info "Web dashboard now served by Laravel web routes - no separate deployment needed"

    log_success "Web dashboard configuration complete"
}

# Run database migrations (BF-003: Timestamp support for multiple daily health metrics)
run_migrations() {
    log_section "Database Migrations"

    log_info "BF-003: Health metrics timestamp migration included"
    log_info "This enables multiple entries per day with full timestamps"

    # Migrations are already run as part of Laravel deployment
    log_success "Migrations will be applied during Laravel deployment"
}

# Post-deployment verification
verify_deployment() {
    log_section "Post-Deployment Verification"

    log_info "Testing API endpoints..."

    # Test health endpoint
    HEALTH_RESPONSE=$(curl -s -X GET "https://healthapp.compica.com/api/v1/health" \
        -H "Accept: application/json" || echo '{"success":false}')

    if echo "$HEALTH_RESPONSE" | grep -q '"success":true'; then
        log_success "API health check passed"
    else
        log_error "API health check failed"
        echo "Response: $HEALTH_RESPONSE"
        exit 1
    fi

    # Test Laravel web dashboard
    log_info "Testing Laravel web dashboard..."
    DASHBOARD_PATH="https://healthapp.compica.com/dashboard"
    DASHBOARD_RESPONSE=$(curl -s -I "$DASHBOARD_PATH" | head -1)

    if echo "$DASHBOARD_RESPONSE" | grep -q "200\|302\|401"; then
        log_success "Laravel web dashboard is accessible"
    else
        log_warning "Laravel dashboard returned unexpected response"
        echo "Response: $DASHBOARD_RESPONSE"
        echo "Check manually: $DASHBOARD_PATH"
    fi

    # Test Laravel backend
    LARAVEL_RESPONSE=$(curl -s -I "https://healthapp.compica.com/api/v1/health-metrics" \
        -H "Accept: application/json" | head -1)
    if echo "$LARAVEL_RESPONSE" | grep -q "200\|401"; then
        log_success "Laravel backend is accessible"
    else
        log_warning "Laravel backend returned unexpected response (may be normal for auth-required endpoints)"
        echo "Response: $LARAVEL_RESPONSE"
    fi
}

# Main deployment flow
main() {
    log_section "Health Management App - Complete Deployment"
    echo "Environment: $ENV"
    echo "Project Root: $PROJECT_ROOT"
    echo ""

    # Production deployment confirmation
    if [ "$ENV" = "production" ]; then
        log_warning "⚠️  PRODUCTION DEPLOYMENT WARNING ⚠️"
        echo ""
        echo "This will deploy to the live production environment:"
        echo "  - URL: https://healthapp.compica.com"
        echo "  - Database: Production MySQL database"
        echo "  - Users: Real user data will be affected"
        echo ""
        read -p "Are you sure you want to deploy to PRODUCTION? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "Deployment cancelled by user."
            exit 0
        fi
        echo ""
    fi

    # Pre-deployment checks
    check_dependencies

    # Setup deployment structure
    create_backup
    setup_symlinks

    # Deploy components to the new directory
    deploy_laravel "$DEPLOY_DIR"
    deploy_webapp "$DEPLOY_DIR"  # Now just logs configuration status
    run_migrations

    # Activate the new deployment
    activate_deployment "$DEPLOY_DIR"

    # Post-deployment verification
    verify_deployment

    # Deployment summary
    log_section "Deployment Complete! 🎉"

    echo "Successfully deployed all components:"
    echo "  ✓ Laravel Backend (API + Web Dashboard)"
    echo "  ✓ Laravel Web Dashboard (no separate web-app)"
    echo "  ✓ Database Migrations (BF-003: Multiple daily health metrics)"
    echo ""

    echo "BF-003 Impact:"
    echo "  ✓ Health metrics now support multiple entries per day"
    echo "  ✓ Timestamp precision instead of date-only storage"
    echo "  ✓ Users can track morning/evening health measurements"
    echo ""
    echo "Deployment Structure:"
    echo "  Active: $REMOTE_WEB_ROOT -> $DEPLOY_DIR"
    echo "  Backup: $REMOTE_BASE_DIR/backups/$TIMESTAMP"
    echo "  Rollback: ./deploy.sh rollback"
    echo ""

    echo "Testing URLs:"
    echo "  API Health: https://healthapp.compica.com/api/v1/health"
    echo "  Web Dashboard: https://healthapp.compica.com/dashboard"
    echo "  Laravel API: https://healthapp.compica.com/api/v1/health-metrics"
    echo ""

    echo "Next Steps:"
    echo "  1. Test the Flutter app with the deployed backend"
    echo "  2. Test Google OAuth login at https://healthapp.compica.com/login"
    echo "  3. Verify dashboard access at https://healthapp.compica.com/dashboard"
    echo "  4. Verify multiple daily health metric entries work"
    echo "  5. Monitor server logs for any issues"
    echo ""

    if [ "$ENV" = "production" ]; then
        echo "Production Deployment Notes:"
        echo "  - HTTPS is enabled on DreamHost"
        echo "  - SSL certificate is active"
        echo "  - Database backups are automatic"
        echo ""
    fi
}

# Handle command line arguments
case "$1" in
    --help|-h)
        echo "Health Management App - Complete Deployment Script"
        echo ""
        echo "Usage: $0 [command] [environment]"
        echo ""
        echo "Commands:"
        echo "  deploy        Deploy application (default)"
        echo "  rollback      Rollback to previous deployment"
        echo "  list          List available deployments"
        echo "  backup        Create backup of current deployment"
        echo ""
        echo "Arguments:"
        echo "  environment   Environment to deploy to (default: production)"
        echo "                Options: production, development"
        echo ""
        echo "Examples:"
        echo "  $0                    # Deploy to production"
        echo "  $0 production        # Deploy to production"
        echo "  $0 rollback           # Rollback to previous version"
        echo "  $0 list               # List available deployments"
        echo "  $0 backup             # Create backup only"
        echo ""
        exit 0
        ;;
    rollback)
        log_section "Rolling Back Deployment"
        echo "This will rollback to the previous deployment version."
        echo ""
        read -p "Are you sure you want to rollback? (yes/no): " -r
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            rollback_deployment
        else
            echo "Rollback cancelled."
        fi
        ;;
    list)
        list_deployments
        ;;
    backup)
        create_backup
        ;;
    *)
        main "$@"
        ;;
esac
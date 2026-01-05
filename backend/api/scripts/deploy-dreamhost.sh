#!/bin/bash

# deploy-dreamhost.sh - Deploy backend code to DreamHost
# Usage: ./deploy-dreamhost.sh [environment]
# environment: 'development' or 'production' (default: 'production')

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REMOTE_USER="compica_health"
REMOTE_HOST="health.martinfourier.com"
REMOTE_DIR="~/health-app-api"
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backend/api"
ENV="${1:-production}"

echo "========================================"
echo "Health App - Backend Deployment"
echo "========================================"
echo ""
echo "Environment: $ENV"
echo ""

echo "Deployment Configuration:"
echo "  Remote User: $REMOTE_USER"
echo "  Remote Host: $REMOTE_HOST"
echo "  Remote Directory: $REMOTE_DIR"
echo "  Local Directory: $LOCAL_DIR"
echo ""

if [ "$ENV" = "production" ]; then
    if [ -f "$LOCAL_DIR/.env" ]; then
        echo "Warning: .env file found in local directory."
        echo "Please update .env on server separately, not here."
        echo ""
        read -p "Continue anyway? (y/N): " -n 1
        if [ "$REPLY" != "y" ]; then
            exit 0
        fi
    fi
fi

echo "Syncing code to DreamHost..."
echo ""

# Sync source code
echo "Uploading source files..."
rsync -avz --delete \
    --exclude='vendor/' \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='.env' \
    --exclude='*.log' \
    "$LOCAL_DIR/" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" \
    | grep -E "(building|sending|sent|sent [0-9]* of [0-9]* files|100%|total)"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ Files synced successfully"
else
    echo "✗ Files sync failed"
    exit 1
fi

echo ""

# Install/update composer dependencies
echo "Installing/updating composer dependencies..."
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DIR && composer install --no-dev --optimize-autoloader"

if [ $? -ne 0 ]; then
    echo "✗ Composer install failed"
    exit 1
fi

echo "✓ Composer dependencies installed"
echo ""

# Set file permissions
echo "Setting file permissions..."
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DIR && find . -type d -exec chmod 755 {} \; && find . -type f -exec chmod 644 {} \;"

if [ $? -ne 0 ]; then
    echo "✗ Permission setting failed"
    exit 1
fi

echo "✓ File permissions set"
echo ""

# Ensure .env is secure
echo "Setting .env permissions..."
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DIR && if [ -f .env ]; then chmod 600 .env; fi"

if [ $? -ne 0 ]; then
    echo "✗ .env permission setting failed"
    exit 1
fi

echo "✓ .env permissions set"
echo ""

# Restart PHP (if using PHP-FPM)
echo "Restarting PHP service..."
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DIR && touch php-fpm.restart"

if [ $? -ne 0 ]; then
    echo "Note: PHP service restart may require manual action"
fi

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Next Steps:"
echo "1. Configure .env file on server:"
echo "   ssh $REMOTE_USER@$REMOTE_HOST"
echo "   cd $REMOTE_DIR"
echo "   cp .env.example .env"
echo "   nano .env"
echo ""
echo "2. Run database deployment:"
echo "   cd $REMOTE_DIR"
echo "   chmod +x scripts/deploy-schema.sh"
echo "   ./scripts/deploy-schema.sh"
echo ""
echo "3. Test deployment:"
echo "   curl https://health.martinfourier.com/api/v1/health"
echo ""

if [ "$ENV" = "production" ]; then
    echo "Production Mode:"
    echo "  - Make sure to enable HTTPS in DreamHost panel"
    echo "  - Update .env with production values"
else
    echo "Development Mode:"
fi

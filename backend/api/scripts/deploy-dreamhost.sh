#!/bin/bash

# DreamHost Deployment Script for Health App Backend
# This script handles deployment to DreamHost shared hosting

set -e  # Exit on any error

# Configuration - Update these variables
DREAMHOST_USER="${DREAMHOST_USER:-your_dreamhost_user}"
DREAMHOST_SERVER="${DREAMHOST_SERVER:-your_dreamhost_server.com}"
REMOTE_PATH="${REMOTE_PATH:-/home/${DREAMHOST_USER}/api.healthapp.example.com}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Starting DreamHost deployment..."
echo "User: $DREAMHOST_USER"
echo "Server: $DREAMHOST_SERVER"
echo "Remote Path: $REMOTE_PATH"

# Check if we're in the right directory
if [[ ! -f "composer.json" ]]; then
    echo "❌ Error: composer.json not found. Run this script from backend/api directory."
    exit 1
fi

# Install/update dependencies
echo "📦 Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction

# Create environment file if it doesn't exist
if [[ ! -f "config/.env" ]]; then
    echo "⚠️  Warning: config/.env not found. Using .env.example as template."
    cp config/.env.example config/.env
    echo "📝 Please edit config/.env with your production settings before continuing."
    echo "Press Enter to continue or Ctrl+C to abort."
    read -r
fi

# Validate PHP syntax
echo "🔍 Validating PHP syntax..."
find src/ -name "*.php" -exec php -l {} \;
php -l public/index.php

# Create deployment archive (exclude development files)
echo "📦 Creating deployment archive..."
DEPLOY_ARCHIVE="/tmp/health-api-deploy-$(date +%Y%m%d-%H%M%S).tar.gz"

tar -czf "$DEPLOY_ARCHIVE" \
    --exclude='.git*' \
    --exclude='node_modules' \
    --exclude='.env.example' \
    --exclude='docs' \
    --exclude='database' \
    --exclude='scripts' \
    --exclude='.github' \
    --exclude='composer.json' \
    --exclude='composer.lock' \
    --exclude='README.md' \
    --exclude='*.log' \
    .

# Upload to DreamHost
echo "📤 Uploading to DreamHost..."
scp "$DEPLOY_ARCHIVE" "${DREAMHOST_USER}@${DREAMHOST_SERVER}:~/"

# Execute remote deployment
echo "🔧 Executing remote deployment..."
ssh "${DREAMHOST_USER}@${DREAMHOST_SERVER}" << EOF
    set -e

    echo "Extracting deployment archive..."
    mkdir -p "$REMOTE_PATH"
    cd "$REMOTE_PATH"
    tar -xzf "$DEPLOY_ARCHIVE"

    echo "Setting correct permissions..."
    find . -type f -exec chmod 644 {} \;
    find . -type d -exec chmod 755 {} \;
    chmod 755 public/index.php

    echo "Cleaning up..."
    rm "$DEPLOY_ARCHIVE"

    echo "✅ Deployment completed successfully!"
EOF

# Clean up local archive
rm -f "$DEPLOY_ARCHIVE"

# Health check
echo "🔍 Running health check..."
sleep 10

HEALTH_URL="https://${DREAMHOST_SERVER}/health"
if curl -f --max-time 30 "$HEALTH_URL" > /dev/null 2>&1; then
    echo "✅ Health check passed! API is responding."
    echo "🌐 API URL: https://$DREAMHOST_SERVER"
else
    echo "❌ Health check failed. Please check the deployment."
    exit 1
fi

echo "🎉 Deployment completed successfully!"
echo "📋 Next steps:"
echo "   1. Verify the API is working with Postman"
echo "   2. Update Flutter app with production API URL"
echo "   3. Monitor error logs on DreamHost"
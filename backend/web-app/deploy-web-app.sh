#!/bin/bash

# deploy-web-app.sh - Deploy web dashboard to DreamHost
# Usage: ./deploy-web-app.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REMOTE_USER="compica_healthapp"
REMOTE_HOST="healthapp.compica.com"
REMOTE_DIR="/home/compica_healthapp/healthapp.compica.com"
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "Health App - Web Dashboard Deployment"
echo "========================================"
echo ""

echo "Deployment Configuration:"
echo "  Remote User: $REMOTE_USER"
echo "  Remote Host: $REMOTE_HOST"
echo "  Remote Directory: $REMOTE_DIR"
echo "  Local Directory: $LOCAL_DIR"
echo ""

echo "Syncing web app to DreamHost..."
echo ""

# Sync web app files
rsync -avz --delete \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='*.log' \
    --exclude='deploy-web-app.sh' \
    "$LOCAL_DIR/" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" \
    | grep -E "(sending|sent|100%|total)"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ Files synced successfully"
else
    echo "✗ Files sync failed"
    exit 1
fi

echo ""

# Set directory permissions (755 for directories, 644 for files)
echo "Setting file permissions..."
ssh "$REMOTE_USER@$REMOTE_HOST" << 'EOF'
    # Ensure web root directory is readable
    chmod 755 /home/compica_healthapp/healthapp.compica.com

    # Set file permissions in web root
    cd /home/compica_healthapp/healthapp.compica.com
    find . -maxdepth 1 -type f \( -name "*.html" -o -name "*.js" -o -name "*.css" -o -name ".htaccess" \) -exec chmod 644 {} \;

    # Ensure API directory is accessible
    chmod 755 api
    chmod 755 api/public
EOF

if [ $? -ne 0 ]; then
    echo "✗ Permission setting failed"
    exit 1
fi

echo "✓ File permissions set"
echo ""

echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Test deployment:"
echo "  curl https://healthapp.compica.com/"
echo "  curl https://healthapp.compica.com/api/v1/health"
echo ""

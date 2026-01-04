#!/bin/bash

# Environment Setup Script for Health App Backend
# Sets up environment variables and configuration for deployment

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔧 Health App Backend Environment Setup"
echo "========================================"

# Check if .env file exists
if [[ -f "$PROJECT_ROOT/config/.env" ]]; then
    echo "⚠️  .env file already exists at $PROJECT_ROOT/config/.env"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

# Create config directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/config"

# Copy template
cp "$PROJECT_ROOT/config/.env.example" "$PROJECT_ROOT/config/.env"

echo "📝 Setting up environment variables..."

# Database Configuration
echo "🗄️  Database Configuration:"
read -p "Database Host [localhost]: " DB_HOST
DB_HOST=${DB_HOST:-localhost}
read -p "Database Name [health_app]: " DB_NAME
DB_NAME=${DB_NAME:-health_app}
read -p "Database User [health_app_user]: " DB_USER
DB_USER=${DB_USER:-health_app_user}
read -s -p "Database Password: " DB_PASSWORD
echo

# JWT Configuration
echo "🔐 JWT Configuration:"
JWT_SECRET=$(openssl rand -base64 32)
echo "Generated JWT secret: ${JWT_SECRET:0:20}..."

# Google OAuth Configuration
echo "🔗 Google OAuth Configuration:"
read -p "Google Client ID: " GOOGLE_CLIENT_ID
read -p "Google Client Secret: " GOOGLE_CLIENT_SECRET
read -p "Google Redirect URI [https://api.healthapp.example.com/api/v1/auth/verify-google]: " GOOGLE_REDIRECT_URI
GOOGLE_REDIRECT_URI=${GOOGLE_REDIRECT_URI:-https://api.healthapp.example.com/api/v1/auth/verify-google}

# API Configuration
echo "🌐 API Configuration:"
read -p "API Base URL [https://api.healthapp.example.com]: " API_BASE_URL
API_BASE_URL=${API_BASE_URL:-https://api.healthapp.example.com}

# CORS Configuration
echo "🔒 CORS Configuration:"
read -p "CORS Allowed Origins (comma-separated) [https://healthapp.example.com,https://app.healthapp.example.com]: " CORS_ORIGINS
CORS_ORIGINS=${CORS_ORIGINS:-https://healthapp.example.com,https://app.healthapp.example.com}

# Rate Limiting
echo "⚡ Rate Limiting Configuration:"
read -p "Requests per minute [100]: " RATE_LIMIT_REQUESTS
RATE_LIMIT_REQUESTS=${RATE_LIMIT_REQUESTS:-100}
read -p "Auth requests per minute [5]: " RATE_LIMIT_AUTH_REQUESTS
RATE_LIMIT_AUTH_REQUESTS=${RATE_LIMIT_AUTH_REQUESTS:-5}

# Update .env file
sed -i.bak "s/DB_HOST=.*/DB_HOST=$DB_HOST/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/DB_NAME=.*/DB_NAME=$DB_NAME/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/DB_USER=.*/DB_USER=$DB_USER/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/GOOGLE_CLIENT_ID=.*/GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/GOOGLE_CLIENT_SECRET=.*/GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/GOOGLE_REDIRECT_URI=.*/GOOGLE_REDIRECT_URI=$GOOGLE_REDIRECT_URI/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/API_BASE_URL=.*/API_BASE_URL=$API_BASE_URL/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/CORS_ALLOWED_ORIGINS=.*/CORS_ALLOWED_ORIGINS=$CORS_ORIGINS/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/RATE_LIMIT_REQUESTS=.*/RATE_LIMIT_REQUESTS=$RATE_LIMIT_REQUESTS/" "$PROJECT_ROOT/config/.env"
sed -i.bak "s/RATE_LIMIT_AUTH_REQUESTS=.*/RATE_LIMIT_AUTH_REQUESTS=$RATE_LIMIT_AUTH_REQUESTS/" "$PROJECT_ROOT/config/.env"

# Remove backup file
rm "$PROJECT_ROOT/config/.env.bak"

echo "✅ Environment setup completed!"
echo "📄 Configuration saved to: $PROJECT_ROOT/config/.env"
echo ""
echo "🔍 Next steps:"
echo "   1. Review the .env file and adjust any values if needed"
echo "   2. Run database setup: mysql -u $DB_USER -p $DB_NAME < database/schema.sql"
echo "   3. Test the setup: composer start"
echo "   4. For production deployment, set these values in your CI/CD environment"
echo ""
echo "⚠️  Important: Keep the .env file secure and never commit it to version control!"
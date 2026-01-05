# DreamHost Deployment Guide

This guide explains how to deploy the Health Management App backend to DreamHost shared hosting.

## Prerequisites

- DreamHost account with SSH access
- Domain: `health.martinfourier.com`
- PHP 8.1+ installed locally
- Composer installed locally
- MySQL database access

## Step 1: SSH Access to DreamHost

### 1.1 Find SSH Credentials

1. Log in to [DreamHost Panel](https://panel.dreamhost.com/)
2. Navigate to **Manage Users**
3. Find or create SSH user
4. Note: SSH hostname (server) is typically your domain name

### 1.2 Test SSH Connection

```bash
ssh username@health.martinfourier.com
# Replace 'username' with your DreamHost SSH username
```

If connection fails:
- Verify SSH hostname is correct (usually `health.martinfourier.com`)
- Check if SSH access is enabled in DreamHost panel
- Try from different network

## Step 2: Create MySQL Database

### 2.1 Access phpMyAdmin or MySQL Command Line

#### Option A: Using phpMyAdmin (Recommended)

1. Log in to DreamHost panel
2. Navigate to **Goodies > MySQL Databases**
3. Scroll to **phpMyAdmin** section
4. Click on phpMyAdmin for your domain

#### Option B: Using MySQL Command Line

```bash
ssh username@health.martinfourier.com
# You'll be prompted for password

# Access MySQL shell
mysql -u username -p

# OR run single command
ssh username@health.martinfourier.com mysql -u username -p" <database.sql

# Replace 'username' with your MySQL username
```

### 2.2 Create Database

In phpMyAdmin:
1. Click on "New" to create new database
2. Enter database name: `health_app`
3. Select collation: `utf8mb4_unicode_ci`
4. Click "Create"

**Note**: Keep track of your database credentials:
- **Database Name**: `health_app`
- **Database User**: (from DreamHost panel)
- **Database Password**: (from DreamHost panel)

### 2.3 Run Database Schema

#### Using deploy-schema.sh Script

```bash
cd backend/api
chmod +x scripts/deploy-schema.sh
./scripts/deploy-schema.sh
```

The script will:
- Prompt for MySQL host, user, password, and database name
- Run `database/schema.sql` migrations
- Verify table creation

#### Manual Execution

If script doesn't work, manually import the schema:

```bash
# Copy schema.sql to DreamHost
scp database/schema.sql username@health.martinfourier.com:~

# SSH to server and import
ssh username@health.martinfourier.com
mysql -u username -p health_app < ~/schema.sql

# Replace 'username' with your MySQL username
```

### 2.4 Verify Database Creation

Run the following to verify tables were created:

```sql
-- After SSH login:
mysql -u username -p -e "USE health_app; SHOW TABLES;"

-- Expected output:
-- health_metrics
-- medications
-- meals
-- exercises
-- meal_plans
-- sync_status
-- password_resets
-- migrations
-- users
```

## Step 3: Upload Backend Code

### 3.1 Using deploy-dreamhost.sh Script (Recommended)

```bash
cd backend/api
chmod +x scripts/deploy-dreamhost.sh
./scripts/deploy-dreamhost.sh
```

The script will:
- Sync code to DreamHost via rsync
- Run `composer install --no-dev` on server
- Set correct file permissions

### 3.2 Manual Upload

If script doesn't work, manually upload files:

```bash
# Sync code directory
rsync -avz --delete \
  --exclude='vendor/' \
  --exclude='.git/' \
  public/ \
  src/ \
  config/ \
  scripts/ \
  username@health.martinfourier.com:~/health-app-api/

# SSH to server
ssh username@health.martinfourier.com

# Set up composer
ssh username@health.martinfourier.com
cd ~/health-app-api
composer install --no-dev --optimize-autoloader
```

### 3.3 Verify File Permissions

```bash
ssh username@health.martinfourier.com
cd ~/health-app-api

# Set permissions
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

# Verify permissions
ls -la
```

Expected permissions:
- Directories: `755` (rwxr-xr-x)
- Files: `644` (rw-r--r--)

### 3.4 Directory Structure

Ensure the following structure on DreamHost:

```
~/health-app-api/
├── public/
│   └── index.php
├── src/
│   ├── Controllers/
│   ├── Services/
│   ├── Middleware/
│   └── Utils/
├── config/
│   ├── app.php
│   └── database.php
├── database/
│   └── schema.sql
├── scripts/
├── vendor/
│   └── [composer dependencies]
├── .env
├── .env.example
├── composer.json
└── composer.lock
```

## Step 4: Configure Environment Variables

### 4.1 Create .env File

```bash
ssh username@health.martinfourier.com
cd ~/health-app-api

# Copy example
cp .env.example .env

# Edit .env
nano .env
# OR
vim .env
```

### 4.2 Set Production Values

Edit `.env` file with production values:

```bash
APP_ENV=production
APP_DEBUG=false
API_BASE_URL=https://health.martinfourier.com/api

# Database (from Step 2)
DB_HOST=localhost
DB_PORT=3306
DB_NAME=health_app
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password

# JWT - Generate strong random string
# Use: openssl rand -base64 32
JWT_SECRET=CHANGE_THIS_TO_STRONG_RANDOM_SECRET

# Google OAuth (from Google Cloud Console)
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=

# Email (Gmail App Password)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-gmail-app-password
SMTP_ENCRYPTION=tls
EMAIL_FROM=noreply@health.martinfourier.com
EMAIL_FROM_NAME=Health Management App

# CORS
CORS_ALLOWED_ORIGINS=https://health.martinfourier.com,https://www.health.martinfourier.com

# Rate Limiting
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_AUTH_REQUESTS=5

# Sync
SYNC_MAX_BATCH_SIZE=100
SYNC_WINDOW_DAYS=30

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
LOG_MAX_FILES=30
```

### 4.3 Generate JWT Secret

```bash
# Generate 32-byte random secret
openssl rand -base64 32

# Example output:
# Xy7bN9zQ2tR4kL8mW3hO5dP6jA1sV7nE3fY9c=

# Use this value for JWT_SECRET in .env
```

### 4.4 Set Secure Permissions

```bash
# Set .env to be readable only by owner
chmod 600 .env

# Verify
ls -la .env
# Should show: -rw------- (600)
```

## Step 5: Configure SSL/HTTPS

### 5.1 Enable Let's Encrypt Certificate

1. Log in to DreamHost panel
2. Navigate to **Domains > Manage Domains**
3. Find `health.martinfourier.com`
4. Click "HTTPS" or "Secure" tab
5. Click "Add Let's Encrypt"
6. Select domain: `health.martinfourier.com`
7. Click "Issue"
8. Wait for certificate to be issued (1-5 minutes)

### 5.2 Configure HTTP to HTTPS Redirect

In `public/.htaccess` file, add:

```apache
# Force HTTPS
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
```

If `.htaccess` doesn't exist, create it:

```bash
ssh username@health.martinfourier.com
cd ~/health-app-api/public
nano .htaccess
# Add above content
```

### 5.3 Verify HTTPS Works

```bash
curl -I https://health.martinfourier.com/api/v1/health
# Should return: HTTP/2 200

# Test HTTP redirect to HTTPS
curl -I http://health.martinfourier.com/api/v1/health
# Should return: HTTP/1.1 301 Moved Permanently (with Location: https://...)
```

## Step 6: Test Backend Health Check

```bash
# Test health endpoint
curl https://health.martinfourier.com/api/v1/health

# Expected response:
# {
#   "status": "success",
#   "data": {
#     "status": "ok"
#   },
#   "message": "Health check passed"
# }
```

## Step 7: Test Authentication Flow

### 7.1 Test Registration

```bash
curl -X POST https://health.martinfourier.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "name": "Test User"
  }'
```

### 7.2 Test Login

```bash
# Login and get tokens
TOKENS=$(curl -X POST https://health.martinfourier.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!"
  }')

# Extract access token
ACCESS_TOKEN=$(echo $TOKENS | jq -r '.data.access_token')

# Test protected endpoint with token
curl -X GET https://health.martinfourier.com/api/v1/user/profile \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### 7.3 Test Password Reset Request

```bash
curl -X POST https://health.martinfourier.com/api/v1/auth/password-reset/request \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

Check your email for password reset link.

## Step 8: Configure Logging

### 8.1 Create Logs Directory

```bash
ssh username@health.martinfourier.com
cd ~/health-app-api
mkdir -p logs
chmod 755 logs
```

### 8.2 Test Logging

```bash
# Make a test request
curl -X POST https://health.martinfourier.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "InvalidPassword!"
  }'

# Check logs
ssh username@health.martinfourier.com
tail -f logs/app.log

# Should see login attempt in logs
```

## Step 9: Troubleshooting

### Common Issues

#### Issue: Database Connection Failed

**Symptoms**:
- "Access denied for user" error
- "Unknown database" error

**Solutions**:
1. Verify database credentials in `.env`
2. Check database name matches (case-sensitive)
3. Ensure database was created
4. Check MySQL user has proper permissions

#### Issue: Composer Install Fails

**Symptoms**:
- "Could not find package" errors
- "Permission denied" errors

**Solutions**:
1. Check PHP version (8.1+ required)
2. Verify `composer.json` is uploaded
3. Run with verbose output: `composer install -vvv`
4. Ensure sufficient PHP memory

#### Issue: 500 Internal Server Error

**Symptoms**:
- API returns 500 for all requests

**Solutions**:
1. Check logs: `tail -f logs/app.log`
2. Check PHP error logs in DreamHost panel
3. Verify all PHP files are uploaded
4. Test with `APP_DEBUG=true` for detailed errors

#### Issue: 403 Forbidden

**Symptoms**:
- "Access forbidden" or "403 Forbidden" errors

**Solutions**:
1. Check file permissions (should be 644 for files, 755 for dirs)
2. Verify `.env` file permissions (should be 600)
3. Check `.htaccess` rules

#### Issue: SSL Certificate Not Working

**Symptoms**:
- "Connection not secure" or SSL errors
- Mixed content warnings

**Solutions**:
1. Verify Let's Encrypt is issued
2. Check `.htaccess` redirect rules
3. Ensure all assets load over HTTPS
4. Test with different browsers

## Step 10: Production Checklist

Before going live, verify:

- [ ] Database created and schema imported
- [ ] All code files uploaded
- [ ] Composer dependencies installed
- [ ] `.env` configured with production values
- [ ] JWT_SECRET changed from default
- [ ] SSL/HTTPS enabled and tested
- [ ] Health check endpoint returns 200
- [ ] Registration/login flow tested
- [ ] Protected routes working (with JWT)
- [ ] Error logging to `logs/app.log`
- [ ] File permissions set correctly
- [ ] CORS configured for production domain

## Backup and Rollback

### Backup Before Deployment

```bash
# Backup current production if exists
ssh username@health.martinfourier.com
cd ~/health-app-api
tar -czf ../backup-$(date +%Y%m%d).tar.gz .

# Download backup
scp username@health.martinfourier.com:~/../backup-*.tar.gz ./
```

### Rollback If Issues

```bash
# If deployment fails, restore from backup
ssh username@health.martinfourier.com
cd ~
tar -xzf backup-YYYYMMDD.tar.gz
cp -r backup-health-app-api/* ~/health-app-api/

# Rollback database
ssh username@health.martinfourier.com
mysql -u username -p health_app < ~/backup/schema-rollback.sql
```

## Monitoring

### Set Up Monitoring

1. Enable DreamHost email notifications for:
   - High CPU usage
   - Disk space alerts
   - SSL certificate expiry
   - Account breaches

2. Monitor logs regularly:
   ```bash
   ssh username@health.martinfourier.com
   tail -f ~/health-app-api/logs/app.log
   ```

3. Check API uptime:
   ```bash
   # Use uptime monitoring service like UptimeRobot or Pingdom
   ```

## Security Notes

- Always use HTTPS in production
- Keep `.env` file permissions at 600 (owner read/write only)
- Regularly update dependencies (`composer update`)
- Monitor logs for suspicious activity
- Use strong random secrets (32+ bytes)
- Enable rate limiting on authentication endpoints
- Keep SSL certificates up to date
- Review `.htaccess` for security headers

## References

- [DreamHost Documentation](https://help.dreamhost.com/hc/en-us)
- [Let's Encrypt Documentation](https://letsencrypt.org/)
- [PHP Composer](https://getcomposer.org/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Apache .htaccess Guide](https://httpd.apache.org/docs/current/mod/mod_rewrite.html)

---

**Last Updated**: 2026-01-04

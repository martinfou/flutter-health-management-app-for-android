# Laravel Backend Setup Guide

Complete setup guide for the Health Management App Laravel backend with Docker database.

## Prerequisites

- PHP 8.1 or higher
- Composer
- Docker Desktop (for database)
- Node.js & npm (for frontend assets)

## Quick Start

### 1. Start Docker Database

**First time setup:**

1. **Open Docker Desktop** (if not already running)
   - On macOS: Applications → Docker
   - Wait for Docker to fully start (whale icon in menu bar)

2. **Start the database containers:**
   ```bash
   cd /Volumes/T7/src/ai-recipes/flutter-health-management-app-for-android/backend/laravel-app
   ./docker-start.sh
   ```

   Or manually:
   ```bash
   docker compose up -d
   ```

3. **Verify containers are running:**
   ```bash
   docker compose ps
   ```

### 2. Configure Environment

The `.env` file is already configured for Docker. Verify these settings:

```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=health_app
DB_USERNAME=health_app_user
DB_PASSWORD=health_app_password
```

### 3. Start Laravel Server

```bash
php artisan serve --port=9000
```

## Access Points

### 🌐 Web Dashboard
- **URL**: http://localhost:9000
- **Login**: http://localhost:9000/login
- **Auth**: Google OAuth (users can view their own data)

### 🔌 API Endpoints (for Flutter App)
- **Base URL**: http://localhost:9000/api/v1
- **Auth**: JWT tokens
- **Documentation**: See routes/api.php

### 🗄️ Database Management
- **phpMyAdmin**: http://localhost:8080
  - Server: `mysql`
  - Username: `health_app_user`
  - Password: `health_app_password`

## Database Schema

The database schema includes:
- ✅ `users` - User accounts (Google OAuth + email/password)
- ✅ `health_metrics` - Daily health tracking
- ✅ `meals` - Nutrition logs
- ✅ `exercises` - Workout logs
- ✅ `medications` - Medication tracking
- ✅ `meal_plans` - Meal planning
- ✅ `sync_status` - Multi-device sync
- ✅ `password_resets` - Password reset tokens

Schema is auto-initialized from: `docker/mysql/init/01-schema.sql`

## Important Configuration

### Google OAuth Setup

Before using Google Sign-In, update `.env`:

```env
GOOGLE_CLIENT_SECRET=your-actual-google-client-secret
```

**Get Google OAuth credentials:**
1. Go to: https://console.cloud.google.com/
2. Select your project
3. APIs & Services → Credentials
4. Find your OAuth 2.0 Client ID
5. Copy the Client Secret

### JWT Secret (for API compatibility with Slim)

Update `.env` with the **same secret** used in your Slim API:

```env
JWT_SECRET=your-actual-jwt-secret-from-slim-api
```

This ensures JWT tokens are compatible between Laravel and Slim during migration.

## API Testing

### Test API is Running
```bash
curl http://localhost:9000/api/v1
```

Expected response:
```json
{
  "success": true,
  "message": "API information retrieved",
  "data": {
    "name": "Health Management App API",
    "version": "1.0.0",
    "status": "development"
  }
}
```

### Test User Registration
```bash
curl -X POST http://localhost:9000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

## Docker Commands

### Start Database
```bash
docker compose up -d
```

### Stop Database
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f mysql
```

### Reset Database (deletes all data)
```bash
docker compose down -v
docker compose up -d
```

### Access MySQL CLI
```bash
docker compose exec mysql mysql -u health_app_user -phealth_app_password health_app
```

### Backup Database
```bash
docker compose exec mysql mysqldump -u health_app_user -phealth_app_password health_app > backup.sql
```

### Restore Database
```bash
docker compose exec -T mysql mysql -u health_app_user -phealth_app_password health_app < backup.sql
```

## Troubleshooting

### Docker won't start
1. Open Docker Desktop application
2. Wait for it to fully start (green icon)
3. Try again

### Port 3306 already in use
```bash
# Check what's using the port
lsof -i :3306

# Stop existing MySQL
brew services stop mysql
# or
sudo systemctl stop mysql
```

### Port 9000 already in use
```bash
# Use a different port
php artisan serve --port=8001
```

### Can't connect to database
1. Check containers: `docker compose ps`
2. Check logs: `docker compose logs mysql`
3. Test connection: `docker compose exec mysql mysql -u health_app_user -phealth_app_password -e "SELECT 1"`

### Laravel shows "SQLSTATE[HY000] [2002] Connection refused"
- Wait 5-10 seconds for MySQL to fully start
- Check Docker containers: `docker compose ps`
- Restart containers: `docker compose restart`

## Development Workflow

### Daily workflow
```bash
# 1. Start Docker (if not running)
./docker-start.sh

# 2. Start Laravel server
php artisan serve --port=9000

# 3. Access dashboard: http://localhost:9000
# 4. Test API: http://localhost:9000/api/v1
```

### Stop everything
```bash
# Stop Laravel (Ctrl+C in terminal)

# Stop Docker
docker compose down
```

## API Routes Available

Run `php artisan route:list` to see all routes:

**API Authentication:**
- POST /api/v1/auth/register
- POST /api/v1/auth/login
- POST /api/v1/auth/verify-google
- POST /api/v1/auth/refresh
- POST /api/v1/auth/logout

**User Profile:**
- GET /api/v1/user/profile
- PUT /api/v1/user/profile
- DELETE /api/v1/user/account

**Health Metrics:**
- GET /api/v1/health-metrics (list with filters)
- POST /api/v1/health-metrics (create)
- GET /api/v1/health-metrics/{id} (show)
- PUT /api/v1/health-metrics/{id} (update)
- DELETE /api/v1/health-metrics/{id} (delete)
- POST /api/v1/health-metrics/sync (bulk sync)

## Next Steps

1. ✅ Database running (Docker)
2. ✅ Laravel server running (port 9000)
3. ⚠️ Update GOOGLE_CLIENT_SECRET in .env
4. ⚠️ Update JWT_SECRET in .env
5. 🎯 Test Google OAuth login
6. 🎯 Point Flutter app to http://localhost:9000/api/v1
7. 🎯 Test data sync from Flutter app

## Production Deployment

For production:
- Use managed MySQL (not Docker)
- Set strong database passwords
- Configure proper JWT_SECRET
- Enable HTTPS
- Set APP_ENV=production
- Set APP_DEBUG=false
- Run: `php artisan config:cache`
- Run: `php artisan route:cache`
- Run: `php artisan view:cache`

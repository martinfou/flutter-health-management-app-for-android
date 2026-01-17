# Health Management App Backend

This backend provides REST API services for the Flutter health management app. The backend is built with Laravel and provides all necessary API endpoints for health tracking, nutrition, exercise, and medication management.

## Architecture

- **Backend Framework**: Laravel (PHP)
- **Database**: MySQL (production) / SQLite (development)
- **Authentication**: JWT tokens
- **API**: RESTful with standardized JSON responses

## Quick Start

### Prerequisites
- PHP 8.1+
- Composer
- MySQL (production) or SQLite (development)
- Node.js & npm (for frontend assets)

### Start the Backend Server

```bash
# From project root directory
./backend/start-backend.sh
```

Or manually:

```bash
cd backend/laravel-app
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
```

### Test the API

```bash
# Health check
curl http://localhost:8000/api/v1/health

# Register a user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'

# Create a health metric
curl -X POST http://localhost:8000/api/v1/health-metrics \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"date":"2026-01-04","weight_kg":75.2,"sleep_hours":7.5,"energy_level":8}'
```

## Environment Configuration

- Copy `laravel-app/.env.example` to `laravel-app/.env`
- Configure database settings, JWT secret, and other environment variables
- Set `ACTIVE_BACKEND=laravel` (default) or `slim` for fallback

## Database

### Development (SQLite)
- Database file: `laravel-app/database/database.sqlite`
- Run migrations: `php artisan migrate`

### Production (MySQL)
- Configure MySQL connection in `.env`
- Run migrations: `php artisan migrate`

## Development

- Laravel API runs on `http://localhost:8000`
- Health endpoint: `/api/v1/health`
- API documentation: `/api/documentation` (Laravel API)
- All endpoints documented in `docs/openapi.yaml`
- Postman collection available in `docs/postman_collection.json`

### Running Tests

```bash
cd backend/laravel-app
php artisan test --filter Api
```

## Migration Complete

The backend has been fully migrated from the legacy Slim PHP API to Laravel. All endpoints are now served by Laravel with comprehensive testing and error handling.

## Production Deployment

For production deployment to DreamHost:
- Use `deploy.sh` for automated deployment (deploys both backends)
- Configure environment variables in DreamHost panel
- Set up SSL certificates
- Use MySQL database
- The toggle system allows instant rollback if needed
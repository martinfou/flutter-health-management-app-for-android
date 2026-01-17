# Health Management App - Laravel Backend

This is the Laravel backend for the Flutter health management app. It provides REST API endpoints for health tracking, nutrition, exercise, and medication management.

## Migration Complete ✅

This Laravel backend has successfully replaced the legacy Slim PHP API. The migration included:

- ✅ Full CRUD operations for all entities (Meals, Exercises, Medications, Meal Plans, Health Metrics)
- ✅ JWT authentication with middleware
- ✅ Comprehensive API testing suite (20+ test files)
- ✅ Database migrations and seeders
- ✅ Email service integration
- ✅ Rate limiting and CORS protection
- ✅ Production deployment and testing

## Setup & Installation

### Prerequisites
- PHP 8.1+
- Composer
- MySQL (production) or SQLite (development)
- Node.js & npm (for asset compilation)

### Installation

```bash
# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Run database migrations
php artisan migrate

# (Optional) Seed database with test data
php artisan db:seed
```

### Environment Configuration

Key environment variables:
```env
APP_NAME="Health Management App"
APP_ENV=local
APP_KEY=your-generated-key
APP_DEBUG=true

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=health_app
DB_USERNAME=your_username
DB_PASSWORD=your_password

JWT_SECRET=your-jwt-secret

# Backend toggle (laravel = default, slim = fallback)
ACTIVE_BACKEND=laravel
```

## Running the Application

```bash
# Start development server
php artisan serve

# Run tests
php artisan test

# Run specific API tests
php artisan test --filter Api
```

## API Endpoints

All endpoints require JWT authentication (except auth endpoints):

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `POST /api/v1/auth/logout` - Logout user

### Health Metrics
- `GET /api/v1/health-metrics` - List health metrics
- `POST /api/v1/health-metrics` - Create health metric
- `GET /api/v1/health-metrics/{id}` - Get specific metric
- `PUT /api/v1/health-metrics/{id}` - Update metric
- `DELETE /api/v1/health-metrics/{id}` - Delete metric
- `POST /api/v1/health-metrics/sync` - Sync metrics

### Meals
- `GET /api/v1/meals` - List meals with filtering
- `POST /api/v1/meals` - Create meal
- `GET /api/v1/meals/{id}` - Get specific meal
- `PUT /api/v1/meals/{id}` - Update meal
- `DELETE /api/v1/meals/{id}` - Delete meal
- `POST /api/v1/meals/sync` - Sync meals

### Exercises
- `GET /api/v1/exercises` - List exercises with filtering
- `POST /api/v1/exercises` - Create exercise or template
- `GET /api/v1/exercises/{id}` - Get specific exercise
- `PUT /api/v1/exercises/{id}` - Update exercise
- `DELETE /api/v1/exercises/{id}` - Delete exercise
- `POST /api/v1/exercises/sync` - Sync exercises

### Medications
- `GET /api/v1/medications` - List medications
- `POST /api/v1/medications` - Create medication
- `GET /api/v1/medications/{id}` - Get specific medication
- `PUT /api/v1/medications/{id}` - Update medication
- `DELETE /api/v1/medications/{id}` - Delete medication
- `POST /api/v1/medications/sync` - Sync medications

### Meal Plans
- `GET /api/v1/meal-plans` - List meal plans
- `POST /api/v1/meal-plans` - Create meal plan
- `GET /api/v1/meal-plans/{id}` - Get specific meal plan
- `PUT /api/v1/meal-plans/{id}` - Update meal plan
- `DELETE /api/v1/meal-plans/{id}` - Delete meal plan
- `POST /api/v1/meal-plans/sync` - Sync meal plans

## Backend Status

Laravel is now the only backend system. The legacy Slim PHP API has been removed from the codebase. All API requests are handled by Laravel with no fallback system needed.

## Testing

```bash
# Run all tests
php artisan test

# Run API tests only
php artisan test --filter Api

# Run with coverage
php artisan test --coverage
```

## Deployment

For production deployment:
- Use the root `deploy.sh` script (deploys both Laravel and Slim)
- Configure MySQL database
- Set environment variables
- Run migrations: `php artisan migrate --force`
- Set `APP_ENV=production` and `APP_DEBUG=false`

## Architecture

- **Framework**: Laravel 10.x
- **Authentication**: JWT tokens with custom middleware
- **Database**: Eloquent ORM with migrations
- **API**: RESTful with consistent JSON responses
- **Testing**: PHPUnit with comprehensive test coverage
- **Email**: Laravel Mail for notifications
- **Rate Limiting**: Laravel's built-in throttling
- **CORS**: Configurable cross-origin requests

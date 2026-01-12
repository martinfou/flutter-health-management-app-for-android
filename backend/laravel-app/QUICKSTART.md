# Laravel Backend - Quick Start Guide

## Database Setup ✅ COMPLETED

All migrations have been run successfully:
- ✅ Framework tables (users, cache, jobs, sessions)
- ✅ Health tracking tables (health_metrics, meals, exercises, medications, meal_plans, sync_status)
- ✅ Rate limiting tables (rate_limit_requests, rate_limit_blocks)
- ✅ Users table updated with Google OAuth and health profile fields

**Database:** SQLite (database/database.sqlite)

## Running the Server

### Start the Laravel development server:
```bash
php artisan serve --port=9000
```

The API will be available at: `http://localhost:9000/api/v1`

### In another terminal, you can test endpoints:

```bash
# Test API info endpoint
curl http://localhost:9000/api/v1/

# Register a user
curl -X POST http://localhost:9000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'

# Login
curl -X POST http://localhost:9000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Create a meal (requires JWT token from login)
curl -X POST http://localhost:9000/api/v1/meals \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "date": "2026-01-11",
    "meal_type": "breakfast",
    "name": "Oatmeal with berries",
    "calories": 350
  }'
```

## API Endpoints Available

### Authentication (No JWT required)
- POST `/api/v1/auth/register` - Register new user
- POST `/api/v1/auth/login` - Login with email/password
- POST `/api/v1/auth/verify-google` - Login with Google
- POST `/api/v1/auth/refresh` - Refresh access token

### Protected Endpoints (JWT required)

**Auth & Profile:**
- POST `/api/v1/auth/logout`
- GET `/api/v1/user/profile`
- PUT `/api/v1/user/profile`
- DELETE `/api/v1/user/account`

**Health Metrics:** (6 endpoints)
- GET `/api/v1/health-metrics` - List
- POST `/api/v1/health-metrics` - Create
- GET `/api/v1/health-metrics/{id}` - Get
- PUT `/api/v1/health-metrics/{id}` - Update
- DELETE `/api/v1/health-metrics/{id}` - Delete
- POST `/api/v1/health-metrics/sync` - Bulk sync

**Meals:** (6 endpoints)
- GET `/api/v1/meals`
- POST `/api/v1/meals`
- GET `/api/v1/meals/{id}`
- PUT `/api/v1/meals/{id}`
- DELETE `/api/v1/meals/{id}`
- POST `/api/v1/meals/sync`

**Exercises:** (6 endpoints)
- GET `/api/v1/exercises`
- POST `/api/v1/exercises`
- GET `/api/v1/exercises/{id}`
- PUT `/api/v1/exercises/{id}`
- DELETE `/api/v1/exercises/{id}`
- POST `/api/v1/exercises/sync`

**Medications:** (6 endpoints)
- GET `/api/v1/medications`
- POST `/api/v1/medications`
- GET `/api/v1/medications/{id}`
- PUT `/api/v1/medications/{id}`
- DELETE `/api/v1/medications/{id}`
- POST `/api/v1/medications/sync`

**Meal Plans:** (6 endpoints)
- GET `/api/v1/meal-plans`
- POST `/api/v1/meal-plans`
- GET `/api/v1/meal-plans/{id}`
- PUT `/api/v1/meal-plans/{id}`
- DELETE `/api/v1/meal-plans/{id}`
- POST `/api/v1/meal-plans/sync`

## All Responses Use Standard Format

```json
{
  "success": true,
  "data": {...},
  "message": "...",
  "timestamp": "2026-01-11T12:00:00+00:00"
}
```

Errors:
```json
{
  "success": false,
  "message": "Error message",
  "timestamp": "2026-01-11T12:00:00+00:00"
}
```

Paginated:
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5,
    "has_next": true,
    "has_prev": false
  },
  "message": "...",
  "timestamp": "..."
}
```

## Rate Limiting

- **General endpoints:** 100 requests per minute
- **Auth endpoints:** 5 requests per minute
- Rate limit headers added to all responses:
  - `X-RateLimit-Limit`
  - `X-RateLimit-Remaining`
  - `X-RateLimit-Reset`

## CORS Support

- Configured for `*` (all origins) by default
- Change via `CORS_ALLOWED_ORIGINS` in `.env`
- Preflight OPTIONS requests handled automatically

## Testing with Postman

1. **Import environment variables:**
   - `base_url`: http://localhost:9000
   - `token`: (set after login)

2. **Register a user** (POST to auth/register)
3. **Copy the `access_token`** from response
4. **Set `Authorization`** header to `Bearer {token}`
5. **Test other endpoints** with the token

## Troubleshooting

### Database Connection Error
If you get "database file missing":
```bash
touch database/database.sqlite
php artisan migrate
```

### Port Already in Use
```bash
php artisan serve --port=8000  # Use different port
```

### Clear Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

## Next Steps

1. ✅ Database setup complete
2. ⏳ Refactor AuthController & HealthMetricsController to use ResponseHelper (2 hrs)
3. ⏳ Create integration tests (3-4 hrs)
4. ⏳ Update documentation (1 hr)

See `/IMPLEMENTATION_SUMMARY.md` for complete implementation status.

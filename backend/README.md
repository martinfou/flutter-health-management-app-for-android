# Health Management App Backend

## Quick Start

### Prerequisites
- PHP 8.1+
- Composer
- SQLite3 (for local development)

### Start the Backend Server

```bash
# From project root directory
./backend/start-backend.sh
```

Or manually:

```bash
cd backend/api
composer install
php -S localhost:8000 -t public
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
  -d '{"date":"2026-01-04","weight_kg":75.2,"sleep_hours":7.5,"energy_level":8}'
```

## Environment Configuration

- Copy `config/.env.example` to `config/.env`
- Modify settings as needed (database, JWT secret, etc.)
- The start script will automatically use the .env file

## Database

SQLite is used for local development:
- Database file: `/tmp/health_app.db`
- Schema: `database/schema.sqlite.sql`
- Run `sqlite3 /tmp/health_app.db < database/schema.sqlite.sql` to set up

## Development

- API runs on `http://localhost:8000`
- Health endpoint: `/api/v1/health`
- All endpoints documented in `docs/openapi.yaml`
- Postman collection available in `docs/postman_collection.json`

## Production Deployment

For production deployment to DreamHost:
- Use `scripts/deploy-dreamhost.sh` for automated deployment
- Configure environment variables in DreamHost
- Set up SSL certificates
- Use MySQL database instead of SQLite
# Health Management App Backend API

Complete REST API for the Flutter Health Management App providing comprehensive health tracking, nutrition logging, exercise management, and cross-device synchronization.

## 🚀 Quick Start

### Prerequisites
- PHP 8.1+
- MySQL 8.0+
- Composer

### Installation
```bash
cd backend/api
composer install
cp config/.env.example config/.env
# Edit config/.env with your database and JWT settings
```

### Database Setup
```bash
mysql -u root -p < database/schema.sql
```

### Start Development Server
```bash
composer start
# API available at http://localhost:8000/api/v1
```

## 📚 API Documentation

### OpenAPI Specification
The API is fully documented using OpenAPI 3.0.3 specification:

- **File**: `docs/openapi.yaml`
- **Interactive Docs**: Import into Swagger UI or any OpenAPI-compatible viewer
- **Complete Coverage**: All endpoints, request/response schemas, authentication

### Postman Collection
Ready-to-use Postman collection for testing:

- **File**: `docs/postman_collection.json`
- **Import**: Open Postman → Import → Upload File
- **Environment Variables**:
  - `base_url`: API base URL (default: `http://localhost:8000/api/v1`)
  - `access_token`: JWT access token (auto-populated)
  - `refresh_token`: JWT refresh token (auto-populated)
  - `user_id`: Current user ID (auto-populated)

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication:

1. **Register/Login** to get access and refresh tokens
2. **Include Bearer token** in `Authorization` header for protected endpoints
3. **Refresh tokens** automatically when they expire

```bash
# Example request with authentication
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     https://api.example.com/v1/health-metrics
```

## 📋 API Endpoints Overview

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/refresh` - Refresh access token
- `POST /auth/verify-google` - Google OAuth verification
- `GET /auth/profile` - Get user profile
- `PUT /auth/profile` - Update user profile
- `DELETE /auth/account` - Delete account (GDPR)

### Health Metrics
- `GET /health-metrics` - List health metrics (with filtering/pagination)
- `POST /health-metrics` - Create health metric
- `GET /health-metrics/{id}` - Get specific health metric
- `PUT /health-metrics/{id}` - Update health metric
- `DELETE /health-metrics/{id}` - Delete health metric
- `POST /health-metrics/sync` - Bulk sync health metrics

### Medications
- `GET /medications` - List medications
- `POST /medications` - Create medication
- `GET /medications/{id}` - Get medication
- `PUT /medications/{id}` - Update medication
- `DELETE /medications/{id}` - Delete medication
- `POST /medications/sync` - Bulk sync medications

### Meals
- `GET /meals` - List meals (with filtering)
- `POST /meals` - Create meal
- `GET /meals/{id}` - Get meal
- `PUT /meals/{id}` - Update meal
- `DELETE /meals/{id}` - Delete meal
- `POST /meals/sync` - Bulk sync meals

### Exercises
- `GET /exercises` - List exercises
- `POST /exercises` - Create exercise/template
- `GET /exercises/{id}` - Get exercise
- `PUT /exercises/{id}` - Update exercise
- `DELETE /exercises/{id}` - Delete exercise
- `POST /exercises/sync` - Bulk sync exercises

### Meal Plans
- `GET /meal-plans` - List meal plans
- `POST /meal-plans` - Create meal plan
- `GET /meal-plans/{id}` - Get meal plan
- `PUT /meal-plans/{id}` - Update meal plan
- `DELETE /meal-plans/{id}` - Delete meal plan
- `POST /meal-plans/sync` - Bulk sync meal plans

### Sync & System
- `GET /sync/status` - Get sync status
- `POST /sync/bulk` - Bulk sync all entities
- `POST /sync/resolve-conflicts` - Resolve sync conflicts
- `GET /health` - Health check

## 🔒 Security Features

- **Rate Limiting**: 100 req/min general, 5 req/min auth endpoints
- **CORS Protection**: Configurable allowed origins
- **Input Validation**: Comprehensive validation on all endpoints
- **SQL Injection Prevention**: Parameterized queries throughout
- **JWT Security**: Secure token generation and validation
- **HTTPS Enforcement**: Automatic redirect to HTTPS
- **Error Handling**: Safe error responses without data leakage

## 📊 Response Format

All API responses follow a consistent format:

### Success Response
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Operation completed successfully",
  "timestamp": "2026-01-04T12:00:00Z"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "error_code": "ERROR_CODE",
  "timestamp": "2026-01-04T12:00:00Z"
}
```

### Validation Error Response
```json
{
  "success": false,
  "message": "Validation failed",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "field_name": "Error message"
  },
  "timestamp": "2026-01-04T12:00:00Z"
}
```

## 🔄 Sync Architecture

The API supports offline-first architecture with comprehensive sync capabilities:

- **Incremental Sync**: Sync only changed data since last sync
- **Conflict Resolution**: Last-write-wins strategy with manual override
- **Bulk Operations**: Efficient bulk sync for multiple entities
- **Sync Status Tracking**: Monitor sync state across devices
- **Cross-Device Support**: Seamless data synchronization

## 🧪 Testing

### Using Postman
1. Import `docs/postman_collection.json`
2. Set environment variables
3. Run authentication requests first to get tokens
4. Test protected endpoints with automatic token handling

### Manual Testing
```bash
# Health check
curl http://localhost:8000/api/v1/health

# Register user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'
```

## 🚀 Deployment

### Development
```bash
composer start  # Starts PHP built-in server
```

### Production (DreamHost)
1. Set up DreamHost account with PHP 8.1+ and MySQL
2. Deploy code via FTP/SFTP
3. Configure environment variables
4. Set up SSL certificate
5. Run database migrations
6. Configure Apache/.htaccess routing

### CI/CD
GitHub Actions workflow included for automated deployment:
- Automated testing
- Dependency installation
- Deployment to DreamHost
- Health checks post-deployment

## 📝 Development Notes

### Architecture
- **Framework**: Slim 4.x (PSR-7 compliant)
- **Database**: MySQL with PDO
- **Authentication**: JWT with refresh tokens
- **Validation**: Respect/Validation library
- **Error Handling**: Structured middleware-based approach

### Code Organization
```
src/
├── Controllers/     # Route handlers
├── Middleware/      # PSR-15 middleware
├── Services/        # Business logic services
├── Utils/          # Helper utilities
└── Models/         # Data models (future)
```

### Database Schema
Complete MySQL schema in `database/schema.sql` with:
- User management tables
- Health tracking tables
- Sync infrastructure
- Proper indexing and foreign keys

## 🤝 Contributing

1. Follow PSR-12 coding standards
2. Add OpenAPI documentation for new endpoints
3. Update Postman collection for API changes
4. Include comprehensive validation
5. Add appropriate error handling

## 📞 Support

For API integration questions or issues:
- Check the OpenAPI specification
- Review Postman collection examples
- Test with provided health check endpoint
- Check application logs for detailed error information
# Sync Architecture Design (Post-MVP)

## Overview

This document defines the post-MVP sync architecture for multi-device data synchronization using DreamHost PHP/MySQL backend with Slim Framework. This architecture enables users to access their health data across multiple devices while maintaining offline-first functionality and data privacy.

**⚠️ POST-MVP FEATURE**: This architecture is designed for Implementation Phase 2, not required for MVP.

**Reference**: Based on requirements in `artifacts/requirements.md` and data models in `artifacts/phase-1-foundations/data-models.md`.

## Architecture Principles

### Core Principles

1. **Offline-First**: App works fully offline, sync happens in background
2. **Privacy-First**: Data stored securely with HTTPS/SSL, user must opt-in
3. **Optional**: User explicitly enables sync, can disable at any time
4. **Conflict Resolution**: Timestamp-based (last write wins) with merge strategies
5. **Cost-Effective**: Reasonable costs for individual users
6. **Secure**: JWT authentication, HTTPS/SSL, secure password hashing

### Sync Strategy

- **Local-First**: All data stored locally in Hive, sync is optional enhancement
- **Background Sync**: Sync happens in background, doesn't block user
- **Incremental**: Only sync changed data since last sync
- **Bidirectional**: Sync from server to device and device to server
- **Conflict Resolution**: Timestamp-based with custom merge for complex cases

## Backend Architecture

### Technology Stack

- **Backend Framework**: Slim Framework 4.x
- **Language**: PHP 8.1+
- **Database**: MySQL (via DreamHost)
- **Authentication**: JWT tokens (firebase/php-jwt)
- **API Style**: REST API with JSON
- **Security**: HTTPS/SSL (Let's Encrypt via DreamHost)
- **Hosting**: DreamHost shared hosting

### Why Slim Framework?

1. **Lightweight**: Minimal overhead (~2MB footprint)
2. **Shared Hosting Compatible**: Works perfectly on DreamHost
3. **REST API Focused**: Built specifically for REST APIs
4. **Easy Deployment**: Simple file structure, no complex configuration
5. **Modern PHP**: Uses PSR standards, dependency injection included
6. **Security**: Built-in security features, middleware support
7. **Active Development**: Well-maintained, good documentation

### Project Structure

```
api/
├── public/
│   ├── index.php              # Entry point
│   └── .htaccess              # Apache routing
├── src/
│   ├── Middleware/
│   │   ├── AuthMiddleware.php      # JWT validation
│   │   ├── CorsMiddleware.php      # CORS handling
│   │   └── ErrorMiddleware.php     # Error handling
│   ├── Controllers/
│   │   ├── AuthController.php      # Authentication endpoints
│   │   ├── HealthMetricsController.php
│   │   ├── MedicationsController.php
│   │   ├── MealsController.php
│   │   ├── ExercisesController.php
│   │   ├── MealPlansController.php
│   │   └── SyncController.php     # Bulk sync endpoint
│   ├── Services/
│   │   ├── DatabaseService.php     # Database operations
│   │   ├── AuthService.php         # Authentication logic
│   │   ├── SyncService.php         # Sync logic
│   │   └── ConflictResolver.php    # Conflict resolution
│   ├── Models/
│   │   ├── User.php
│   │   ├── HealthMetric.php
│   │   ├── Medication.php
│   │   └── SyncStatus.php
│   └── Utils/
│       ├── JwtHelper.php
│       └── ResponseHelper.php
├── config/
│   ├── database.php           # Database configuration
│   ├── app.php                # App configuration
│   └── .env                   # Environment variables
├── vendor/                    # Composer dependencies
├── composer.json
└── .htaccess                   # Root .htaccess
```

## Database Schema (MySQL)

### Users Table

```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,           -- UUID
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,  -- bcrypt hash
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_sync_at TIMESTAMP NULL,
    sync_enabled BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_sync_enabled (sync_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Health Metrics Table

```sql
CREATE TABLE health_metrics (
    id VARCHAR(36) PRIMARY KEY,           -- UUID
    user_id VARCHAR(36) NOT NULL,         -- FK to users
    data JSON NOT NULL,                   -- Full HealthMetric JSON
    updated_at TIMESTAMP NOT NULL,        -- For conflict resolution
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,            -- Soft delete
    INDEX idx_user_id (user_id),
    INDEX idx_updated_at (updated_at),
    INDEX idx_user_updated (user_id, updated_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Medications Table

```sql
CREATE TABLE medications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    data JSON NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_updated_at (updated_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Meals Table

```sql
CREATE TABLE meals (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    data JSON NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_updated_at (updated_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Exercises Table

```sql
CREATE TABLE exercises (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    data JSON NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_updated_at (updated_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Meal Plans Table

```sql
CREATE TABLE meal_plans (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    data JSON NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_updated_at (updated_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Sync Status Table

```sql
CREATE TABLE sync_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,    -- 'health_metrics', 'medications', etc.
    last_sync_at TIMESTAMP NOT NULL,
    last_sync_token VARCHAR(255) NULL,   -- For incremental sync
    INDEX idx_user_entity (user_id, entity_type),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## API Endpoints

### Authentication Endpoints

#### POST /api/auth/register

Register new user account.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe"
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe"
    },
    "token": "jwt_token_here"
  }
}
```

#### POST /api/auth/login

Authenticate user and get JWT token.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe"
    },
    "token": "jwt_token_here"
  }
}
```

#### POST /api/auth/refresh

Refresh JWT token.

**Request Headers**:
```
Authorization: Bearer {refresh_token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "token": "new_jwt_token_here"
  }
}
```

### Health Metrics Endpoints

#### POST /api/health-metrics/sync

Sync health metrics (upload from device).

**Request Headers**:
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "metrics": [
    {
      "id": "uuid",
      "data": {
        "userId": "user_uuid",
        "date": "2024-01-15T00:00:00Z",
        "weight": 75.5,
        "sleepQuality": 7,
        "energyLevel": 8,
        "restingHeartRate": 68
      },
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "synced": 5,
    "conflicts": 0,
    "errors": []
  }
}
```

#### GET /api/health-metrics

Fetch health metrics (download to device).

**Request Headers**:
```
Authorization: Bearer {jwt_token}
```

**Query Parameters**:
- `since`: ISO 8601 timestamp (optional, for incremental sync)
- `limit`: Number of records (optional, default 100)

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "metrics": [
      {
        "id": "uuid",
        "data": { /* HealthMetric JSON */ },
        "updated_at": "2024-01-15T10:30:00Z"
      }
    ],
    "has_more": false,
    "next_sync_token": "token_here"
  }
}
```

### Sync Endpoints

#### POST /api/sync/bulk

Bulk sync all entity types.

**Request Headers**:
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "health_metrics": [ /* array of metrics */ ],
  "medications": [ /* array of medications */ ],
  "meals": [ /* array of meals */ ],
  "exercises": [ /* array of exercises */ ],
  "meal_plans": [ /* array of meal plans */ ],
  "last_sync_at": "2024-01-15T00:00:00Z"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "health_metrics": {
      "synced": 10,
      "conflicts": 0,
      "server_updates": [ /* array of server-side updates */ ]
    },
    "medications": {
      "synced": 3,
      "conflicts": 0,
      "server_updates": []
    },
    "meals": {
      "synced": 25,
      "conflicts": 1,
      "server_updates": []
    },
    "sync_timestamp": "2024-01-15T12:00:00Z"
  }
}
```

## Conflict Resolution

### Strategy: Timestamp-Based (Last Write Wins)

**Default Strategy**: Last write wins based on `updated_at` timestamp.

**Process**:
1. Compare `updated_at` timestamps
2. If server version is newer: Keep server version, return to client
3. If client version is newer: Update server, keep client version
4. If timestamps are equal: Keep server version (server is source of truth)

### Custom Merge Strategies

For complex entities that may have been modified in different ways:

**HealthMetric Merge**:
- Merge body measurements (keep all unique measurements)
- Keep latest weight, sleep, energy, heart rate
- Combine notes

**Meal Merge**:
- If same meal ID, same date: Last write wins
- If different dates: Keep both

**Medication Merge**:
- If same medication ID: Last write wins
- Merge side effects (keep all unique side effects)

### Conflict Response

When conflicts occur, server returns:

```json
{
  "success": true,
  "data": {
    "synced": 10,
    "conflicts": 2,
    "conflict_details": [
      {
        "entity_id": "uuid",
        "entity_type": "health_metrics",
        "client_version": { /* client data */ },
        "server_version": { /* server data */ },
        "resolution": "server_wins" // or "client_wins" or "merged"
      }
    ],
    "server_updates": [ /* server-side updates to apply */ ]
  }
}
```

## Authentication (JWT)

### Token Structure

**Access Token** (short-lived, 1 hour):
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "iat": 1234567890,
  "exp": 1234571490
}
```

**Refresh Token** (long-lived, 30 days):
```json
{
  "user_id": "uuid",
  "token_type": "refresh",
  "iat": 1234567890,
  "exp": 1237246290
}
```

### JWT Implementation (PHP)

```php
// src/Utils/JwtHelper.php
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtHelper {
    private static $secretKey;
    
    public static function generateToken($userId, $email, $expirationHours = 1) {
        $payload = [
            'user_id' => $userId,
            'email' => $email,
            'iat' => time(),
            'exp' => time() + ($expirationHours * 3600)
        ];
        
        return JWT::encode($payload, self::getSecretKey(), 'HS256');
    }
    
    public static function validateToken($token) {
        try {
            $decoded = JWT::decode($token, new Key(self::getSecretKey(), 'HS256'));
            return (array) $decoded;
        } catch (Exception $e) {
            return null;
        }
    }
    
    private static function getSecretKey() {
        if (self::$secretKey === null) {
            self::$secretKey = getenv('JWT_SECRET_KEY');
        }
        return self::$secretKey;
    }
}
```

### Auth Middleware

```php
// src/Middleware/AuthMiddleware.php
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;

class AuthMiddleware {
    public function __invoke(Request $request, RequestHandler $handler): Response {
        $authHeader = $request->getHeaderLine('Authorization');
        
        if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return $this->unauthorizedResponse();
        }
        
        $token = $matches[1];
        $payload = JwtHelper::validateToken($token);
        
        if ($payload === null) {
            return $this->unauthorizedResponse();
        }
        
        // Add user info to request
        $request = $request->withAttribute('user_id', $payload['user_id']);
        $request = $request->withAttribute('user_email', $payload['email']);
        
        return $handler->handle($request);
    }
    
    private function unauthorizedResponse(): Response {
        $response = new \Slim\Psr7\Response();
        $response->getBody()->write(json_encode([
            'success' => false,
            'error' => 'Unauthorized'
        ]));
        return $response->withStatus(401)
            ->withHeader('Content-Type', 'application/json');
    }
}
```

## Flutter Client Implementation

### Sync Service

```dart
// lib/core/sync/sync_service.dart
class SyncService {
  final String apiBaseUrl;
  final AuthService authService;
  
  Future<SyncResult> syncHealthMetrics(List<HealthMetric> metrics) async {
    final token = await authService.getAccessToken();
    if (token == null) {
      return SyncResult.failure('Not authenticated');
    }
    
    final payload = {
      'metrics': metrics.map((m) => {
        'id': m.id,
        'data': m.toJson(),
        'updated_at': m.updatedAt.toIso8601String(),
      }).toList(),
    };
    
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/health-metrics/sync'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SyncResult.success(data);
      } else {
        return SyncResult.failure('Sync failed: ${response.statusCode}');
      }
    } catch (e) {
      return SyncResult.failure('Network error: $e');
    }
  }
  
  Future<List<HealthMetric>> fetchHealthMetrics({DateTime? since}) async {
    final token = await authService.getAccessToken();
    if (token == null) {
      throw SyncException('Not authenticated');
    }
    
    final queryParams = <String, String>{};
    if (since != null) {
      queryParams['since'] = since.toIso8601String();
    }
    
    final uri = Uri.parse('$apiBaseUrl/health-metrics').replace(
      queryParameters: queryParams,
    );
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data']['metrics'] as List)
          .map((m) => HealthMetric.fromJson(m['data']))
          .toList();
    } else {
      throw SyncException('Fetch failed: ${response.statusCode}');
    }
  }
}
```

### Background Sync

```dart
// lib/core/sync/background_sync.dart
class BackgroundSync {
  final SyncService syncService;
  final HealthMetricsRepository repository;
  
  Future<void> performBackgroundSync() async {
    try {
      // Get local changes since last sync
      final lastSyncAt = await getLastSyncTimestamp();
      final localChanges = await repository.getChangedSince(lastSyncAt);
      
      // Sync to server
      final syncResult = await syncService.syncHealthMetrics(localChanges);
      
      if (syncResult.isSuccess) {
        // Fetch server updates
        final serverUpdates = await syncService.fetchHealthMetrics(
          since: lastSyncAt,
        );
        
        // Merge server updates into local database
        await repository.mergeUpdates(serverUpdates);
        
        // Update last sync timestamp
        await updateLastSyncTimestamp(DateTime.now());
      }
    } catch (e) {
      // Log error, retry later
      print('Background sync failed: $e');
    }
  }
}
```

## Security

### Password Hashing

Use bcrypt for password hashing:

```php
// Registration
$passwordHash = password_hash($password, PASSWORD_BCRYPT);

// Login
if (password_verify($password, $user->password_hash)) {
    // Valid password
}
```

### HTTPS/SSL

- Use HTTPS for all API endpoints
- DreamHost provides free Let's Encrypt SSL certificates
- Enforce HTTPS in `.htaccess`:

```apache
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

### Input Validation

- Validate all input data
- Sanitize user inputs
- Use prepared statements for database queries
- Validate JWT tokens on every request

## Error Handling

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "email": "Invalid email format",
      "password": "Password must be at least 8 characters"
    }
  }
}
```

### HTTP Status Codes

- `200 OK`: Success
- `201 Created`: Resource created
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Conflict during sync
- `500 Internal Server Error`: Server error

## Deployment

### DreamHost Setup

1. **Create Database**: Create MySQL database via DreamHost panel
2. **Upload Files**: Upload API files to `api/` directory
3. **Configure .env**: Set database credentials, JWT secret
4. **Install Dependencies**: Run `composer install`
5. **Configure .htaccess**: Set up routing
6. **Enable SSL**: Enable Let's Encrypt SSL certificate

### Environment Variables

```env
# .env
DB_HOST=localhost
DB_NAME=health_app_db
DB_USER=health_app_user
DB_PASS=secure_password
JWT_SECRET_KEY=your_secret_key_here
API_BASE_URL=https://your-domain.com/api
```

## Performance Considerations

### Database Optimization

- Use indexes on frequently queried fields
- Use JSON columns for flexible data storage
- Implement pagination for large result sets
- Use connection pooling

### Caching

- Cache user authentication tokens
- Cache frequently accessed data
- Use Redis for session storage (optional, post-MVP)

### Rate Limiting

- Implement rate limiting for API endpoints
- Limit: 100 requests per minute per user
- Return 429 Too Many Requests when exceeded

## Monitoring and Logging

### Logging

- Log all API requests
- Log authentication attempts
- Log sync operations
- Log errors with stack traces

### Monitoring

- Monitor API response times
- Monitor database query performance
- Monitor sync success/failure rates
- Set up alerts for errors

## References

- **Requirements**: `artifacts/requirements.md` - Sync requirements and technology stack
- **Data Models**: `artifacts/phase-1-foundations/data-models.md` - Entity definitions
- **Database Schema**: `artifacts/phase-1-foundations/database-schema.md` - Local database structure
- **Slim Framework**: https://www.slimframework.com/
- **JWT**: https://jwt.io/

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Sync Architecture Design Complete  
**Phase**: Post-MVP (Implementation Phase 2)


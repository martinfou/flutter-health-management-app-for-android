# API Documentation (Post-MVP)

## Overview

This document provides comprehensive API documentation for the DreamHost PHP/MySQL backend API. The API supports cloud sync, authentication, and data synchronization for the Flutter Health Management App.

**Status**: Post-MVP Feature  
**Backend**: PHP with Slim Framework  
**Database**: MySQL on DreamHost  
**Authentication**: JWT-based

## Base URL

```
Production: https://api.healthapp.example.com/v1
Development: https://dev-api.healthapp.example.com/v1
```

## Authentication

### JWT Authentication

All API requests (except authentication endpoints) require a JWT token in the Authorization header.

**Header Format**:
```
Authorization: Bearer <jwt_token>
```

### Authentication Endpoints

#### Register User

**POST** `/auth/register`

**Request Body**:
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
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### Login

**POST** `/auth/login`

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### Refresh Token

**POST** `/auth/refresh`

**Headers**:
```
Authorization: Bearer <current_token>
```

**Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Health Metrics API

### Get Health Metrics

**GET** `/health-metrics`

**Query Parameters**:
- `start_date` (optional): ISO 8601 date string
- `end_date` (optional): ISO 8601 date string
- `limit` (optional): Number of records (default: 100)
- `offset` (optional): Pagination offset (default: 0)

**Response** (200 OK):
```json
{
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "date": "2024-01-15T00:00:00Z",
      "weight": 75.5,
      "sleep_quality": 8,
      "energy_level": 7,
      "resting_heart_rate": 65,
      "body_measurements": {
        "waist": 90.0,
        "hips": 100.0
      },
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 100,
    "limit": 100,
    "offset": 0
  }
}
```

### Create Health Metric

**POST** `/health-metrics`

**Request Body**:
```json
{
  "date": "2024-01-15T00:00:00Z",
  "weight": 75.5,
  "sleep_quality": 8,
  "energy_level": 7,
  "resting_heart_rate": 65,
  "body_measurements": {
    "waist": 90.0,
    "hips": 100.0
  }
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "date": "2024-01-15T00:00:00Z",
  "weight": 75.5,
  "sleep_quality": 8,
  "energy_level": 7,
  "resting_heart_rate": 65,
  "body_measurements": {
    "waist": 90.0,
    "hips": 100.0
  },
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

### Update Health Metric

**PUT** `/health-metrics/:id`

**Request Body**: Same as create

**Response** (200 OK): Updated health metric object

### Delete Health Metric

**DELETE** `/health-metrics/:id`

**Response** (204 No Content)

## Medications API

### Get Medications

**GET** `/medications`

**Response** (200 OK):
```json
{
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "name": "Wellbutrin",
      "dosage": "150mg",
      "frequency": "daily",
      "times": ["08:00"],
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": null,
      "reminder_enabled": true,
      "created_at": "2024-01-01T10:00:00Z",
      "updated_at": "2024-01-01T10:00:00Z"
    }
  ]
}
```

### Create Medication

**POST** `/medications`

**Request Body**:
```json
{
  "name": "Wellbutrin",
  "dosage": "150mg",
  "frequency": "daily",
  "times": ["08:00"],
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": null,
  "reminder_enabled": true
}
```

**Response** (201 Created): Medication object

## Meals API

### Get Meals

**GET** `/meals`

**Query Parameters**:
- `start_date` (optional): ISO 8601 date string
- `end_date` (optional): ISO 8601 date string

**Response** (200 OK):
```json
{
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "date": "2024-01-15T00:00:00Z",
      "meal_type": "breakfast",
      "name": "Omelet",
      "protein": 30.0,
      "fats": 25.0,
      "net_carbs": 5.0,
      "calories": 305.0,
      "ingredients": ["eggs", "cheese", "butter"],
      "recipe_id": null,
      "created_at": "2024-01-15T08:00:00Z"
    }
  ]
}
```

### Create Meal

**POST** `/meals`

**Request Body**:
```json
{
  "date": "2024-01-15T00:00:00Z",
  "meal_type": "breakfast",
  "name": "Omelet",
  "protein": 30.0,
  "fats": 25.0,
  "net_carbs": 5.0,
  "calories": 305.0,
  "ingredients": ["eggs", "cheese", "butter"],
  "recipe_id": null
}
```

**Response** (201 Created): Meal object

## Sync API

### Sync Data

**POST** `/sync`

**Request Body**:
```json
{
  "last_sync": "2024-01-14T10:00:00Z",
  "health_metrics": [
    {
      "id": "uuid",
      "date": "2024-01-15T00:00:00Z",
      "weight": 75.5,
      "sync_action": "create"
    }
  ],
  "medications": [],
  "meals": []
}
```

**Response** (200 OK):
```json
{
  "sync_timestamp": "2024-01-15T10:00:00Z",
  "conflicts": [],
  "synced": {
    "health_metrics": 1,
    "medications": 0,
    "meals": 0
  }
}
```

## Error Responses

### Standard Error Format

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

### Error Codes

- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Conflict (e.g., sync conflict)
- `422 Unprocessable Entity`: Validation error
- `500 Internal Server Error`: Server error

### Validation Error Example

**Response** (422 Unprocessable Entity):
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "weight": "Weight must be between 20 and 500 kg",
      "date": "Date cannot be in the future"
    }
  }
}
```

## Rate Limiting

**Rate Limits**:
- Authentication endpoints: 5 requests per minute
- Data endpoints: 100 requests per minute
- Sync endpoints: 10 requests per minute

**Rate Limit Headers**:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

**Rate Limit Exceeded Response** (429 Too Many Requests):
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Please try again later."
  }
}
```

## References

- **Sync Architecture**: `artifacts/phase-3-integration/sync-architecture-design.md`
- **Backend Requirements**: Post-MVP requirements

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Post-MVP API Documentation


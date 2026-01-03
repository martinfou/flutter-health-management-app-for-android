# Mock API Server for Health Management App

Simple Node.js/Express mock server for testing authentication endpoints during development.

## Features

- ✅ User registration
- ✅ User login
- ✅ JWT token generation (access + refresh tokens)
- ✅ Token refresh
- ✅ User profile management
- ✅ Password reset (mock)
- ✅ Account deletion
- ✅ CORS enabled for Flutter app

## Prerequisites

- Node.js (v14 or higher)
- npm or yarn

## Installation

```bash
cd mock-server
npm install
```

## Running the Server

### Development Mode (with auto-reload)

```bash
npm run dev
```

### Production Mode

```bash
npm start
```

The server will start on `http://localhost:3000`

## API Endpoints

### Authentication

- **POST** `/api/auth/register` - Register new user
- **POST** `/api/auth/login` - Login user
- **POST** `/api/auth/refresh` - Refresh access token
- **POST** `/api/auth/logout` - Logout user

### User Management

- **GET** `/api/user/profile` - Get user profile (requires auth)
- **PUT** `/api/user/profile` - Update user profile (requires auth)
- **DELETE** `/api/user/account` - Delete user account (requires auth)

### Password Reset

- **POST** `/api/auth/password-reset/request` - Request password reset
- **POST** `/api/auth/password-reset/verify` - Verify and reset password

### Health Check

- **GET** `/health` - Server health check

## Example Requests

### Register User

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@#",
    "name": "Test User"
  }'
```

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@#"
  }'
```

### Get Profile

```bash
curl -X GET http://localhost:3000/api/user/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Configuration

### JWT Settings

Edit `server.js` to change:
- `JWT_SECRET` - Secret key for signing tokens
- `JWT_ACCESS_TOKEN_EXPIRY` - Access token expiration (default: 24h)
- `JWT_REFRESH_TOKEN_EXPIRY` - Refresh token expiration (default: 30d)

### Port

Change `PORT` in `server.js` (default: 3000)

## Notes

- **In-memory storage**: Users are stored in memory and will be lost when server restarts
- **Password reset**: Mock implementation - doesn't actually send emails
- **Token validation**: Basic JWT validation - tokens are signed but not persisted
- **CORS**: Enabled for all origins (configure for production)

## Integration with Flutter App

Update the base URL in `app/lib/core/network/authentication_service.dart`:

```dart
static const String _baseUrl = 'http://localhost:3000/api';
```

For Android emulator, use:
```dart
static const String _baseUrl = 'http://10.0.2.2:3000/api';
```

For iOS simulator, use:
```dart
static const String _baseUrl = 'http://localhost:3000/api';
```

## Troubleshooting

### Port Already in Use

If port 3000 is already in use, change the `PORT` constant in `server.js`.

### CORS Issues

If you encounter CORS errors, ensure the `cors` middleware is properly configured in `server.js`.

### Token Validation Errors

Make sure the `JWT_SECRET` in the mock server matches what you expect (though for mock server, this is less critical).

## Production Considerations

⚠️ **This is a mock server for development only!**

For production:
- Use a real database (MySQL/PostgreSQL)
- Implement proper password reset with email service
- Add rate limiting
- Use environment variables for secrets
- Implement proper error logging
- Add request validation middleware
- Use HTTPS
- Implement token blacklisting for logout





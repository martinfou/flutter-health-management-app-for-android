# Backend Architecture Report: Google OAuth Configuration Issue

## Executive Summary

The Health Management App has a complex multi-tier architecture with three distinct applications, each handling authentication differently. The reported `redirect_uri_mismatch` error occurs because the web application (web-app) uses Google Identity Services with an improperly configured OAuth client, while the Laravel backend has its own separate Google OAuth implementation.

## Current Architecture Overview

### Application Tiers

1. **Flutter Mobile Application**
   - **Purpose**: Native Android health tracking app
   - **Authentication**: JWT tokens via Laravel API
   - **API Endpoint**: `https://healthapp.compica.com/api/v1/*`

2. **Laravel Backend (laravel-app)**
   - **Location**: `/backend/laravel-app/`
   - **Dual Authentication Systems**:
     - **API Routes** (`/api/v1/*`): JWT-based authentication for Flutter app
     - **Web Routes** (`/*`): Session-based authentication with Google OAuth for web dashboard
   - **Framework**: Laravel 10.x with custom JWT service
   - **Database**: MySQL with Eloquent ORM

3. **Web Application (web-app)**
   - **Location**: `/backend/web-app/`
   - **Type**: Vanilla HTML/CSS/JavaScript single-page application
   - **Authentication**: Google Identity Services (direct OAuth) + Laravel API
   - **Purpose**: Web-based dashboard interface

## Authentication Flow Analysis

### Flutter App Authentication Flow
```
Flutter App → Laravel API (/api/v1/auth/login) → JWT Token → API Access
```

### Web-App Authentication Flow (PROBLEMATIC)
```
Web-App → Google Identity Services → Laravel API (/api/v1/auth/verify-google) → JWT Token
```

### Laravel Web Dashboard Authentication Flow (UNUSED)
```
Browser → Laravel Web Routes (/auth/google) → Google OAuth → Session → Dashboard
```

## Root Cause: OAuth Configuration Mismatch

### Current Web-App Google OAuth Setup

**File**: `backend/web-app/app.js` (lines 37-38)
```javascript
google.accounts.id.initialize({
    client_id: '741266813874-275q1r6aug39onitf95lepsh02msg2s7.apps.googleusercontent.com',
    callback: handleGoogleSignIn
});
```

**Issue**: This client ID is configured for Android/mobile use, not web applications. The `redirect_uri_mismatch` error occurs because:

1. The Google Cloud Console OAuth client is not configured with `https://healthapp.compica.com` as an authorized redirect URI
2. The client ID appears to be for Android development rather than web application use
3. No proper OAuth redirect flow is implemented (using Identity Services instead)

### Laravel Backend OAuth Configuration

**File**: `backend/laravel-app/config/services.php`
```php
'google' => [
    'client_id' => env('GOOGLE_CLIENT_ID'),
    'client_secret' => env('GOOGLE_CLIENT_SECRET'),
    'redirect' => env('GOOGLE_REDIRECT_URI'),
],
```

**File**: `backend/laravel-app/routes/web.php`
```php
Route::get('/auth/google', [GoogleAuthController::class, 'redirectToGoogle']);
Route::get('/auth/google/callback', [GoogleAuthController::class, 'handleGoogleCallback']);
```

**Status**: Laravel's Google OAuth is properly configured but **unused** by any application.

## Architecture Problems Identified

### 1. Redundant Authentication Systems
- **Issue**: Three different authentication implementations exist simultaneously
- **Impact**: Confusion, maintenance overhead, security risks
- **Recommendation**: Consolidate to single authentication system

### 2. Misconfigured Web Application
- **Issue**: web-app uses Google Identity Services incorrectly
- **Impact**: OAuth failures, poor user experience
- **Recommendation**: Either fix OAuth config or remove web-app entirely

### 3. Unused Laravel Web Routes
- **Issue**: Laravel has complete web authentication system that's not being used
- **Impact**: Dead code, potential security surface
- **Recommendation**: Remove unused web routes or implement proper web dashboard

## Recommended Solutions

### Option 1: Fix Web-App OAuth (Minimal Changes)
1. Create new Google OAuth client ID for web applications
2. Configure authorized redirect URIs for `https://healthapp.compica.com`
3. Update client ID in `web-app/app.js`
4. Test OAuth flow

### Option 2: Use Laravel Web Authentication (Recommended)
1. Remove web-app entirely
2. Implement web dashboard using Laravel Blade templates
3. Use Laravel's existing Google OAuth routes (`/auth/google`)
4. Single authentication system for all web access

### Option 3: Consolidate to API-Only (Most Clean)
1. Remove web-app and Laravel web routes
2. Keep only JWT API authentication
3. Create separate web frontend (React/Vue) that uses API
4. Single authentication system

## Immediate Fix for Current Issue

To resolve the `redirect_uri_mismatch` error:

1. **Create New Google OAuth Web Client**:
   - Go to Google Cloud Console → APIs & Services → Credentials
   - Create new OAuth 2.0 Client ID for "Web application"
   - Add authorized redirect URIs: `https://healthapp.compica.com`

2. **Update Web-App Configuration**:
   - Replace client ID in `backend/web-app/app.js`
   - Test authentication flow

## Security Considerations

- **Multiple Client Secrets**: Currently 3+ different Google OAuth clients exist
- **Token Storage**: Web-app stores JWT tokens in localStorage (vulnerable to XSS)
- **Session Management**: Laravel web routes use secure sessions but are unused
- **CORS Configuration**: API allows cross-origin requests from web-app

## Migration Recommendations

1. **Phase 1**: Fix immediate OAuth issue
2. **Phase 2**: Choose single authentication architecture
3. **Phase 3**: Remove redundant code and consolidate systems
4. **Phase 4**: Implement proper security measures

## Files Requiring Attention

- `backend/web-app/app.js` - OAuth client ID configuration
- `backend/laravel-app/config/services.php` - OAuth credentials
- `backend/laravel-app/routes/web.php` - Unused web routes
- `backend/laravel-app/app/Http/Controllers/Auth/GoogleAuthController.php` - Unused OAuth controller
- Google Cloud Console - OAuth client configurations

## Conclusion

The `redirect_uri_mismatch` error is a symptom of architectural confusion rather than a simple configuration issue. The application currently maintains three separate authentication systems that conflict with each other. Immediate fix is possible, but long-term architectural consolidation is recommended for maintainability and security.</content>
<parameter name="filePath">/Volumes/T7/src/flutter-health-management-app-for-android/project-management/docs/backend-architecture-report.md
# Feature Request: FR-009 - User Authentication

**Status**: ⏳ In Progress (Partial - Email/Password Only)
**Priority**: 🟠 High
**Story Points**: 13
**Created**: 2025-01-03
**Updated**: 2026-01-03
**Assigned Sprint**: [Sprint 14](../sprints/sprint-14-user-authentication.md)

**Implementation Status**:
- ✅ Email/password authentication service infrastructure exists
- ✅ JWT token management (access + refresh tokens) implemented
- ✅ Token storage using flutter_secure_storage
- ✅ Login page UI exists
- ✅ Authentication service communicates with backend API
- ⚠️ Authentication is DISABLED BY DEFAULT (AuthConfig.isEnabledByDefault = false)
- ❌ Google OAuth NOT implemented (required by specification)
- ❌ Backend server NOT deployed (points to local network IP)

## Description

Implement user account system with Google OAuth authentication, allowing users to sign in with their Google account and securely access their data. This feature is required for cloud sync and multi-device support, enabling secure access to user data across devices. Google OAuth provides a seamless authentication experience while leveraging Google's security infrastructure.

## User Story

As a user, I want to sign in to the app using my Google account, so that my health data is protected and accessible across multiple devices without managing separate credentials.

## Acceptance Criteria

- [ ] Google OAuth sign-in flow integration
- [ ] User authentication via Google OAuth
- [ ] JWT token-based authentication (backend issues JWT after OAuth verification)
- [ ] JWT token refresh mechanism
- [ ] User profile management (view/edit profile)
- [ ] Secure token storage on device (flutter_secure_storage)
- [ ] Logout functionality (clear tokens and OAuth session)
- [ ] Account deletion (GDPR compliance)
- [ ] Error handling for OAuth failures
- [ ] Error handling for network failures during auth
- [ ] Handle case when user denies OAuth permissions
- [ ] Handle case when Google account is not available
- [ ] Display user's Google profile information (name, email, avatar)

## Business Value

User authentication is essential for cloud sync and multi-device support, enabling secure access to user data. This feature protects user privacy and data security while enabling future features that require user identity. It's a foundational feature for scaling the app beyond local-only usage.

## Technical Requirements

### Authentication Flow
- Sign In: Google OAuth → Verify token with backend → Backend issues JWT token
- Token Refresh: Refresh token → New access token
- Logout: Clear tokens and OAuth session locally and on backend

### Security Requirements
- OAuth Token Verification: Backend must verify Google OAuth ID token
- JWT Token: Signed with secret key, expires after 24 hours
- Refresh Token: Longer expiration (30 days), stored securely
- HTTPS: All API calls must use HTTPS
- OAuth Scopes: Request appropriate Google OAuth scopes (email, profile)

### Backend Implementation
- OAuth verification endpoint (verify Google ID token using Google API Client Library)
- User creation/lookup based on Google account
- JWT token generation and validation (using existing firebase/php-jwt library)
- Authentication endpoints (verify OAuth, refresh, logout)
- User management endpoints (profile, update, delete)
- Google OAuth client configuration
- **Note**: Using Google Sign-In directly (not Firebase Auth) - backend verifies Google ID tokens directly

### Flutter Implementation
- Google Sign-In integration (`google_sign_in` package - direct Google OAuth, not Firebase)
- Authentication service layer
- Secure storage for tokens (flutter_secure_storage)
- Google OAuth sign-in UI flow
- Authentication state management (Riverpod)
- Protected routes (require authentication)
- Token refresh interceptor
- Handle OAuth callbacks and errors
- **Note**: Using `google_sign_in` package directly (not `firebase_auth`) - sends Google ID token to custom backend

## Reference Documents

- `../../phase-3-integration/api-documentation.md` - Authentication endpoints specification
- `../../phase-3-integration/sync-architecture-design.md` - Auth implementation details
- `../../../app/docs/post-mvp-features.md` - Post-MVP features overview

## Technical References

- API Spec: `../../phase-3-integration/api-documentation.md`
- Sync Architecture: `../../phase-3-integration/sync-architecture-design.md`
- Authentication Service: Create `AuthenticationService` in `lib/core/network/`
- Secure Storage: Use `flutter_secure_storage` package
- Google Sign-In: Use `google_sign_in` package (Flutter) - **direct Google OAuth, not Firebase Auth**
- Backend: Use Google API Client Library for PHP (`google/apiclient`) to verify ID tokens
- State Management: Create `authProvider` in `lib/core/providers/`
- Backlog Management Process: Authentication standard specifies Google OAuth
- Decision Analysis: See `FR-009-oauth-decision-analysis.md` for Google Sign-In vs Firebase Auth comparison

## Dependencies

- Backend infrastructure must be set up on DreamHost
- Database schema for users table must be created
- SSL certificate must be configured
- Google Cloud Platform project must be created
- Google OAuth 2.0 credentials must be configured (Client ID for Android)
- OAuth consent screen must be configured in Google Cloud Console

## Notes

- This feature must be completed before FR-008 (Cloud Sync)
- Google OAuth is the standard authentication method (per backlog management process)
- **Using Google Sign-In directly (not Firebase Auth)** - see decision analysis document
- No password management required - Google handles authentication
- Backend receives Google ID token and verifies it directly using Google API Client Library
- After verification, backend issues JWT token using existing firebase/php-jwt library
- User profile data (name, email, avatar) can be retrieved from Google account
- GDPR compliance: Users must be able to delete their accounts and all associated data
- MVP currently has no authentication - this is a post-MVP Phase 1 priority
- Android OAuth configuration requires SHA-1 fingerprint for Google Cloud Console
- Flutter package: `google_sign_in` (not `firebase_auth`)
- Backend library: `google/apiclient` for PHP (via Composer)

## History

- 2025-01-03 - Created
- 2025-01-27 - Updated to use Google OAuth authentication (standard authentication method)
- 2026-01-03 - Status review:
  - Email/password authentication infrastructure implemented but disabled by default
  - AuthenticationService exists at lib/core/network/authentication_service.dart
  - AuthConfig allows toggling auth at runtime (lib/core/constants/auth_config.dart)
  - Login page exists at lib/core/pages/login_page.dart
  - Google OAuth NOT yet implemented - still required
  - Backend server not deployed (configured for local network testing only)


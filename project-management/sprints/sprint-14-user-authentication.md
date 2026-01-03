# Sprint 14: User Authentication

**Sprint Goal**: Implement user account system using Google OAuth and backend-issued JWT authentication, enabling users to sign in with Google, log in securely, and manage their profiles. This foundational feature enables cloud sync and multi-device support while leveraging Google's security infrastructure.

**Duration**: 2025-12-31 - 2026-01-14 (2 weeks)  
**Team Velocity**: Target 13 points  
**Sprint Planning Date**: 2025-12-31  
**Sprint Review Date**: 2026-01-14  
**Sprint Retrospective Date**: 2026-01-15

---

## ⚠️ IMPORTANT: Documentation Update Reminder

**After completion of each STORY**, the LLM must update:
1. ✅ **Story status** in this document (⭕ Not Started → ⏳ In Progress → ✅ Complete)
2. ✅ **Progress Summary** section at the bottom of this document
3. ✅ **Acceptance Criteria** checkboxes for the completed story
4. ✅ **Related backlog items** (FR-009) with implementation status
5. ✅ **Sprint Summary** section with completed points
6. ✅ **Demo Checklist** items that are verified

**After completion of each TASK**, update:
- Task status in the task table (⭕ → ⏳ → ✅)
- Implementation notes section
- Any related technical references

---

## Related Feature Requests and Bug Fixes

This sprint implements the following items from the product backlog:

### Feature Requests
- [FR-009: User Authentication](../backlog/feature-requests/FR-009-user-authentication.md) - 13 points

**Total**: 13 points

## Sprint Overview

**Focus Areas**:
- User registration and login flows via Google OAuth
- JWT token-based authentication system (JWTs issued by backend after Google OAuth verification)
- All authentication endpoints require backend to verify Google ID token using Google API Client (PHP/Node/etc.) and issue short-lived JWT on success
- End-to-end sign-in UI and backend flow follow Google OAuth platform best practices
- Secure token storage on device
- User profile management
- Password reset functionality
- Protected routes and authentication state management

**Key Deliverables**:
- Google Sign-In UI & authentication service layer with JWT support
- OAuth flow with Google Sign-In (google_sign_in package)
- Backend verification of Google ID token (php-google-auth-library)
- App issues API calls with backend-provided JWTs after Google OAuth login
- Login and registration UI screens
- Secure token storage implementation
- User profile management UI
- Password reset flow
- Authentication state provider (Riverpod)
- Protected route navigation

**Dependencies**:
- Backend infrastructure must be set up on DreamHost (may need to be done in parallel)
- Google OAuth 2.0 credentials & consent screen must be set up in Google Cloud Console
- Database schema for users table must be created
- SSL certificate must be configured
- Email service must be configured for password reset
- `flutter_secure_storage` package must be added to dependencies
- OAuth token verification (Google API PHP client) and JWT issuing on backend

**Risks & Blockers**:
- Backend infrastructure setup may be a blocker if not ready
- Email service configuration required for password reset
- JWT token refresh mechanism complexity
- Secure storage implementation on Android
- Protected routes navigation architecture

**Documentation Workflow**:
- ⚠️ **IMPORTANT**: After completion of each **story**, the LLM must update this sprint document (`sprint-14-user-authentication.md`) with:
  - Story status updates (⭕ Not Started → ⏳ In Progress → ✅ Complete)
  - Progress summary updates
  - Acceptance criteria completion status
  - Any blockers or issues discovered
- After completion of each **task**, the LLM must update this sprint document with task status updates
- Related documents referenced in tasks (e.g., FR-009) should also be updated to reflect implementation details, progress, and any deviations from the original specification
- Documentation updates should include:
  - Task status changes (⭕ Not Started → ⏳ In Progress → ✅ Complete)
  - Implementation notes or decisions made during development
  - Any technical changes or improvements discovered during implementation
  - Links to related code changes or new files created
  - Test coverage information

## User Stories

### Story 14.1: User Authentication System - 13 Points

**User Story**: As a user, I want to log in with my Google account through a seamless Google OAuth sign-in flow, so that my health data is protected, secure, and accessible across devices—without needing a separate password for the app.

**Acceptance Criteria**:

#### Registration and Login (Via Google OAuth)
- [ ] Users can sign in with Google OAuth (no password management required)
- [ ] OAuth flow works for new and existing Google users
- [ ] Backend receives and verifies Google ID token, issues app JWT
- [ ] Error handling for OAuth failures (including user cancellation, permissions denial)
- [ ] Remember me option (Google session and backend refresh token)
- [ ] Input validation for Google Account scenarios (network, Google Play Services issues)

#### Authentication System
- [ ] JWT token-based authentication implemented
- [ ] JWT access token expires after 24 hours
- [ ] JWT refresh token expires after 30 days
- [ ] Token refresh mechanism implemented
- [ ] Secure token storage on device using `flutter_secure_storage`
- [ ] Logout functionality clears tokens and resets auth state

#### User Profile Management
- [ ] Users can view their profile information
- [ ] Users can edit their profile (email, name, etc.)
- [ ] Profile data is fetched from backend API
- [ ] Profile updates are saved to backend

#### Password Reset
- [ ] Users can request password reset via email
- [ ] Password reset email contains secure token
- [ ] Users can verify reset token and set new password
- [ ] Password reset flow is secure and user-friendly

#### Account Management
- [ ] Users can delete their account (GDPR compliance)
- [ ] Account deletion removes all user data from backend
- [ ] Account deletion confirmation dialog

#### UI/UX Requirements
- [ ] Login screen with email and password fields
- [ ] Registration screen with validation feedback
- [ ] Password reset request screen
- [ ] Password reset verification screen
- [ ] User profile screen
- [ ] Loading states during authentication operations
- [ ] Error messages displayed clearly to users
- [ ] Success confirmations for completed actions

#### Navigation and Protected Routes
- [ ] Protected routes require authentication
- [ ] Unauthenticated users are redirected to login
- [ ] Authenticated users can access all app features
- [ ] Navigation state persists after app restart (if "Remember me" enabled)

**Reference Documents**:
- `../backlog/feature-requests/FR-009-user-authentication.md` - Feature specification
- `../../phase-3-integration/api-documentation.md` - Authentication endpoints specification
- `../../phase-3-integration/sync-architecture-design.md` - Auth implementation details
- `../../../app/docs/post-mvp-features.md` - Post-MVP features overview

**Technical References**:
- API Spec: `../../phase-3-integration/api-documentation.md`
- Sync Architecture: `../../phase-3-integration/sync-architecture-design.md`
- Authentication Service: Create `AuthenticationService` in `lib/core/network/`
- Secure Storage: Use `flutter_secure_storage` package
- State Management: Create `authProvider` in `lib/core/providers/`
- Backend: DreamHost PHP/MySQL implementation (may need to be created)

**Story Points**: 13

**Priority**: 🟠 High

**Status**: ⏳ In Progress

**Implementation Notes**:
- This is a foundational feature for cloud sync (FR-008)
- Google OAuth is the mandatory authentication standard (see backlog-management-process.md and FR-009)
- Backend infrastructure setup may need to be done in parallel or before this sprint
- Google Cloud project and OAuth credentials must be correctly configured and referenced
- Password hashing required only for non-OAuth flows (deferred/post-MVP)
- JWT tokens should be signed with a secret key
- Consider implementing other social login types in future (out of scope for this sprint)
- GDPR compliance requires account deletion functionality
- Secure storage implementation must work correctly on Android API 24-34

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-500 | Add flutter_secure_storage dependency to pubspec.yaml | `pubspec.yaml` | FR-009 - Dependencies | ✅ | 1 | Dev1 |
| T-501 | Create AuthenticationService class | `AuthenticationService` | FR-009 - Flutter Implementation | ✅ | 5 | Dev2 |
| T-502 | Implement register method in AuthenticationService | `AuthenticationService.register()` | FR-009 - Registration Flow | ✅ | 3 | Dev2 |
| T-503 | Implement login method in AuthenticationService | `AuthenticationService.login()` | FR-009 - Login Flow | ✅ | 3 | Dev2 |
| T-504 | Implement token refresh method in AuthenticationService | `AuthenticationService.refreshToken()` | FR-009 - Token Refresh | ✅ | 3 | Dev2 |
| T-505 | Implement logout method in AuthenticationService | `AuthenticationService.logout()` | FR-009 - Logout Flow | ✅ | 2 | Dev2 |
| T-506 | Create secure token storage utility | `TokenStorage` class | FR-009 - Secure Storage | ✅ | 3 | Dev2 |
| T-507 | Create authentication state provider (Riverpod) | `authProvider`, `authStateProvider` | FR-009 - State Management | ✅ | 3 | Dev3 |
| T-508 | Create login page UI | `LoginPage` widget | FR-009 - UI/UX | ✅ | 5 | Dev3 |
| T-509 | Create registration page UI | `RegistrationPage` widget | FR-009 - UI/UX | ✅ | 5 | Dev3 |
| T-510 | Implement email and password validation | `EmailValidator`, `PasswordValidator` | FR-009 - Validation | ✅ | 3 | Dev2 |
| T-511 | Create user profile page UI | `UserProfilePage` widget | FR-009 - Profile Management | ✅ | 5 | Dev3 |
| T-512 | Implement profile update functionality | `UserProfileService.updateProfile()` | FR-009 - Profile Management | ✅ | 3 | Dev2 |
| T-513 | Create password reset request page UI | `PasswordResetRequestPage` widget | FR-009 - Password Reset | ✅ | 3 | Dev3 |
| T-514 | Create password reset verification page UI | `PasswordResetVerificationPage` widget | FR-009 - Password Reset | ✅ | 3 | Dev3 |
| T-515 | Implement password reset request API call | `AuthenticationService.requestPasswordReset()` | FR-009 - Password Reset | ✅ | 2 | Dev2 |
| T-516 | Implement password reset verification API call | `AuthenticationService.verifyPasswordReset()` | FR-009 - Password Reset | ✅ | 3 | Dev2 |
| T-517 | Implement account deletion functionality | `AuthenticationService.deleteAccount()` | FR-009 - Account Management | ✅ | 3 | Dev2 |
| T-518 | Create protected route wrapper | `ProtectedRoute` widget | FR-009 - Navigation | ✅ | 3 | Dev3 |
| T-519 | Update app navigation to use protected routes | `main.dart`, route configuration | FR-009 - Navigation | ✅ | 3 | Dev3 |
| T-520 | Implement token refresh interceptor | `TokenRefreshInterceptor` | FR-009 - Token Refresh | ⭕ | 3 | Dev2 |
| T-521 | Add error handling for network failures | `AuthenticationService` error handling | FR-009 - Error Handling | ⭕ | 2 | Dev2 |
| T-522 | Write unit tests for AuthenticationService | `AuthenticationService` tests | FR-009 - Testing | ⭕ | 5 | Dev2 |
| T-523 | Write unit tests for token storage | `TokenStorage` tests | FR-009 - Testing | ⭕ | 3 | Dev2 |
| T-524 | Write widget tests for login page | `LoginPage` tests | FR-009 - Testing | ⭕ | 3 | Dev3 |
| T-525 | Write widget tests for registration page | `RegistrationPage` tests | FR-009 - Testing | ⭕ | 3 | Dev3 |
| T-526 | Write integration tests for authentication flow | Integration tests | FR-009 - Testing | ⭕ | 5 | Dev2 |
| T-527 | Manual testing: Complete registration and login flow | Manual testing | FR-009 - Testing | ⭕ | 2 | QA |
| T-528 | Manual testing: Test password reset flow | Manual testing | FR-009 - Testing | ⭕ | 2 | QA |
| T-529 | Manual testing: Test token refresh mechanism | Manual testing | FR-009 - Testing | ⭕ | 2 | QA |
| T-530 | Manual testing: Test account deletion | Manual testing | FR-009 - Testing | ⭕ | 2 | QA |

**Total Task Points**: 88 (includes testing)

---

## Sprint Summary

**Total Story Points**: 13
- Story 14.1: User Authentication System - 13 points

**Total Task Points**: 88
- Story 14.1 Tasks: 88 points

**Estimated Velocity**: 13 points (based on story points)

**Sprint Burndown**:
- Day 1: [X] points completed
- Day 2: [X] points completed
- ...
- Day 14: [X] points completed

**Progress Summary**:

### Story 14.1: User Authentication System
- **Status**: ⏳ In Progress
- **Progress**: 22/30 tasks completed (73%)
- **Key Decisions Made**: 
  - Backend infrastructure: Using placeholder URL (needs to be configured)
  - JWT token expiration: 24h access token, 30d refresh token
  - Secure storage: Using flutter_secure_storage with Android encrypted shared preferences
  - Navigation: MainNavigationPage wrapped with ProtectedRoute
  - Startup: App checks authentication status on startup and shows login if not authenticated
- **Remaining Work**:
  - Write unit tests (T-522, T-523)
  - Write widget tests (T-524, T-525)
  - Write integration tests (T-526)
  - Manual testing (T-527, T-528, T-529, T-530)

**Sprint Review Notes**:
- [Notes from sprint review]

**Sprint Retrospective Notes**:
- [Notes from retrospective]

---

## Demo Checklist

### Story 14.1: User Authentication System
- [ ] Register new user account with email and password
- [ ] Login with registered credentials
- [ ] Login with invalid credentials (error handling)
- [ ] "Remember me" option works (token persists after app restart)
- [ ] View user profile information
- [ ] Edit user profile and save changes
- [ ] Request password reset via email
- [ ] Verify password reset token and set new password
- [ ] Logout functionality clears auth state
- [ ] Protected routes redirect to login when not authenticated
- [ ] Authenticated users can access all app features
- [ ] Token refresh mechanism works automatically
- [ ] Account deletion removes user data (GDPR compliance)
- [ ] Error messages display clearly for network failures
- [ ] Loading states shown during authentication operations

---

## Notes

### Design Decisions

1. **Backend Infrastructure** (Story 14.1):
   - **Decision**: Backend must be set up on DreamHost before or during this sprint
   - **Approach**: May need to create backend endpoints in parallel with Flutter implementation
   - **Alternative**: Use mock backend for initial development, then integrate real backend

2. **JWT Token Strategy** (Story 14.1):
   - **Decision**: Use access token (24h) + refresh token (30d) pattern
   - **Implementation**: Access token for API calls, refresh token for obtaining new access tokens
   - **Storage**: Both tokens stored securely using `flutter_secure_storage`

3. **Password Requirements** (Story 14.1):
   - **Decision**: Minimum 8 characters, uppercase, lowercase, number, special character
   - **Validation**: Client-side validation for UX, server-side validation for security
   - **Feedback**: Real-time validation feedback in registration form

4. **Protected Routes** (Story 14.1):
   - **Decision**: Use route wrapper that checks authentication state
   - **Implementation**: `ProtectedRoute` widget that redirects to login if not authenticated
   - **Navigation**: Maintain navigation state after authentication

5. **Account Deletion** (Story 14.1):
   - **Decision**: GDPR compliance requires account deletion
   - **Implementation**: Delete all user data from backend, clear local tokens
   - **Confirmation**: Show confirmation dialog before deletion

### Implementation Considerations

- Story 14.1 is complex and involves multiple layers (domain, data, presentation, backend)
- Backend infrastructure setup may be a blocker - coordinate with backend team
- Secure storage implementation must be tested on various Android versions (API 24-34)
- Token refresh mechanism needs careful implementation to avoid race conditions
- Password requirements must be clearly communicated to users
- Error handling is critical for good UX during network failures
- Consider implementing biometric authentication in future (out of scope)

### Testing Considerations

- Story 14.1 requires comprehensive testing (unit, widget, integration)
- Test secure storage on different Android versions
- Test token refresh mechanism with expired tokens
- Test network failure scenarios
- Test password reset flow end-to-end
- Test account deletion and data removal
- Manual testing on physical devices for authentication flows

### Backend Dependencies

- **Database Schema**: Users table must be created with fields: id, email, password_hash, name, created_at, updated_at
- **API Endpoints**: 
  - POST /api/auth/register
  - POST /api/auth/login
  - POST /api/auth/refresh
  - POST /api/auth/logout
  - GET /api/user/profile
  - PUT /api/user/profile
  - POST /api/auth/password-reset/request
  - POST /api/auth/password-reset/verify
  - DELETE /api/user/account
- **JWT Configuration**: Secret key, token expiration times
- **Email Service**: SMTP configuration for password reset emails
- **SSL Certificate**: HTTPS must be configured

---

**Last Updated**: 2025-12-31  
**Version**: 1.0  
**Status**: Sprint Planning Complete


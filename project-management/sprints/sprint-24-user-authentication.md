# Sprint 24: User Authentication & Bug Fixes

**Sprint Goal**: Implement user authentication system with Google OAuth integration and JWT tokens, enabling secure user accounts and login flows. Also fix critical bug blocking food saving. This sprint unblocks cloud sync and multi-device support (FR-008).

**Duration**: 2 weeks (Sprint 24)
**Team Velocity**: Target 16 points (13 FR-009 + 3 BF-002)
**Sprint Planning Date**: 2026-01-17
**Sprint Review Date**: TBD
**Sprint Retrospective Date**: TBD

---

## Related Feature Requests and Bug Fixes

This sprint implements the following items from the product backlog:

### Feature Requests
- [FR-009: User Authentication](../backlog/features/FR-009-user-authentication.md) - 13 points

### Bug Fixes
- [BF-002: Food Save Blocked by 40g Carb Limit](../backlog/bug-fixes/BF-002-food-save-blocked-by-carb-limit.md) - 3 points

**Total**: 16 points

---

## Sprint Overview

**Focus Areas**:
- User registration and login flows via Google OAuth
- JWT token-based authentication system
- Backend verification of Google ID tokens
- Secure token storage on device
- User profile management
- Password reset functionality
- Protected routes and authentication state management
- Fix food save validation bug blocking carb limit edge cases

**Key Deliverables**:
- Google Sign-In UI with JWT support
- Complete OAuth flow (google_sign_in package)
- Backend Google token verification
- Secure token storage (flutter_secure_storage)
- User profile management UI
- Password reset flow
- Protected route navigation
- Fixed food save carb limit validation

**Dependencies**:
- ✅ Backend infrastructure deployed (FR-020 complete)
- ✅ JWT authentication endpoints ready
- Google OAuth credentials configured
- SSL certificate configured
- Email service configured for password reset

**Risks & Blockers**:
- Email service configuration for password reset
- JWT token refresh mechanism complexity
- Secure storage on various Android versions
- Protected routes navigation architecture

---

## User Stories

### Story 24.1: User Authentication System - 13 Points

**User Story**: As a user, I want to log in with my Google account through a seamless OAuth sign-in flow, so that my health data is protected and accessible across devices.

**Acceptance Criteria**:
- [ ] Users can sign in with Google OAuth
- [ ] Backend verifies Google ID token and issues JWT
- [ ] JWT tokens expire correctly (24h access, 30d refresh)
- [ ] Tokens stored securely using flutter_secure_storage
- [ ] User profiles can be viewed and edited
- [ ] Password reset works via email
- [ ] Account deletion removes all user data (GDPR)
- [ ] Protected routes redirect unauthenticated users
- [ ] Token refresh happens automatically
- [ ] Error handling for auth failures

**Story Points**: 13

**Priority**: 🟠 High

**Status**: ⭕ Not Started

---

### Story 24.2: Fix Food Save Validation Bug - 3 Points

**User Story**: As a user, I want to save food entries even when macros are at or near the carb limit, so that I can log all meals without artificial restrictions.

**Acceptance Criteria**:
- [ ] Food entries save successfully at exactly 40g carbs
- [ ] Food entries save successfully above 40g carbs
- [ ] Error message only shows for invalid data, not limit edge cases
- [ ] Existing food entries unaffected
- [ ] Validation still catches truly invalid data

**Story Points**: 3

**Priority**: 🟠 High

**Status**: ⭕ Not Started

**Reference**: [BF-002: Food Save Blocked by 40g Carb Limit](../backlog/bug-fixes/BF-002-food-save-blocked-by-carb-limit.md)

---

## Tasks

| Task ID | Task Description | Status | Points |
|---------|------------------|--------|--------|
| T-2401 | Add flutter_secure_storage to pubspec.yaml | ⭕ | 1 |
| T-2402 | Create AuthenticationService class | ⭕ | 5 |
| T-2403 | Implement login via Google OAuth | ⭕ | 3 |
| T-2404 | Implement token refresh mechanism | ⭕ | 3 |
| T-2405 | Implement logout functionality | ⭕ | 2 |
| T-2406 | Create secure token storage utility | ⭕ | 3 |
| T-2407 | Create authentication state provider (Riverpod) | ⭕ | 3 |
| T-2408 | Create login page UI | ⭕ | 5 |
| T-2409 | Create user profile page UI | ⭕ | 5 |
| T-2410 | Implement profile update functionality | ⭕ | 3 |
| T-2411 | Create password reset UI flow | ⭕ | 3 |
| T-2412 | Implement protected routes wrapper | ⭕ | 3 |
| T-2413 | Fix food save carb limit validation (BF-002) | ⭕ | 3 |
| T-2414 | Unit tests for AuthenticationService | ⭕ | 5 |
| T-2415 | Widget tests for login page | ⭕ | 3 |
| T-2416 | Manual testing: Complete auth flow | ⭕ | 2 |
| T-2417 | Manual testing: Token refresh | ⭕ | 2 |

**Total Task Points**: 54

---

## Demo Checklist

- [ ] User can register with Google OAuth
- [ ] User can login with registered Google account
- [ ] Login credentials persist after app restart
- [ ] User profile displays correctly
- [ ] User can edit and save profile changes
- [ ] Token refresh works automatically
- [ ] Logout clears all authentication state
- [ ] Protected routes redirect to login when needed
- [ ] Error messages display clearly
- [ ] Food entries save at carb limit edge cases
- [ ] Password reset flow works end-to-end
- [ ] Account deletion removes user data

---

## Implementation Notes

**Current Status**: Sprint Planning Complete

**Architecture**:
- Slim Framework backend ✅ (from Sprint 23)
- MySQL database ✅
- JWT authentication ✅
- Google OAuth integration ⭕

**Next Steps After Sprint 24**:
1. Complete FR-009 (User Authentication)
2. Start Sprint 25-26: FR-008 (Cloud Sync & Multi-Device)
3. Parallel: Sprint 26 FR-019 (Open Food Facts Integration)

---

**Last Updated**: 2026-01-17
**Status**: Sprint 24 Planning Complete
**Blocked By**: None - Ready to start
**Unblocks**: FR-008 (Cloud Sync), Sprint 25-26

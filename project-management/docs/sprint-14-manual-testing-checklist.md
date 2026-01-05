# Sprint 14 Manual Testing Checklist

This checklist is used to verify all authentication features work correctly after implementation.

## Prerequisites

- [ ] Backend deployed to production (https://health.martinfourier.com/api)
- [ ] Gmail App Password configured in `.env`
- [ ] Google OAuth Client ID configured in `.env`
- [ ] JWT_SECRET configured with strong value
- [ ] Email service working (can send password reset emails)
- [ ] App updated with production backend URL

## Google OAuth Testing

### Registration (New Google User)

- [ ] User can tap "Sign in with Google" button
- [ ] Google Sign-In UI appears correctly
- [ ] User selects Google account from list
- [ ] User grants permissions (email, profile)
- [ ] Backend receives Google ID token
- [ ] Backend verifies token with Google API
- [ ] New user created in `users` table with `google_id`
- [ ] JWT tokens returned (access + refresh)
- [ ] User is redirected to home page
- [ ] User's name and email pre-filled in user profile

### Login (Returning Google User)

- [ ] User can tap "Sign in with Google" button
- [ ] Google Sign-In UI appears correctly
- [ ] User selects previously used Google account
- [ ] Backend receives Google ID token
- [ ] Backend finds user by `google_id`
- [ ] JWT tokens returned (access + refresh)
- [ ] User is redirected to home page
- [ ] Last login timestamp updated in `users` table

## Email/Password Authentication Testing

### Registration

- [ ] User can fill registration form
- [ ] Email validation works (correct format)
- [ ] Password validation shows strength indicator (weak/medium/strong)
- [ ] Password requirements displayed (8+ chars, uppercase, lowercase, number, special)
- [ ] Backend receives registration request
- [ ] Backend validates email uniqueness
- [ ] Backend hashes password securely
- [ ] User created in `users` table
- [ ] JWT tokens returned and stored
- [ ] User is redirected to home page

### Login

- [ ] User can enter email and password
- [ ] Password field has toggle to show/hide
- [ ] "Remember me" checkbox works
- [ ] Backend receives login request
- [ ] Backend verifies credentials
- [ ] JWT tokens returned and stored
- [ ] User is redirected to home page
- [ ] Invalid credentials show error message
- [ ] Network errors show user-friendly messages

### Token Refresh

- [ ] Access token expires after 24 hours
- [ ] API call fails with 401 response
- [ ] App automatically calls refresh endpoint
- [ ] New access token received
- [ ] Original API call retried with new token
- [ ] User experience is seamless (no manual re-login required)

### Password Reset Request

- [ ] "Forgot Password?" link works on login page
- [ ] User navigates to password reset request page
- [ ] User enters email address
- [ ] Backend validates email format
- [ ] Backend generates password reset token
- [ ] Backend sends email to user's Gmail
- [ ] Success message shown ("If email exists, link sent")

### Password Reset Verification

- [ ] User receives email with reset link
- [ ] User clicks link (or opens in app)
- [ ] Backend validates token format
- [ ] Backend verifies token not expired
- [ ] User can enter new password
- [ ] Password validation works (same requirements as registration)
- [ ] Backend updates password in `users` table
- [ ] Backend deletes used password reset token
- [ ] Success message shown ("Password reset successfully")
- [ ] User can login with new password

### Logout

- [ ] User taps logout button (in profile page)
- [ ] Backend logout endpoint called
- [ ] Access token deleted on backend (optional)
- [ ] Local tokens cleared from secure storage
- [ ] User redirected to login page
- [ ] User's Google session ended

## Profile Management Testing

### View Profile

- [ ] User can view profile page
- [ ] User's name, email displayed
- [ ] Protected route requires authentication
- [ ] Backend returns user data correctly

### Update Profile

- [ ] User can edit name field
- [ ] User can edit email field
- [ ] Changes persist to backend
- [ ] Updated data shows in profile after save
- [ ] Email change requires re-authentication (if email changed)

## Account Deletion (GDPR)

### Initiate Deletion

- [ ] Delete account button exists in profile page
- [ ] Confirmation dialog appears
- [ ] Warning message explains consequences
- [ ] "All data will be permanently removed" shown

### Confirm Deletion

- [ ] User can confirm deletion
- [ ] Backend `deleteAccount` endpoint called
- [ ] User soft-deleted in `users` table (`deleted_at` set)
- [ ] Cascading delete works (health_metrics, medications, etc. deleted)
- [ ] Local tokens cleared
- [ ] User logged out
- [ ] User redirected to login page

### GDPR Compliance

- [ ] Data removed from all related tables (health_metrics, medications, meals, exercises, meal_plans, sync_status)
- [ ] Data cannot be recovered after deletion
- [ ] Account deletion confirmation email sent
- [ ] Error logged in backend logs
- [ ] Deletion timestamp recorded in `deleted_at` field

## Error Handling Testing

### Network Errors

- [ ] No internet connection shows user-friendly message
- [ ] Connection timeout shows timeout message
- [ ] Server unavailable (5xx) shows appropriate message
- [ ] Server error (5xx) shows server error message
- [ ] Transient errors trigger automatic retry
- [ ] Retry uses exponential backoff (1s, 2s, 4s)

### Authentication Errors

- [ ] Invalid credentials (401) shows "Invalid email or password"
- [ ] Token expired (401) triggers automatic refresh
- [ ] Refresh token expired forces re-login
- [ ] Email already registered shows "Email already registered"
- [ ] Validation errors show specific field issues
- [ ] Google Sign-In cancelled shows appropriate message

### Input Validation

- [ ] Email field validates on blur/submit
- [ ] Password field validates in real-time
- [ ] Name field has character limit (255 chars)
- [ ] All required fields show error message
- [ ] Validation errors appear below fields

## Security Testing

### Token Storage

- [ ] Access token stored using flutter_secure_storage
- [ ] Refresh token stored using flutter_secure_storage
- [ ] Storage uses Android encrypted shared preferences
- [ ] Tokens are accessible only to app
- [ ] Tokens cleared on logout
- [ ] Tokens cleared on account deletion

### SSL/HTTPS

- [ ] All API calls use HTTPS
- [ ] HTTP requests redirect to HTTPS
- [ ] SSL certificate is valid
- [ ] No mixed content warnings in browser console

## Performance Testing

- [ ] Login completes within 3 seconds
- [ ] Registration completes within 3 seconds
- [ ] Token refresh completes within 2 seconds
- [ ] Profile updates complete within 2 seconds
- [ ] Password reset email sent within 5 seconds
- [ ] No UI blocking during API calls

## Cross-Browser Testing

- [ ] Chrome (Desktop)
- [ ] Firefox (Desktop)
- [ ] Safari (iOS - future)
- [ ] Edge (Desktop)
- [ ] Mobile Chrome

## Device Testing

### Android Emulator

- [ ] Google Sign-In works on emulator
- [ ] Email/password authentication works
- [ ] Token refresh works
- [ ] Profile management works

### Physical Android Device

- [ ] Google Play Services installed
- [ ] Google Sign-In works on physical device
- [ ] Biometric authentication (if added in future)
- [ ] Secure storage uses hardware-backed keystore

## Integration Testing

### Full User Flow

1. Install fresh app (or clear data)
2. Create new account with Google OAuth
3. Log health metrics (weight, sleep, etc.)
4. Log meals and exercises
5. Logout
6. Reinstall app
7. Log in again with same Google account
8. Verify all data synced to backend

### Multi-Device Testing

1. Log in on Device A
2. Add health metrics on Device A
3. Install app on Device B
4. Log in with same Google account
5. Verify metrics appear on Device B
6. Logout on Device B
7. Verify data removed from Device B on logout

## Bug Reporting

- [ ] Create bug report for any issues found
- [ ] Include device information
- [ ] Include app version
- [ ] Include reproduction steps
- [ ] Include expected vs actual behavior
- [ ] Test on multiple devices if applicable

---

## Testing Results

**Date**: ___________

**Tester**: ___________

**Overall Status**: PASS / FAIL / PARTIAL PASS

**Critical Issues Found**:
- _____________________________
- _____________________________

**Non-Critical Issues Found**:
- _____________________________
- _____________________________

**Recommendations**:
1. _____________________________
2. _____________________________

**Next Steps**:
1. Fix critical issues before release
2. Address non-critical items in future sprints
3. Document any workarounds

---

**Tested By**: _____________

**Reviewed By**: _____________

**Date**: ____________

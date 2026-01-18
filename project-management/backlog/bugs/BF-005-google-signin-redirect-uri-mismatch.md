# Bug Fix: BF-005 - Google OAuth Login Fails in Laravel Application

**Status**: ✅ Completed
**Priority**: 🟠 High
**Story Points**: 8
**Created**: 2026-01-18
**Updated**: 2026-01-18
**Assigned Sprint**: Backlog

## Description

Google OAuth authentication fails in the Laravel application with a redirect_uri_mismatch error. Users should be able to login once with Google OAuth, but the current setup appears to have configuration issues preventing proper authentication.

## Steps to Reproduce

1. Navigate to https://healthapp.compica.com/login
2. Click the "Sign in with Google" button
3. Google OAuth consent screen appears briefly
4. Error page displays with message: "Access blocked: This app's request is invalid" and "Error 400: redirect_uri_mismatch"

## Expected Behavior

Users should be able to authenticate once using Google OAuth and be logged into the Laravel application successfully.

## Actual Behavior

Google OAuth returns error 400: redirect_uri_mismatch, preventing users from logging in. The application should be a standard Laravel app without requiring multiple authentication steps or a separate frontend SPA.

## Environment

### For Web Applications:
- **Browser**: Chrome (latest), Firefox (latest)
- **Browser Version**: Chrome 131.0+, Firefox 133.0+
- **OS**: Windows 11, macOS 14.0+
- **OS Version**: Windows 11 23H2, macOS Sonoma 14.1+
- **Screen Resolution**: Various (not relevant to issue)

### General:
- **User Role**: Any user attempting to sign in
- **Account Type**: N/A (authentication issue)

## Screenshots/Logs

```
Access blocked: This app's request is invalid
You can't sign in because this app sent an invalid request. You can try again later, or contact the developer about this issue. Learn more about this error
If you are a developer of this app, see
Error 400: redirect_uri_mismatch
```

## Technical Details

The application has a complex multi-tier architecture with three separate applications each implementing authentication differently. The redirect_uri_mismatch error occurs in the web-app (HTML/JS frontend) which uses Google Identity Services with an incorrectly configured OAuth client.

**Architecture Components**:
1. **Flutter Mobile App**: Uses Laravel API with JWT authentication
2. **Laravel Backend**: Provides API (JWT) and web routes (session-based OAuth) - web routes unused
3. **Web App**: Standalone HTML/JS app using Google Identity Services + Laravel API

**Specific Issue**: The web-app uses Google OAuth client ID `741266813874-275q1r6aug39onitf95lepsh02msg2s7.apps.googleusercontent.com` which is configured for Android/mobile, not web applications. The production domain `healthapp.compica.com` is not listed as an authorized redirect URI.

**Root Cause Analysis**:
- Web-app bypasses Laravel's proper OAuth implementation
- Uses Google Identity Services directly instead of OAuth redirect flow
- OAuth client configured for wrong platform (Android vs Web)
- Multiple conflicting authentication systems exist simultaneously

## Solution

**Immediate Fix (Option 1 - Fix Current Web-App)**:
1. Create new Google OAuth 2.0 Client ID for "Web application" in Google Cloud Console
2. Add authorized redirect URIs: `https://healthapp.compica.com`
3. Update client ID in `backend/web-app/app.js` (replace `741266813874-275q1r6aug39onitf95lepsh02msg2s7.apps.googleusercontent.com`)
4. Test authentication flow

**Recommended Long-term Fix (Option 2 - Consolidate Architecture)**:
1. Remove web-app entirely and use Laravel's built-in web authentication
2. Implement web dashboard using Laravel Blade templates and existing OAuth routes
3. Single authentication system eliminates configuration conflicts

**Alternative (Option 3 - API-Only Architecture)**:
1. Remove web-app and unused Laravel web routes
2. Create separate modern web frontend (React/Vue) that uses only the Laravel API
3. Maintain single JWT-based authentication system

## Reference Documents

- [Backend Architecture Report](../docs/backend-architecture-report.md) - Complete architecture analysis
- Laravel Socialite documentation - Google OAuth setup
- Google OAuth 2.0 documentation - Authorized redirect URIs configuration
- Laravel deployment guide - Environment configuration

## Technical References

- Laravel Socialite configuration: config/services.php
- OAuth environment variables: .env file (GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, etc.)
- Google Cloud Console: APIs & Services > Credentials > OAuth 2.0 Client IDs
- Laravel routes: routes/web.php or routes/auth.php
- OAuth callback route: Likely /auth/google/callback

## Testing

- [ ] Laravel Socialite configuration verified
- [ ] Google Cloud Console OAuth client configured with correct redirect URI
- [ ] Environment variables set correctly in production
- [ ] OAuth routes accessible and functional
- [ ] Manual testing completed on production URL
- [ ] Regression testing completed for Laravel authentication

## Notes

This bug reveals fundamental architectural issues with three separate authentication systems running simultaneously. The immediate OAuth error can be fixed, but the underlying architecture needs consolidation. The current setup with Flutter app (JWT), web-app (Google Identity Services), and unused Laravel web routes (Socialite OAuth) creates maintenance overhead and security risks.

**Business Impact**: Users cannot access the web dashboard, creating a poor user experience and limiting platform accessibility.

**Technical Debt**: Multiple authentication implementations increase complexity and potential security vulnerabilities.

## History

- 2026-01-18 - Created
- 2026-01-18 - Updated to clarify single Laravel application requirement, no dual authentication or SPA frontend
- 2026-01-18 - Added comprehensive backend architecture report revealing multi-tier authentication complexity
- 2026-01-18 - Implemented Solution 2: Removed web-app, consolidated to single Laravel web authentication system</content>
<parameter name="filePath">/Volumes/T7/src/flutter-health-management-app-for-android/project-management/backlog/bugs/BF-005-google-signin-redirect-uri-mismatch.md
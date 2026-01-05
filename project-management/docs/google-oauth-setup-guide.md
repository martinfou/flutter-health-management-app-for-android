# Google OAuth Setup Guide

This guide explains how to set up Google OAuth for the Health Management App authentication system.

## Prerequisites

- Google Cloud account
- Flutter project with `google_sign_in` package installed
- Backend API with Google OAuth verification endpoint

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project selector dropdown at the top
3. Click "New Project"
4. Enter project name (e.g., "Health Management App")
5. Click "Create"
6. Wait for project to be created (may take a few minutes)

## Step 2: Enable Google Sign-In API

1. In Google Cloud Console, ensure your new project is selected
2. Navigate to **APIs & Services > Library**
3. Search for "Google Sign-In API"
4. Click on "Google Sign-In API"
5. Click "Enable"

## Step 3: Create OAuth 2.0 Credentials

### 3.1 Configure OAuth Consent Screen

1. Navigate to **APIs & Services > OAuth consent screen**
2. Select "External" user type and click "Create"
3. Fill in the required fields:
   - **App name**: Health Management App
   - **User support email**: Your email address
   - **Developer contact information**: Your email address
4. Click "Save and Continue"
5. Skip the "Scopes" step (not required for basic sign-in)
6. Add test users (for testing before publication):
   - Click "Add Users"
   - Enter email addresses of testers
7. Click "Save and Continue"

### 3.2 Create OAuth 2.0 Client ID

1. Navigate to **APIs & Services > Credentials**
2. Click "+ Create Credentials"
3. Select "OAuth client ID"
4. Choose application type: **Android**
5. Fill in the required fields:
   - **Package name**: `com.example.health_app` (replace with your app's package name)
     - Found in `app/android/app/build.gradle` as `applicationId`
   - **SHA-1 certificate fingerprint**: Get from keystore (see below)

### 3.3 Get SHA-1 Fingerprint from Keystore

#### For Debug Builds (Development)

```bash
# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Windows
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Look for `SHA1` line in the output:
```
Certificate fingerprints:
    MD5:  ...
    SHA1:  AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
    SHA256: ...
```

#### For Release Builds (Production)

If you have a custom keystore for release builds:

```bash
# macOS/Linux
keytool -list -v -keystore path/to/your/release.keystore -alias your-alias

# Windows
keytool -list -v -keystore path\to\your\release.keystore -alias your-alias
```

You'll be prompted for the keystore password and alias password.

#### Finding Your Keystore

Check `app/android/key.properties` (if exists) or look in your project documentation for release keystore location.

### 3.4 Create the Client ID

1. After entering package name and SHA-1 fingerprint, click "Create"
2. Copy the **Client ID** that appears
3. Save it - you'll need it for:
   - Backend `.env` file: `GOOGLE_CLIENT_ID`
   - Android configuration (optional, for future use)

## Step 4: Update Backend Configuration

### 4.1 Update Backend `.env` File

In `backend/api/.env`, set:

```bash
GOOGLE_CLIENT_ID=<your-client-id-here>
GOOGLE_CLIENT_SECRET=<your-client-secret-here>
```

Note: For mobile app sign-in, the Client Secret is optional but required if you later add web sign-in support.

### 4.2 Restart Backend

After updating `.env`, restart your backend server:

```bash
cd backend/api
php -S localhost:8000 -t public
# Or for production deployment:
# Run deployment scripts to sync .env changes
```

## Step 5: Test Google Sign-In

### 5.1 Add Your Email as Test User

1. In Google Cloud Console, go to **OAuth consent screen**
2. Scroll to "Test users"
3. Click "Add Users"
4. Enter your email address
5. Save

### 5.2 Run the App

1. Build and run your Flutter app:
   ```bash
   cd app
   flutter run
   ```

2. Navigate to the login page
3. Tap "Sign in with Google"
4. Select your Google account
5. Sign in with Google

### 5.3 Verify Backend Integration

Check your backend logs to ensure:
- Google ID token is received
- Token verification succeeds
- User is created/retrieved
- JWT tokens are generated

## Step 6: Move to Production (Optional)

When ready to publish to Play Store:

1. Add production SHA-1 fingerprint to OAuth client
2. Update OAuth consent screen with:
   - App logo
   - Privacy policy URL
   - Terms of service URL
3. Remove test user restrictions
4. Submit for OAuth verification (may take several days)

## Troubleshooting

### Error: "Google Play Services not available or outdated"

**Cause**: Google Play Services not installed or outdated on device/emulator

**Solution**:
- For physical device: Update Google Play Services
- For emulator: Use emulator with Google Play Store (e.g., Pixel images)

### Error: "API key not valid"

**Cause**: Google Client ID is incorrect or SHA-1 fingerprint doesn't match

**Solution**:
- Verify Client ID in `.env` matches Google Cloud Console
- Re-generate SHA-1 fingerprint from keystore
- Add both debug and release SHA-1 fingerprints

### Error: "App not verified"

**Cause**: Testing with email not in test users list

**Solution**:
- Add your email to OAuth consent screen test users
- Wait a few minutes for changes to propagate

### Error: "Google sign-in was cancelled"

**Cause**: User cancelled the sign-in flow

**Expected behavior**: This is not an error - user tapped back or cancelled

## Files to Update

- `backend/api/.env` - Add `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
- `app/lib/core/network/authentication_service.dart` - Already configured for Google OAuth
- `app/lib/core/pages/login_page.dart` - Already includes Google Sign-In button

## References

- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Flutter google_sign_in package](https://pub.dev/packages/google_sign_in)
- [Google API Client Library for PHP](https://github.com/googleapis/google-api-php-client)

---

**Last Updated**: 2026-01-04

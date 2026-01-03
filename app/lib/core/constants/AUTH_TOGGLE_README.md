# Authentication Toggle

## Overview

The authentication system can be enabled or disabled at runtime through a toggle in the Settings page, or at compile-time by changing the default value.

## Usage

### Runtime Toggle (Settings Page)

1. Open the app
2. Go to **Settings** (More tab → Settings)
3. Find **"Authentication"** toggle in the Account section
4. Toggle ON/OFF as needed

**Note**: For full effect, you may need to restart the app after toggling.

### Compile-Time Default

Edit `app/lib/core/constants/auth_config.dart`:

```dart
static const bool isEnabledByDefault = true;  // Change to false to disable by default
```

## Use Cases

### Disable Authentication For:
- **Development**: Test app features without needing to login
- **Testing**: Quick testing without mock server
- **Demo**: Show app functionality without authentication setup
- **Gradual Rollout**: Start with auth disabled, enable later

### Enable Authentication For:
- **Production**: Secure user accounts and data
- **Multi-device**: Enable cloud sync features
- **User Management**: Track users and provide personalized features

## How It Works

### When Authentication is **ENABLED**:
- ✅ Login page shown on app startup
- ✅ Protected routes require authentication
- ✅ User must register/login to access app
- ✅ Profile management available
- ✅ All auth features active

### When Authentication is **DISABLED**:
- ✅ App skips login page
- ✅ Goes directly to main navigation
- ✅ All routes accessible without authentication
- ✅ No login required
- ⚠️ Profile page may not work (requires auth)

## Technical Details

- **Provider**: `authEnabledProvider` (Riverpod StateProvider)
- **Default**: `AuthConfig.isEnabledByDefault` (compile-time constant)
- **Runtime**: Can be changed via Settings toggle
- **Persistence**: Currently in-memory (resets on app restart)

## Future Enhancements

- Persist toggle state in UserPreferences (Hive)
- Add confirmation dialog when disabling auth
- Show warning when auth is disabled in production builds
- Auto-enable auth in production builds




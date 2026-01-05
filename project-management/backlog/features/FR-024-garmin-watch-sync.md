# Feature Request: FR-024 - Garmin Watch Sync Integration

**Status**: ⭕ Not Started
**Priority**: 🟠 High
**Story Points**: 13
**Created**: 2026-01-04
**Updated**: 2026-01-04
**Assigned Sprint**: Backlog

## Description

Integrate Garmin Fenix 6 (and compatible Garmin wearables) to sync health data with the Android app. This enables automatic import of heart rate, activity, sleep, and other health metrics tracked by Garmin devices.

**Recommended Approach**: Use Google Health Connect as the integration layer. Garmin already syncs data to Health Connect (since June 2025), so the app can read from Health Connect rather than integrating directly with Garmin APIs. This provides several advantages:

1. **No vendor lock-in**: Works with any wearable that syncs to Health Connect (Fitbit, Samsung, Oura, Withings, etc.)
2. **No API approval needed**: Health Connect is a standard Android API, no Garmin developer approval required
3. **Standardized data format**: Health Connect normalizes data from different devices
4. **Privacy-focused**: User controls what apps can access which data types

## User Story

As a Garmin Fenix 6 user,
I want to sync my watch's health data with the app,
so that I can see my heart rate, activities, and sleep data alongside my nutrition tracking for a complete health picture.

## Implementation Options

### Option A: Google Health Connect Integration (Recommended)

**Approach**: Read health data from Google Health Connect, where Garmin (and other devices) already sync.

**Pros**:
- Works with Garmin + any other wearable that supports Health Connect
- Standard Android API (no third-party SDK)
- No developer approval process
- Future-proof (Google Fit deprecated, Health Connect is the standard)
- User controls permissions through Health Connect app

**Cons**:
- Requires Android 14+ (or Health Connect app installed on Android 9+)
- Data sync depends on Garmin Connect app syncing to Health Connect
- Slight delay compared to direct API (depends on Garmin sync frequency)

**Data Available**:
- Heart rate (continuous and resting)
- Steps and distance
- Active calories and total calories
- Sleep stages and duration
- Exercise sessions and workouts
- Blood oxygen (SpO2)
- Stress levels (if supported)

### Option B: Direct Garmin Connect API

**Approach**: Integrate directly with Garmin Connect Developer APIs.

**Pros**:
- Direct access to Garmin-specific data
- Real-time data access
- Access to Garmin-specific metrics (Body Battery, Training Status)

**Cons**:
- Requires Garmin Developer Program approval
- Only works with Garmin devices
- More complex implementation
- API rate limits and quotas
- OAuth implementation required

## Acceptance Criteria

- [ ] App reads heart rate data from Health Connect (last 24 hours, 7 days, 30 days)
- [ ] App reads step count and distance data
- [ ] App reads sleep data (duration, stages if available)
- [ ] App reads exercise/activity sessions
- [ ] App reads calorie expenditure data
- [ ] Settings page allows user to enable/disable Health Connect sync
- [ ] User can select which data types to sync
- [ ] Data displays on home dashboard with wearable indicators
- [ ] Weekly AI review incorporates wearable health data
- [ ] Error handling for permission denied or Health Connect unavailable
- [ ] Onboarding flow explains Health Connect setup for Garmin users

## Business Value

- **Complete health picture**: Combines nutrition tracking with activity and biometric data
- **Increased user engagement**: Users see value from automatic data import
- **Better AI insights**: Weekly reviews can incorporate sleep, exercise, and heart rate trends
- **Competitive advantage**: Most nutrition apps don't integrate wearable data
- **Device agnostic**: Works with any Health Connect-compatible wearable, not just Garmin

## Technical Requirements

### Health Connect Integration

- **Minimum SDK**: Android 14 (API 34) native, or Android 9+ with Health Connect app
- **Permission Types**:
  - `READ_HEART_RATE`
  - `READ_STEPS`
  - `READ_DISTANCE`
  - `READ_SLEEP`
  - `READ_EXERCISE`
  - `READ_ACTIVE_CALORIES_BURNED`
  - `READ_TOTAL_CALORIES_BURNED`
- **Sync Strategy**: Background sync every 15-30 minutes (configurable)
- **Data Retention**: Store last 30 days locally for offline access

### Dependencies
- `androidx.health.connect:connect-client:1.x.x`
- Health Connect app installed (pre-installed on Android 14+)

### Garmin Setup (User Instructions)
1. Install Garmin Connect app on Android phone
2. Pair Fenix 6 with Garmin Connect
3. Enable Health Connect sync in Garmin Connect settings
4. Grant Health Connect permissions to the health app

## Reference Documents

- [Health Connect Overview](https://developer.android.com/health-and-fitness/guides/health-connect)
- [Health Connect Data Types](https://developer.android.com/reference/kotlin/androidx/health/connect/client/records/package-summary)
- [Garmin Health Connect Support](https://support.garmin.com/en-US/?faq=1mXD0hkqD97vNqNjXUOQ59)

## Technical References

- Health Connect Client: `androidx.health.connect.client.HealthConnectClient`
- Permission handling: Use standard Health Connect permission flow
- Data Models: Create entities for HeartRate, Steps, Sleep, Exercise
- Repository: `WearableHealthRepository` with Health Connect implementation
- Service: `HealthConnectSyncService` for background sync

### Proposed Architecture

```
lib/
  core/
    wearable/
      health_connect_client.dart       # Platform channel to native
      wearable_repository.dart         # Data access layer
      models/
        heart_rate_record.dart
        sleep_record.dart
        exercise_record.dart
        steps_record.dart
  features/
    wearable_sync/
      presentation/
        pages/
          wearable_settings_page.dart
          health_connect_setup_page.dart
        widgets/
          heart_rate_card.dart
          activity_summary_card.dart
          sleep_summary_card.dart

android/
  app/src/main/kotlin/.../
    HealthConnectService.kt
    HealthConnectChannel.kt
```

## Dependencies

- FR-010: LLM Integration (for incorporating wearable data in AI reviews) ✅ Complete
- None blocking - can be implemented independently

### Synergy with FR-018

FR-018 (Google Health Connect Planned Exercise Integration) also uses Health Connect but for a different purpose:
- **FR-018**: Write workout plans TO Health Connect (exercise planning)
- **FR-023**: Read health data FROM Health Connect (wearable sync)

These features share the Health Connect platform channel infrastructure. If both are implemented, they should share:
- `HealthConnectService.kt` - Native service for Health Connect operations
- `HealthConnectChannel.kt` - Platform channel handler
- Permission handling UI and flows
- Health Connect availability detection

**Recommendation**: Implement FR-023 first (reading is simpler than writing), then FR-018 can extend the same infrastructure.

## Notes

- **Garmin Fenix 6 Compatibility**: The Fenix 6 syncs to Garmin Connect, which syncs to Health Connect. All data types should be available.
- **Health Connect Availability**: Pre-installed on Pixel devices and Android 14+. Available as installable app for Android 9-13.
- **Google Fit Deprecation**: Google Fit APIs are being sunset in 2026, Health Connect is the replacement.
- **Future Enhancement**: Consider adding write capabilities to log exercise from the app to Health Connect.
- **Privacy Consideration**: All Health Connect data stays on-device unless user opts into cloud sync (FR-008).

## Estimated Implementation

| Story | Description | Points |
|-------|-------------|--------|
| 24.1 | Health Connect platform channel and native setup | 5 |
| 24.2 | Heart rate and activity data reading | 3 |
| 24.3 | Sleep data reading and display | 2 |
| 24.4 | Settings UI and permission handling | 3 |
| **Total** | | **13** |

## History

- 2026-01-04 - Created

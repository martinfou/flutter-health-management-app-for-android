# Platform Specifications

## Overview

This document defines Android platform-specific specifications for the Flutter Health Management App, including permissions, platform features, SDK requirements, and Android-specific implementations.

**Reference**: 
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Requirements: `artifacts/requirements.md`
- Integration: `artifacts/phase-3-integration/integration-specifications.md`

## Android SDK Requirements

### Minimum SDK

**API Level 24 (Android 7.0 Nougat)**
- Supports 95%+ of Android devices
- Required for Hive database
- Required for modern Flutter features

### Target SDK

**API Level 34 (Android 14)**
- Latest Android version
- Required for Health Connect integration
- Required for latest security features

### Compile SDK

**API Level 34**
- Match target SDK
- Enable latest Android features

## Android Permissions

### Required Permissions

**Internet** (for post-MVP sync):
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**Network State** (for connectivity checking):
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Optional Permissions

**Activity Recognition** (for Google Fit step counting):
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

**Location** (optional, for location-based activities):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Camera** (for progress photos):
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**Storage** (for progress photos and data export):
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**Notifications** (for reminders):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Permission Request Flow

**Runtime Permissions** (Android 6.0+):
1. Check if permission is granted
2. If not granted, request permission with explanation
3. Handle permission result
4. Gracefully degrade if permission denied

**Implementation**:
```dart
class PermissionHandler {
  static Future<bool> requestActivityRecognition() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }
  
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
}
```

## Android Manifest Configuration

### Application Configuration

```xml
<application
    android:label="Health Tracker"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    
    <!-- Main Activity -->
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop"
        android:theme="@style/LaunchTheme">
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>
    
    <!-- File Provider for sharing -->
    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.fileprovider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/file_paths" />
    </provider>
</application>
```

## Background Tasks

### Work Manager

**Purpose**: Schedule background tasks (sync, notifications)

**Implementation**:
```dart
class BackgroundSyncWorker extends Worker {
  @override
  Future<void> performWork() async {
    // Perform sync operations
    await syncService.syncHealthMetrics();
    return Result.success();
  }
}
```

### Battery Optimization

**Requirements**:
- Request exemption from battery optimization for critical tasks
- Handle battery optimization restrictions gracefully
- Optimize background tasks to minimize battery impact

## Notification Channels

Android requires notification channels for all notifications (Android 8.0+). Channels allow users to control notification behavior per category.

### Channel Configuration

**Medication Reminders Channel**:
```dart
const medicationChannel = AndroidNotificationChannel(
  'medication_reminders',
  'Medication Reminders',
  description: 'Notifications for medication reminders. These are important for medication adherence.',
  importance: Importance.high,
  enableVibration: true,
  playSound: true,
  showBadge: true,
  enableLights: true,
  ledColor: Colors.red,
);

// Create channel
Future<void> createMedicationChannel() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(medicationChannel);
}
```

**Channel Details**:
- **Channel ID**: `medication_reminders` (must be unique)
- **Channel Name**: "Medication Reminders" (user-visible)
- **Description**: Explains purpose to users
- **Importance**: High (shows in heads-up notification, makes sound)
- **Vibration**: Enabled (important for medication adherence)
- **Sound**: Default notification sound
- **Badge**: Shows notification badge on app icon
- **LED**: Red LED color for visual indicator

**Workout Reminders Channel**:
```dart
const workoutChannel = AndroidNotificationChannel(
  'workout_reminders',
  'Workout Reminders',
  description: 'Notifications for scheduled workout reminders and movement breaks.',
  importance: Importance.defaultImportance,
  enableVibration: true,
  playSound: true,
  showBadge: false,
  enableLights: false,
);

// Create channel
Future<void> createWorkoutChannel() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(workoutChannel);
}
```

**Channel Details**:
- **Channel ID**: `workout_reminders`
- **Importance**: Default (normal notification, no heads-up)
- **Vibration**: Enabled (for movement reminders)
- **Sound**: Default notification sound
- **Badge**: Disabled (less critical than medication)

**General Notifications Channel**:
```dart
const generalChannel = AndroidNotificationChannel(
  'general_notifications',
  'General Notifications',
  description: 'General app notifications, updates, and information.',
  importance: Importance.low,
  enableVibration: false,
  playSound: false,
  showBadge: false,
  enableLights: false,
);

// Create channel
Future<void> createGeneralChannel() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(generalChannel);
}
```

**Channel Details**:
- **Channel ID**: `general_notifications`
- **Importance**: Low (silent notification, appears in notification shade)
- **Vibration**: Disabled (not urgent)
- **Sound**: Disabled (not urgent)
- **Use Case**: App updates, information messages, non-urgent reminders

**Safety Alerts Channel**:
```dart
const safetyAlertsChannel = AndroidNotificationChannel(
  'safety_alerts',
  'Safety Alerts',
  description: 'Critical health and safety alerts that require immediate attention.',
  importance: Importance.max,
  enableVibration: true,
  playSound: true,
  showBadge: true,
  enableLights: true,
  ledColor: Colors.red,
  lockscreenVisibility: LockscreenVisibility.public,
);

// Create channel
Future<void> createSafetyAlertsChannel() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(safetyAlertsChannel);
}
```

**Channel Details**:
- **Channel ID**: `safety_alerts`
- **Importance**: Max (highest priority, bypasses Do Not Disturb)
- **Vibration**: Enabled (critical alerts)
- **Sound**: Enabled (critical alerts)
- **Lockscreen Visibility**: Public (visible on lockscreen)
- **Use Case**: Critical health alerts, safety warnings

### Channel Initialization

**Create All Channels on App Start**:
```dart
class NotificationChannelManager {
  static Future<void> initializeChannels() async {
    await createMedicationChannel();
    await createWorkoutChannel();
    await createGeneralChannel();
    await createSafetyAlertsChannel();
  }
}

// Call in main.dart or app initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification channels
  await NotificationChannelManager.initializeChannels();
  
  runApp(MyApp());
}
```

### Notification Channel Best Practices

**1. Channel Creation**:
- Create channels on app startup (before first notification)
- Channels cannot be modified after creation (must delete and recreate)
- Channel importance cannot be changed after creation

**2. Channel Selection**:
- Use appropriate channel for each notification type
- Match channel importance to notification priority
- Consider user preferences (users can modify channel settings)

**3. Channel Management**:
- Don't create unnecessary channels
- Group related notifications in same channel
- Use descriptive channel names and descriptions

**4. User Control**:
- Users can disable channels in Android Settings
- Users can modify channel importance, sound, vibration
- Respect user's channel preferences

### Notification Display with Channels

**Example Notification with Channel**:
```dart
Future<void> showMedicationReminder({
  required String medicationName,
  required String dosage,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    medicationChannel.id, // Use channel ID
    medicationChannel.name, // Channel name
    channelDescription: medicationChannel.description,
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    'Medication Reminder',
    'Time to take $medicationName ($dosage)',
    notificationDetails,
  );
}
```

**Example Safety Alert Notification**:
```dart
Future<void> showSafetyAlert({
  required String title,
  required String message,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    safetyAlertsChannel.id,
    safetyAlertsChannel.name,
    channelDescription: safetyAlertsChannel.description,
    importance: Importance.max,
    priority: Priority.max,
    icon: '@mipmap/ic_launcher',
    styleInformation: BigTextStyleInformation(''), // Expandable notification
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await flutterLocalNotificationsPlugin.show(
    1, // Notification ID
    title,
    message,
    notificationDetails,
  );
}
```

## File Storage

### Internal Storage

**App Data Directory**:
- Store sensitive data in app's internal directory
- Not accessible to other apps
- Cleared on app uninstall

### External Storage

**Progress Photos**:
- Store in app-specific external directory
- Accessible via file picker
- Preserved on app updates

**Data Export**:
- Export to Downloads folder
- Share via Android share sheet

## Health Connect Integration (Android 14+)

### Health Connect Setup

**Requirements**:
- Android 14+ (API 34+)
- Health Connect app installed
- Health Connect permissions granted

**Implementation**:
```dart
class HealthConnectIntegration {
  static Future<bool> isAvailable() async {
    if (Platform.isAndroid) {
      final sdkInt = await PlatformVersion.sdkInt;
      return sdkInt >= 34; // Android 14
    }
    return false;
  }
  
  static Future<bool> requestPermissions() async {
    // Request Health Connect permissions
    // Use health package for Health Connect integration
  }
}
```

## App Icons and Splash Screen

### App Icon

**Requirements**:
- Multiple densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Adaptive icon (Android 8.0+)
- Launcher icon

### Splash Screen

**Implementation**:
- Use Flutter's native splash screen
- Show app logo and name
- Transition to main app

## ProGuard/R8 Configuration

### Rules

**Keep Hive Models**:
```proguard
-keep class * extends io.flutter.plugins.hive.HiveObject { *; }
-keep @hive.HiveType class * { *; }
```

**Keep Data Models**:
```proguard
-keep class * extends com.example.health_app.data.models.** { *; }
```

## Performance Optimization

### Build Configuration

**Release Build**:
- Enable R8 code shrinking
- Enable code obfuscation
- Optimize APK size

**Debug Build**:
- Disable optimizations for faster builds
- Enable debugging symbols

## Testing on Android

### Emulator Requirements

- Android API 24 minimum
- Android API 34 for Health Connect testing
- Google Play Services (for Google Fit)

### Device Testing

- Test on various Android versions (7.0-14)
- Test on different screen sizes
- Test with different Android manufacturers

## References

- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Requirements**: `artifacts/requirements.md`
- **Integration**: `artifacts/phase-3-integration/integration-specifications.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Platform Specifications Complete


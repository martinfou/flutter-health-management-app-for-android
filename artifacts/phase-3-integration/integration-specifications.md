# Integration Specifications

## Overview

This document defines integration specifications for the Flutter Health Management App for Android, including Google Fit/Health Connect integration, manual sale item entry system, LLM API abstraction layer (post-MVP), notification system, and data export/import functionality.

**Reference**: 
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Requirements: `artifacts/requirements.md`
- Feature Specs: `artifacts/phase-2-features/`

## Google Fit Integration

### Architecture

**Package**: Use `health` package for Flutter (supports both Google Fit and Health Connect)

**Integration Pattern**:
- Data source abstraction in data layer
- Repository coordinates between local storage and Google Fit
- Background sync when app is active
- Offline queue for sync requests

### Permissions

**Required Permissions**:
- `android.permission.ACTIVITY_RECOGNITION` - For step counting
- `android.permission.ACCESS_FINE_LOCATION` (optional) - For location-based activities

**Permission Request Flow**:
1. Request permissions on first use
2. Show explanation dialog if permission denied
3. Handle permission denial gracefully (app works without integration)

### Data Sync

**Sync Frequency**:
- Active sync: Every 15 minutes when app is active
- Background sync: When app resumes from background
- Manual sync: User can trigger manual sync

**Data Types Synced**:
- Step count (daily)
- Active minutes (daily)
- Calories burned (daily)
- Heart rate (if available)
- Distance (if available)

**Sync Implementation**:
```dart
class GoogleFitDataSource {
  final Health health = Health();
  
  Future<Either<Failure, ActivityData>> syncTodayActivity() async {
    try {
      // Check permissions
      final hasPermission = await health.hasPermissions([
        HealthDataType.STEPS,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ]);
      
      if (!hasPermission) {
        return Left(PermissionFailure('Google Fit permissions not granted'));
      }
      
      // Get today's data
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final steps = await health.getHealthDataFromTypes(
        [HealthDataType.STEPS],
        startOfDay,
        now,
      );
      
      final calories = await health.getHealthDataFromTypes(
        [HealthDataType.ACTIVE_ENERGY_BURNED],
        startOfDay,
        now,
      );
      
      // Process and return data
      return Right(ActivityData.fromHealthData(steps, calories));
    } catch (e) {
      return Left(IntegrationFailure('Google Fit sync failed: $e'));
    }
  }
}
```

### Error Handling

- **Permission Denied**: Show message, allow app to work without integration
- **No Data Available**: Return empty data, don't show error
- **Network Error**: Queue sync request, retry when online
- **API Error**: Log error, show user-friendly message

## Health Connect Integration

### Architecture

**Package**: Use `health` package (supports Health Connect on Android 14+)

**Platform Requirements**:
- Android 14+ (API Level 34+)
- Health Connect app must be installed on device
- Health Connect permissions granted per data type

**Integration Pattern**:
- Prefer Health Connect when available (Android 14+)
- Fallback to Google Fit on older Android versions
- Unified interface for both platforms
- Automatic platform detection and routing

### Setup and Configuration

**Health Connect App Installation**:
- Health Connect app available on Google Play Store
- Check if app is installed before requesting permissions
- Guide users to install if not available
- Handle gracefully if user cannot install

**Initialization**:
```dart
class HealthConnectDataSource {
  final Health health = Health();
  
  Future<bool> initialize() async {
    if (!Platform.isAndroid) {
      return false;
    }
    
    // Check Android version
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 34) {
      return false; // Health Connect requires Android 14+
    }
    
    // Check if Health Connect is available
    final isAvailable = await health.hasPermissions([HealthDataType.STEPS]);
    return isAvailable != null;
  }
  
  Future<bool> isHealthConnectAvailable() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 34) {
        return false;
      }
      
      // Try to request permissions to check availability
      final requested = await health.requestAuthorization([HealthDataType.STEPS]);
      return requested;
    } catch (e) {
      // Health Connect not available
      return false;
    }
  }
}
```

### Permissions

**Health Connect Permission Model**:
- **Granular Permissions**: Request read/write permissions per data type
- **User Control**: Users can grant/deny permissions per data type
- **Privacy-First**: Health Connect provides better privacy controls than Google Fit

**Required Permissions**:
```dart
// Data types to request read permissions for
final readDataTypes = [
  HealthDataType.STEPS,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.HEART_RATE,
  HealthDataType.DISTANCE,
];

// Optional: Write permissions for data we want to write back
final writeDataTypes = [
  HealthDataType.WEIGHT, // If we want to sync weight back
  HealthDataType.HEIGHT,
];
```

**Permission Request Flow**:
```dart
Future<Either<Failure, bool>> requestHealthConnectPermissions() async {
  try {
    // Check if Health Connect is available
    if (!await isHealthConnectAvailable()) {
      return Left(Failure('Health Connect not available on this device'));
    }
    
    // Request read permissions
    final readGranted = await health.requestAuthorization(readDataTypes);
    
    if (!readGranted) {
      return Left(PermissionFailure(
        'Health Connect read permissions not granted'
      ));
    }
    
    // Optionally request write permissions
    final writeGranted = await health.requestAuthorization(writeDataTypes);
    
    return Right(true);
  } catch (e) {
    return Left(Failure('Failed to request Health Connect permissions: $e'));
  }
}
```

**Permission Status Checking**:
```dart
Future<Map<HealthDataType, bool>> checkPermissionStatus() async {
  final status = <HealthDataType, bool>{};
  
  for (final dataType in readDataTypes) {
    final hasPermission = await health.hasPermissions([dataType]);
    status[dataType] = hasPermission ?? false;
  }
  
  return status;
}
```

**Handling Partial Permission Grants**:
```dart
Future<Either<Failure, ActivityData>> syncHealthConnectData() async {
  final permissionStatus = await checkPermissionStatus();
  
  // Check which permissions are granted
  final hasSteps = permissionStatus[HealthDataType.STEPS] ?? false;
  final hasCalories = permissionStatus[HealthDataType.ACTIVE_ENERGY_BURNED] ?? false;
  
  // Sync only data types with granted permissions
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  
  int? steps;
  double? calories;
  
  if (hasSteps) {
    try {
      final stepsData = await health.getHealthDataFromTypes(
        [HealthDataType.STEPS],
        startOfDay,
        now,
      );
      steps = _calculateDailySteps(stepsData);
    } catch (e) {
      // Log error but continue with other data types
      debugPrint('Error fetching steps: $e');
    }
  }
  
  if (hasCalories) {
    try {
      final caloriesData = await health.getHealthDataFromTypes(
        [HealthDataType.ACTIVE_ENERGY_BURNED],
        startOfDay,
        now,
      );
      calories = _calculateDailyCalories(caloriesData);
    } catch (e) {
      debugPrint('Error fetching calories: $e');
    }
  }
  
  return Right(ActivityData(
    steps: steps,
    calories: calories,
    timestamp: now,
  ));
}
```

### Data Sync

**Sync Strategy**:
- Same unified interface as Google Fit
- Health Connect provides more granular permissions
- Better privacy controls for users
- Automatic fallback to Google Fit on Android < 14

**Data Sync Implementation**:
```dart
class UnifiedHealthDataSource {
  final Health health = Health();
  bool? _isHealthConnectAvailable;
  
  Future<Either<Failure, ActivityData>> syncTodayActivity() async {
    // Determine which platform to use
    final useHealthConnect = await _shouldUseHealthConnect();
    
    if (useHealthConnect) {
      return await _syncFromHealthConnect();
    } else {
      return await _syncFromGoogleFit();
    }
  }
  
  Future<bool> _shouldUseHealthConnect() async {
    if (_isHealthConnectAvailable != null) {
      return _isHealthConnectAvailable!;
    }
    
    if (!Platform.isAndroid) {
      _isHealthConnectAvailable = false;
      return false;
    }
    
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 34) {
      _isHealthConnectAvailable = false;
      return false;
    }
    
    // Check if Health Connect is available and permissions granted
    try {
      final hasPermission = await health.hasPermissions([HealthDataType.STEPS]);
      _isHealthConnectAvailable = hasPermission ?? false;
      return _isHealthConnectAvailable!;
    } catch (e) {
      _isHealthConnectAvailable = false;
      return false;
    }
  }
  
  Future<Either<Failure, ActivityData>> _syncFromHealthConnect() async {
    // Health Connect sync implementation
    return await syncHealthConnectData();
  }
  
  Future<Either<Failure, ActivityData>> _syncFromGoogleFit() async {
    // Google Fit sync implementation (existing)
    return await syncGoogleFitData();
  }
}
```

**Data Sync Frequency**:
- **Active Sync**: Every 15 minutes when app is active
- **Background Sync**: When app resumes from background
- **Manual Sync**: User can trigger manual sync
- **Efficient Queries**: Query only new data since last sync

**Data Processing**:
```dart
int _calculateDailySteps(List<HealthDataPoint> dataPoints) {
  int totalSteps = 0;
  
  for (final point in dataPoints) {
    if (point.value is NumericHealthValue) {
      totalSteps += (point.value as NumericHealthValue).numericValue.toInt();
    }
  }
  
  return totalSteps;
}

double _calculateDailyCalories(List<HealthDataPoint> dataPoints) {
  double totalCalories = 0.0;
  
  for (final point in dataPoints) {
    if (point.value is NumericHealthValue) {
      totalCalories += (point.value as NumericHealthValue).numericValue;
    }
  }
  
  return totalCalories;
}
```

### Error Handling

**Common Error Scenarios**:
1. **Health Connect Not Installed**: Guide user to install from Play Store
2. **Permissions Denied**: Show explanation and allow app to work without integration
3. **API Errors**: Log error, show user-friendly message, queue for retry
4. **No Data Available**: Return empty data, don't show error
5. **Platform Not Supported**: Fallback to Google Fit or gracefully degrade

**Error Handling Implementation**:
```dart
Future<Either<Failure, ActivityData>> syncWithErrorHandling() async {
  try {
    if (!await isHealthConnectAvailable()) {
      // Try Google Fit fallback
      return await _syncFromGoogleFit();
    }
    
    return await _syncFromHealthConnect();
  } on PlatformException catch (e) {
    if (e.code == 'permission_denied') {
      return Left(PermissionFailure('Health Connect permissions denied'));
    } else if (e.code == 'not_available') {
      return Left(Failure('Health Connect not available'));
    } else {
      return Left(Failure('Health Connect sync failed: ${e.message}'));
    }
  } catch (e) {
    return Left(Failure('Unexpected error: ${e.toString()}'));
  }
}
```

### Privacy and Security

**Data Privacy**:
- Health Connect provides better privacy controls
- Users can revoke permissions at any time
- All health data remains on device (no cloud sync in MVP)
- Respect user privacy choices

**Best Practices**:
- Request only necessary permissions
- Explain why permissions are needed
- Allow app to function without permissions
- Don't store sensitive health data unnecessarily

## Manual Sale Item Entry System

### Features

- Manual entry of grocery store sale items
- Data caching for offline access
- Bilingual support (French/English) for Quebec
- Sale item search and filtering
- Sale expiration tracking

### UI Components

**Sale Entry Screen**:
- Item name input (bilingual)
- Category dropdown (produce, meat, dairy, pantry)
- Store name input
- Regular price input
- Sale price input
- Discount percentage (auto-calculate)
- Unit selector (lb, oz, each, kg, g)
- Valid from/to date pickers
- Description field (optional)
- Save button

**Sale Item List**:
- Filter by store, category, active sales
- Search by name
- Sort by discount, expiration date
- Display sale badges

### Data Caching

**Cache Strategy**:
- Store sale items in local Hive database
- Cache for offline access
- Auto-expire items past validTo date
- Manual refresh option

**Implementation**:
```dart
class SaleItemCache {
  final HiveBox<SaleItem> saleItemsBox;
  
  Future<void> cacheSaleItem(SaleItem item) async {
    await saleItemsBox.put(item.id, item);
  }
  
  Future<List<SaleItem>> getActiveSales() async {
    final now = DateTime.now();
    return saleItemsBox.values
        .where((item) => 
            item.validFrom.isBefore(now) &&
            item.validTo.isAfter(now))
        .toList();
  }
  
  Future<void> expireOldSales() async {
    final now = DateTime.now();
    final expired = saleItemsBox.values
        .where((item) => item.validTo.isBefore(now))
        .toList();
    
    for (final item in expired) {
      await saleItemsBox.delete(item.id);
    }
  }
}
```

### Bilingual Support

**Quebec Support**:
- French/English interface
- Store names in both languages
- Category names in both languages
- Search in both languages

**Implementation**:
- Use Flutter's `intl` package
- Store bilingual data in sale items
- Detect user locale for display

## LLM API Abstraction Layer (Post-MVP)

### Architecture

**Design Pattern**: Provider pattern with adapters

**Components**:
- LLM Provider interface
- Provider adapters (DeepSeek, OpenAI, Anthropic, Ollama)
- Provider factory
- Configuration system

### Provider Interface

```dart
abstract class LLMProvider {
  Future<LLMResponse> generateCompletion(LLMRequest request);
  Future<Stream<LLMResponse>> generateStream(LLMRequest request);
  String get providerName;
  bool get supportsStreaming;
}
```

### Adapter Implementations

**DeepSeek Adapter** (Default):
- OpenAI-compatible API
- Cost-effective
- Excellent quality

**OpenAI Adapter**:
- GPT-4o-mini (fallback)
- Standard OpenAI API

**Anthropic Adapter**:
- Claude 3 Haiku
- Alternative provider

**Ollama Adapter**:
- Local/offline LLM
- For development/testing

### Configuration System

**Runtime Configuration**:
- Provider selection via config
- Model selection per provider
- API key management
- Rate limiting configuration

**Implementation**:
```dart
class LLMConfig {
  final String provider; // 'deepseek', 'openai', 'anthropic', 'ollama'
  final String model;
  final String? apiKey;
  final int maxTokens;
  final double temperature;
  final bool enablePromptCaching;
  final int rateLimitPerMinute;
}
```

## Notification System

### Notification Types

**Medication Reminders**:
- Scheduled based on medication times
- Repeat daily/weekly as needed
- Action: Mark as taken

**Workout Reminders**:
- Scheduled workout reminders
- Customizable timing
- Action: Start workout

**Movement Breaks** (Desk Reset):
- Remind user to move during sedentary periods
- Configurable frequency
- Action: Dismiss or log activity

**Check-in Reminders**:
- Daily health metric entry reminders
- Weekly review reminders
- Action: Open app to relevant screen

### Notification Scheduling

**Implementation**:
```dart
class NotificationScheduler {
  final FlutterLocalNotificationsPlugin notifications;
  
  Future<void> scheduleMedicationReminder(Medication medication) async {
    for (final time in medication.times) {
      await notifications.zonedSchedule(
        id: _generateId(medication.id, time),
        title: 'Medication Reminder',
        body: 'Time to take ${medication.name}',
        scheduledDate: _calculateNextOccurrence(time),
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
```

### Notification Display

**Requirements**:
- Clear, actionable notifications
- Sound and vibration (user configurable)
- Notification channels for Android
- Persistent notifications for important reminders

## Data Export/Import

### Export Functionality

**Export Format**: JSON

**Export Structure**:
```json
{
  "export_version": "1.0",
  "export_date": "2024-01-15T00:00:00Z",
  "user_profile": { /* UserProfile JSON */ },
  "health_metrics": [ /* Array of HealthMetric JSON */ ],
  "medications": [ /* Array of Medication JSON */ ],
  "meals": [ /* Array of Meal JSON */ ],
  "exercises": [ /* Array of Exercise JSON */ ],
  "meal_plans": [ /* Array of MealPlan JSON */ ]
}
```

**Export Options**:
- Export all data
- Export date range
- Export specific modules
- Compress export file

### Import Functionality

**Import Validation**:
- Validate export file format
- Validate data structure
- Check for required fields
- Validate data ranges

**Import Process**:
1. Validate import file
2. Backup current data
3. Clear existing data (or merge)
4. Import new data
5. Verify import success

**Error Handling**:
- Show validation errors
- Allow partial import
- Restore backup on failure

## Security Measures (Post-MVP)

### HTTPS/SSL

- All API communication over HTTPS
- Certificate pinning (optional)
- Validate SSL certificates

### JWT Authentication

- JWT tokens for API authentication
- Token refresh mechanism
- Secure token storage

### Password Hashing

- bcrypt for password hashing
- Salt rounds: 10
- Never store plaintext passwords

## References

- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Requirements**: `artifacts/requirements.md`
- **Platform Specs**: `artifacts/phase-3-integration/platform-specifications.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Integration Specifications Complete


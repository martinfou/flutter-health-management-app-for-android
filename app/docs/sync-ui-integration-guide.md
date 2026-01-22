# Sync UI Integration Guide

This guide shows how to integrate the sync UI components into your app screens.

## Available Widgets

### 1. SyncStatusIndicator

A compact icon-based sync status indicator for the app bar.

**Usage in AppBar:**
```dart
import 'package:health_app/shared/widgets/sync_status_indicator.dart';

AppBar(
  title: const Text('Your App'),
  actions: [
    const SyncStatusIndicator(),
    const ManualSyncButton(),
  ],
)
```

**Shows:**
- 🔄 Spinning circle when syncing
- ☁️ Green cloud when synced
- ⚠️ Red cloud when error
- 🌐 Orange cloud when offline

### 2. ManualSyncButton

A button that triggers immediate sync with visual feedback.

**Features:**
- Disabled while sync is in progress
- Shows success/error snackbar after sync
- Provides user feedback

## 3. SyncStatusDetails

A detailed bottom sheet showing per-data-type sync information.

**Usage:**
```dart
import 'package:health_app/shared/widgets/sync_status_details.dart';

// Show the bottom sheet
showSyncStatusDetails(context);

// Or in a button:
ElevatedButton(
  onPressed: () => showSyncStatusDetails(context),
  child: const Text('Sync Details'),
)
```

**Shows:**
- Overall sync status (syncing, error, offline, synced)
- Last sync time
- Per-data-type status:
  - Health Metrics
  - Meals
  - Exercises
  - Medications
- Specific error messages
- Connectivity status

## Integration Examples

### Example 1: Home Screen with Sync Indicator

```dart
import 'package:health_app/shared/widgets/sync_status_indicator.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracker'),
        actions: [
          const SyncStatusIndicator(),
          const ManualSyncButton(),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => showSyncStatusDetails(context),
          ),
        ],
      ),
      body: // Your content
    );
  }
}
```

### Example 2: Settings Screen with Sync Details

```dart
import 'package:health_app/shared/widgets/sync_status_details.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Sync Status'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => showSyncStatusDetails(context),
          ),
          // Other settings
        ],
      ),
    );
  }
}
```

## Using Sync Providers Directly

### Access Sync State

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/providers/sync_state_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return syncState.when(
      data: (state) {
        return Column(
          children: [
            Text('Syncing: ${state.isSyncing}'),
            Text('Connected: ${state.isConnected}'),
            Text('Last sync: ${state.lastSyncDisplay}'),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Access Individual Providers

```dart
// Last sync time display
final lastSyncDisplay = ref.watch(lastSyncTimeDisplayProvider);

// Whether currently syncing
final isSyncing = ref.watch(isSyncingProvider);

// Current error message
final error = ref.watch(syncErrorProvider);

// Trigger manual sync
final manualSync = ref.watch(manualSyncTriggerProvider);
final success = await manualSync();
```

### Access Per-Data-Type Status

```dart
import 'package:health_app/core/sync/enums/sync_data_type.dart';

final syncState = ref.watch(syncStateProvider);

syncState.whenData((state) {
  final mealsStatus = state.getStatus(SyncDataType.meals);
  final exercisesStatus = state.getStatus(SyncDataType.exercises);

  if (mealsStatus != null) {
    print('Meals - Synced: ${mealsStatus.lastSync}');
    print('Meals - Error: ${mealsStatus.error}');
  }
});
```

## Styling & Customization

The sync UI components use standard Material Design colors:
- Green (#4CAF50) for success
- Orange (#FF9800) for offline/warning
- Red (#F44336) for error
- Blue (primaryColor) for in-progress

To customize colors, you can extend the widgets or modify the theme in your app.

## Backend Integration

### Meals Pull Sync

The meals sync now supports bidirectional sync with proper pull implementation:

1. **Local changes are pushed** to backend via `/meals/sync` endpoint
2. **Remote changes are pulled** from backend via `/meals/changes` endpoint
3. **Conflict resolution** uses timestamp-based "latest wins" strategy
4. **Batch operations** use efficient Hive `putAll()` operations

### Required Backend Endpoints

For meals sync to work fully, ensure your backend has:

**Push Endpoint:** `POST /meals/sync`
```json
{
  "changes": [/* meal objects */],
  "last_sync_timestamp": "2026-01-22T10:30:00Z"
}
```

**Pull Endpoint:** `GET /meals/changes?since=2026-01-22T10:30:00Z`
```json
{
  "data": [/* meal objects changed since timestamp */]
}
```

## Testing Sync UI

### Mock Data for Development

```dart
// In your test/development code
final mockSyncState = SyncState(
  isSyncing: false,
  lastSyncTime: DateTime.now().subtract(const Duration(minutes: 5)),
  dataTypeStatuses: {
    SyncDataType.healthMetrics: DataTypeSyncStatus(
      type: SyncDataType.healthMetrics,
      isSyncing: false,
      lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
      error: null,
    ),
    SyncDataType.meals: DataTypeSyncStatus(
      type: SyncDataType.meals,
      isSyncing: false,
      lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
      error: null,
    ),
  },
  errorMessage: null,
  isConnected: true,
  lastConnectivityCheck: DateTime.now(),
);
```

## Performance Considerations

1. **SyncStatusIndicator** - Minimal overhead, recommended for all app bars
2. **SyncStatusDetails** - Full rebuild when sync state changes, use sparingly
3. **Providers** - Efficient via Riverpod, only rebuild affected widgets

## Common Issues

### Sync Status Not Updating

**Problem:** UI doesn't update when sync completes

**Solution:** Ensure you're using `ref.watch()` for reactive updates, not `ref.read()`

### Manual Sync Not Triggering

**Problem:** Manual sync button doesn't respond

**Solution:** Check that user is authenticated. Sync requires valid JWT token.

### Missing Sync Data for Exercises/Medications

**Problem:** Exercises and medications don't pull changes

**Solution:** Exercises and medications currently support push-only sync. Pull sync (like meals) can be added when backend endpoints are implemented.

## Next Steps

1. Integrate sync indicators into your main app screens
2. Test with real backend sync operations
3. Monitor sync performance with many items
4. Implement pull sync for exercises and medications when backend ready
5. Add sync status to mobile notifications


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_sync_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';

/// Provider to trigger background synchronization
/// 
/// Watching this provider in the root widget ensures sync starts when appropriate.
final backgroundSyncProvider = Provider<void>((ref) {
  // Get sync service
  final syncService = ref.watch(healthMetricsSyncServiceProvider);
  
  // Trigger initial sync
  // Fire and forget - don't await result in provider
  syncService.syncHealthMetrics().then((result) {
    if (result.isLeft()) {
      // Log error (conceptual)
      // print('Background sync failed: ${result.getLeft()}');
    }
  });
});

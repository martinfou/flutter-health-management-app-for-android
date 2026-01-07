
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';

/// Provider for health metrics sync state
/// 
/// Returns true if currently syncing, false otherwise.
final isSyncingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(healthMetricsSyncServiceProvider);
  return service.isSyncing;
});

/// Provider to trigger manual sync
final manualSyncProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final service = ref.read(healthMetricsSyncServiceProvider);
    await service.syncHealthMetrics();
  };
});

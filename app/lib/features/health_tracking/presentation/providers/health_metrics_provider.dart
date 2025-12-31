import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Provider for current user ID
/// 
/// Gets the current user profile and extracts the user ID.
/// Returns null if no user profile exists.
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  final result = await repository.getCurrentUserProfile();
  
  return result.fold(
    (failure) => null,
    (profile) => profile.id,
  );
});

/// Provider for all health metrics for the current user
/// 
/// Fetches all health metrics for the current user from the repository.
/// Returns empty list if user not found or no metrics exist.
/// Handles error states by returning empty list.
/// 
/// Performance: Consider using date range queries for better performance
/// with large datasets. This provider loads all metrics which may be slow
/// for users with many entries.
final healthMetricsProvider = FutureProvider<List<HealthMetric>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  
  if (userId == null) {
    return [];
  }
  
  final repository = ref.watch(healthTrackingRepositoryProvider);
  final result = await repository.getHealthMetricsByUserId(userId);
  
  return result.fold(
    (failure) => [],
    (metrics) => metrics,
  );
});

/// Provider for health metrics within a date range
/// 
/// More efficient than loading all metrics when you only need a specific range.
/// Use this provider when displaying charts or history for a specific period.
final healthMetricsByDateRangeProvider = FutureProvider.family<
    List<HealthMetric>, ({
  String userId,
  DateTime startDate,
  DateTime endDate,
})>((ref, params) async {
  final repository = ref.watch(healthTrackingRepositoryProvider);
  final result = await repository.getHealthMetricsByDateRange(
    params.userId,
    params.startDate,
    params.endDate,
  );
  
  return result.fold(
    (failure) => [],
    (metrics) => metrics,
  );
});


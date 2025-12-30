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


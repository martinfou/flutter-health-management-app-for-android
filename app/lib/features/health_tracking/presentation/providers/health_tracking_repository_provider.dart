import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/health_tracking/data/repositories/health_tracking_repository_impl.dart';
import 'package:health_app/features/health_tracking/data/datasources/local/health_tracking_local_datasource.dart';

import 'package:health_app/features/health_tracking/data/datasources/remote/health_tracking_remote_datasource.dart';
import 'package:health_app/features/health_tracking/data/services/health_metrics_sync_service.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Provider for HealthTrackingLocalDataSource
final healthTrackingLocalDataSourceProvider =
    Provider<HealthTrackingLocalDataSource>((ref) {
  return HealthTrackingLocalDataSource();
});

/// Provider for HealthTrackingRemoteDataSource
final healthTrackingRemoteDataSourceProvider =
    Provider<HealthTrackingRemoteDataSource>((ref) {
  return HealthTrackingRemoteDataSource();
});

/// Provider for HealthMetricsSyncService
final healthMetricsSyncServiceProvider =
    Provider<HealthMetricsSyncService>((ref) {
  final localDataSource = ref.watch(healthTrackingLocalDataSourceProvider);
  final remoteDataSource = ref.watch(healthTrackingRemoteDataSourceProvider);
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  return HealthMetricsSyncService(
    localDataSource,
    remoteDataSource,
    userProfileRepository: userProfileRepository,
  );
});

/// Provider for HealthTrackingRepository
final healthTrackingRepositoryProvider =
    Provider<HealthTrackingRepository>((ref) {
  final localDataSource = ref.watch(healthTrackingLocalDataSourceProvider);
  final syncService = ref.watch(healthMetricsSyncServiceProvider);
  return HealthTrackingRepositoryImpl(localDataSource, syncService);
});


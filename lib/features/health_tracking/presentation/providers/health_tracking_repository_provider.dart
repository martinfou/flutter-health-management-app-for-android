import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/health_tracking/data/repositories/health_tracking_repository_impl.dart';
import 'package:health_app/features/health_tracking/data/datasources/local/health_tracking_local_datasource.dart';

/// Provider for HealthTrackingLocalDataSource
final healthTrackingLocalDataSourceProvider =
    Provider<HealthTrackingLocalDataSource>((ref) {
  return HealthTrackingLocalDataSource();
});

/// Provider for HealthTrackingRepository
final healthTrackingRepositoryProvider =
    Provider<HealthTrackingRepository>((ref) {
  final localDataSource = ref.watch(healthTrackingLocalDataSourceProvider);
  return HealthTrackingRepositoryImpl(localDataSource);
});


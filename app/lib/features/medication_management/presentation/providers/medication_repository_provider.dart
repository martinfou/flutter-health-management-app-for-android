import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:health_app/features/medication_management/data/repositories/medication_repository_impl.dart';
import 'package:health_app/features/medication_management/data/datasources/local/medication_local_datasource.dart';
import 'package:health_app/core/sync/services/offline_sync_queue.dart';

/// Provider for MedicationLocalDataSource
final medicationLocalDataSourceProvider =
    Provider<MedicationLocalDataSource>((ref) {
  final offlineQueue = ref.watch(offlineSyncQueueProvider);
  return MedicationLocalDataSource(offlineQueue: offlineQueue);
});

/// Provider for MedicationRepository
final medicationRepositoryProvider =
    Provider<MedicationRepository>((ref) {
  final localDataSource = ref.watch(medicationLocalDataSourceProvider);
  return MedicationRepositoryImpl(localDataSource);
});


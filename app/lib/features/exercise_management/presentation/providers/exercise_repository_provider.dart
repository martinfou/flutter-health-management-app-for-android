import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:health_app/features/exercise_management/data/repositories/exercise_repository_impl.dart';
import 'package:health_app/features/exercise_management/data/datasources/local/exercise_local_datasource.dart';
import 'package:health_app/core/sync/services/offline_sync_queue.dart';

/// Provider for ExerciseLocalDataSource
final exerciseLocalDataSourceProvider =
    Provider<ExerciseLocalDataSource>((ref) {
  final offlineQueue = ref.watch(offlineSyncQueueProvider);
  return ExerciseLocalDataSource(offlineQueue: offlineQueue);
});

/// Provider for ExerciseRepository
final exerciseRepositoryProvider =
    Provider<ExerciseRepository>((ref) {
  final localDataSource = ref.watch(exerciseLocalDataSourceProvider);
  return ExerciseRepositoryImpl(localDataSource);
});


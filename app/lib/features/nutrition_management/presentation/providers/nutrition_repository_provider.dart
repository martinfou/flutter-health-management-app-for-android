import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';
import 'package:health_app/features/nutrition_management/data/repositories/nutrition_repository_impl.dart';
import 'package:health_app/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart';
import 'package:health_app/core/sync/services/offline_sync_queue.dart';

/// Provider for NutritionLocalDataSource
final nutritionLocalDataSourceProvider =
    Provider<NutritionLocalDataSource>((ref) {
  final offlineQueue = ref.watch(offlineSyncQueueProvider);
  return NutritionLocalDataSource(offlineQueue: offlineQueue);
});

/// Provider for NutritionRepository
final nutritionRepositoryProvider =
    Provider<NutritionRepository>((ref) {
  final localDataSource = ref.watch(nutritionLocalDataSourceProvider);
  return NutritionRepositoryImpl(localDataSource);
});


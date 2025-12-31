import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';
import 'package:health_app/features/nutrition_management/data/repositories/nutrition_repository_impl.dart';
import 'package:health_app/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart';

/// Provider for NutritionLocalDataSource
final nutritionLocalDataSourceProvider =
    Provider<NutritionLocalDataSource>((ref) {
  return NutritionLocalDataSource();
});

/// Provider for NutritionRepository
final nutritionRepositoryProvider =
    Provider<NutritionRepository>((ref) {
  final localDataSource = ref.watch(nutritionLocalDataSourceProvider);
  return NutritionRepositoryImpl(localDataSource);
});


import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:health_app/features/exercise_management/data/repositories/exercise_repository_impl.dart';
import 'package:health_app/features/exercise_management/data/datasources/local/exercise_local_datasource.dart';

/// Provider for ExerciseLocalDataSource
final exerciseLocalDataSourceProvider =
    Provider<ExerciseLocalDataSource>((ref) {
  return ExerciseLocalDataSource();
});

/// Provider for ExerciseRepository
final exerciseRepositoryProvider =
    Provider<ExerciseRepository>((ref) {
  final localDataSource = ref.watch(exerciseLocalDataSourceProvider);
  return ExerciseRepositoryImpl(localDataSource);
});


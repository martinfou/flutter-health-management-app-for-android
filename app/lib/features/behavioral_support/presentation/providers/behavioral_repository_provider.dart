import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/behavioral_support/domain/repositories/behavioral_repository.dart';
import 'package:health_app/features/behavioral_support/data/repositories/behavioral_repository_impl.dart';
import 'package:health_app/features/behavioral_support/data/datasources/local/behavioral_local_datasource.dart';

/// Provider for BehavioralLocalDataSource
final behavioralLocalDataSourceProvider =
    Provider<BehavioralLocalDataSource>((ref) {
  return BehavioralLocalDataSource();
});

/// Provider for BehavioralRepository
final behavioralRepositoryProvider =
    Provider<BehavioralRepository>((ref) {
  final localDataSource = ref.watch(behavioralLocalDataSourceProvider);
  return BehavioralRepositoryImpl(localDataSource);
});


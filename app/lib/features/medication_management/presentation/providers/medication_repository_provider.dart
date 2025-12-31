import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:health_app/features/medication_management/data/repositories/medication_repository_impl.dart';
import 'package:health_app/features/medication_management/data/datasources/local/medication_local_datasource.dart';

/// Provider for MedicationLocalDataSource
final medicationLocalDataSourceProvider =
    Provider<MedicationLocalDataSource>((ref) {
  return MedicationLocalDataSource();
});

/// Provider for MedicationRepository
final medicationRepositoryProvider =
    Provider<MedicationRepository>((ref) {
  final localDataSource = ref.watch(medicationLocalDataSourceProvider);
  return MedicationRepositoryImpl(localDataSource);
});


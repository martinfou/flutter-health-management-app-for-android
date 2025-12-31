import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:health_app/features/medication_management/data/repositories/medication_repository_impl.dart';
import 'package:health_app/features/medication_management/data/datasources/local/medication_local_datasource.dart';
import 'package:health_app/features/medication_management/data/models/medication_model.dart';
import 'package:health_app/features/medication_management/data/models/medication_log_model.dart';
import 'package:health_app/features/medication_management/domain/usecases/add_medication.dart';
import 'package:health_app/features/medication_management/domain/usecases/log_medication_dose.dart';

/// Integration test for medication logging flow
/// 
/// Tests the complete workflow:
/// 1. Add a medication
/// 2. Log a medication dose
void main() {
  group('Medication Logging Flow Integration Test', () {
    late MedicationRepository repository;

    setUpAll(() async {
      // Initialize Hive for testing with a test directory
      final testDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(testDir.path);
      
      // Register adapters manually for testing
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(MedicationModelAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(MedicationLogModelAdapter());
      }
      
      // Open test boxes with correct type
      if (!Hive.isBoxOpen(HiveBoxNames.medications)) {
        await Hive.openBox<MedicationModel>(HiveBoxNames.medications);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.medicationLogs)) {
        await Hive.openBox<MedicationLogModel>(HiveBoxNames.medicationLogs);
      }
    });

    tearDownAll(() async {
      await Hive.close();
    });

    setUp(() {
      final dataSource = MedicationLocalDataSource();
      repository = MedicationRepositoryImpl(dataSource);
    });

    test('should add medication and retrieve it', () async {
      // Arrange
      const userId = 'test-user-id';
      const medicationName = 'Test Medication';
      const dosage = '10mg';
      final frequency = MedicationFrequency.daily;
      final times = [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 18, minute: 0)];

      final medication = Medication(
        id: 'test-medication-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: medicationName,
        dosage: dosage,
        frequency: frequency,
        times: times,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act - Save the medication
      final saveResult = await repository.saveMedication(medication);

      // Assert - Verify save was successful
      expect(saveResult.isRight(), true);
      saveResult.fold(
        (failure) => fail('Save should succeed, but got: ${failure.message}'),
        (savedMedication) {
          expect(savedMedication.id, medication.id);
          expect(savedMedication.name, medicationName);
          expect(savedMedication.dosage, dosage);
          expect(savedMedication.frequency, frequency);
          expect(savedMedication.userId, userId);
        },
      );

      // Act - Retrieve the medication
      final getResult = await repository.getMedication(medication.id);

      // Assert - Verify retrieval was successful
      expect(getResult.isRight(), true);
      getResult.fold(
        (failure) => fail('Get should succeed, but got: ${failure.message}'),
        (retrievedMedication) {
          expect(retrievedMedication.id, medication.id);
          expect(retrievedMedication.name, medicationName);
        },
      );
    });

    test('should use AddMedicationUseCase to add medication', () async {
      // Arrange
      const userId = 'test-user-id';
      const medicationName = 'New Medication';
      const dosage = '5mg';
      final frequency = MedicationFrequency.daily;
      final times = [TimeOfDay(hour: 8, minute: 0)];

      final useCase = AddMedicationUseCase(repository);

      // Act - Add medication using use case
      final result = await useCase.call(
        userId: userId,
        name: medicationName,
        dosage: dosage,
        frequency: frequency,
        times: times,
        startDate: DateTime.now(),
      );

      // Assert - Verify save was successful
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Use case should succeed: ${failure.message}'),
        (savedMedication) {
          expect(savedMedication.name, medicationName);
          expect(savedMedication.dosage, dosage);
          expect(savedMedication.frequency, frequency);
          expect(savedMedication.userId, userId);
          expect(savedMedication.id.isNotEmpty, true); // ID should be generated
        },
      );
    });

    test('should log medication dose and retrieve it', () async {
      // Arrange
      const userId = 'test-user-id';
      const medicationName = 'Test Medication for Log';
      const dosage = '10mg';
      final frequency = MedicationFrequency.daily;
      final times = [TimeOfDay(hour: 8, minute: 0)];

      // First, create a medication
      final medication = Medication(
        id: 'med-for-log-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: medicationName,
        dosage: dosage,
        frequency: frequency,
        times: times,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final medResult = await repository.saveMedication(medication);
      expect(medResult.isRight(), true, reason: 'Medication should be saved');

      final medicationId = medication.id;
      const logDosage = '10mg';
      final takenAt = DateTime.now();

      final log = MedicationLog(
        id: 'test-log-${DateTime.now().millisecondsSinceEpoch}',
        medicationId: medicationId,
        takenAt: takenAt,
        dosage: logDosage,
        createdAt: DateTime.now(),
      );

      // Act - Save the medication log
      final saveResult = await repository.saveMedicationLog(log);

      // Assert - Verify save was successful
      expect(saveResult.isRight(), true);
      saveResult.fold(
        (failure) => fail('Save log should succeed, but got: ${failure.message}'),
        (savedLog) {
          expect(savedLog.id, log.id);
          expect(savedLog.medicationId, medicationId);
          expect(savedLog.dosage, logDosage);
        },
      );

      // Act - Retrieve the log
      final getResult = await repository.getMedicationLog(log.id);

      // Assert - Verify retrieval was successful
      expect(getResult.isRight(), true);
      getResult.fold(
        (failure) => fail('Get log should succeed, but got: ${failure.message}'),
        (retrievedLog) {
          expect(retrievedLog.id, log.id);
          expect(retrievedLog.medicationId, medicationId);
        },
      );
    });

    test('should use LogMedicationDoseUseCase to log dose', () async {
      // Arrange
      const userId = 'test-user-id';
      const medicationName = 'Medication for Dose Log';
      const dosage = '5mg';
      final frequency = MedicationFrequency.daily;
      final times = [TimeOfDay(hour: 8, minute: 0)];

      // First, create a medication
      final medication = Medication(
        id: 'med-for-dose-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: medicationName,
        dosage: dosage,
        frequency: frequency,
        times: times,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final medResult = await repository.saveMedication(medication);
      expect(medResult.isRight(), true, reason: 'Medication should be saved');

      final medicationId = medication.id;
      final useCase = LogMedicationDoseUseCase(repository);

      // Act - Log dose using use case
      final result = await useCase.call(
        medicationId: medicationId,
        dosage: dosage,
      );

      // Assert - Verify save was successful
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Use case should succeed: ${failure.message}'),
        (savedLog) {
          expect(savedLog.medicationId, medicationId);
          expect(savedLog.dosage, dosage);
          expect(savedLog.id.isNotEmpty, true); // ID should be generated
        },
      );
    });

    test('should validate medication data when adding', () async {
      // Arrange
      const userId = 'test-user-id';
      final useCase = AddMedicationUseCase(repository);

      // Act - Try to add medication with invalid data (empty name)
      final result = await useCase.call(
        userId: userId,
        name: '', // Invalid: empty name
        dosage: '10mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
      );

      // Assert - Verify validation failure
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, anyOf(contains('name'), contains('Name')));
        },
        (_) => fail('Should fail validation for empty name'),
      );
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:health_app/features/medication_management/domain/usecases/log_medication_dose.dart';

// Manual mock for MedicationRepository
class MockMedicationRepository implements MedicationRepository {
  MedicationLog? savedLog;
  Medication? medicationToReturn;
  Failure? failureToReturn;
  Failure? medicationFailureToReturn;

  @override
  Future<Result<MedicationLog>> saveMedicationLog(MedicationLog log) async {
    savedLog = log;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(log);
  }

  @override
  Future<Result<Medication>> getMedication(String id) async {
    if (medicationFailureToReturn != null) {
      return Left(medicationFailureToReturn!);
    }
    if (medicationToReturn != null) {
      return Right(medicationToReturn!);
    }
    return Left(NotFoundFailure('Medication'));
  }

  @override
  Future<Result<List<Medication>>> getMedicationsByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Medication>>> getActiveMedications(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Medication>> saveMedication(Medication medication) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Medication>> updateMedication(Medication medication) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMedication(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<MedicationLog>> getMedicationLog(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<MedicationLog>>> getMedicationLogsByMedicationId(
    String medicationId,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<MedicationLog>>> getMedicationLogsByDateRange(
    String medicationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMedicationLog(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late LogMedicationDoseUseCase useCase;
  late MockMedicationRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicationRepository();
    useCase = LogMedicationDoseUseCase(mockRepository);
  });

  group('LogMedicationDoseUseCase', () {
    test('should save medication log successfully when valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      mockRepository.medicationToReturn = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Aspirin',
        dosage: '100mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final takenAt = DateTime.now();

      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '100mg',
        takenAt: takenAt,
        notes: 'Taken with food',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (log) {
          expect(log.medicationId, 'medication-1');
          expect(log.dosage, '100mg');
          expect(log.notes, 'Taken with food');
          expect(log.id, isNotEmpty);
        },
      );
      expect(mockRepository.savedLog, isNotNull);
    });

    test('should generate ID when not provided', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      mockRepository.medicationToReturn = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '50mg',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (log) => expect(log.id, isNotEmpty),
      );
    });

    test('should use current time when takenAt not provided', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      mockRepository.medicationToReturn = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final beforeCall = DateTime.now();

      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '50mg',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (log) {
          expect(log.takenAt.isAfter(beforeCall) || log.takenAt.isAtSameMomentAs(beforeCall), true);
        },
      );
    });

    test('should return ValidationFailure when dosage is empty', () async {
      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '   ',
        validateMedication: false, // Skip medication validation to test dosage validation
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Dosage cannot be empty'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when takenAt is in future', () async {
      // Arrange
      final futureDate = DateTime.now().add(Duration(hours: 1));

      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '50mg',
        takenAt: futureDate,
        validateMedication: false, // Skip medication validation to test date validation
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot be logged in the future'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when takenAt is too far in past', () async {
      // Arrange
      final tooOldDate = DateTime.now().subtract(Duration(days: 400)); // More than 1 year

      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '50mg',
        takenAt: tooOldDate,
        validateMedication: false, // Skip medication validation to test date validation
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('more than 1 year in the past'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return NotFoundFailure when medication does not exist and validation enabled', () async {
      // Arrange
      mockRepository.medicationFailureToReturn = NotFoundFailure('Medication');

      // Act
      final result = await useCase.call(
        medicationId: 'non-existent',
        dosage: '50mg',
        validateMedication: true,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, contains('Medication'));
        },
        (_) => fail('Should return NotFoundFailure'),
      );
    });

    test('should skip medication validation when validateMedication is false', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '50mg',
        validateMedication: false,
      );

      // Assert
      expect(result.isRight(), true);
      // Should not call getMedication
    });

    test('should save log with notes', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      mockRepository.medicationToReturn = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '50mg',
        notes: 'Taken with breakfast',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (log) {
          expect(log.notes, 'Taken with breakfast');
        },
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');
      mockRepository.medicationToReturn = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await useCase.call(
        medicationId: 'medication-1',
        dosage: '50mg',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (_) => fail('Should return DatabaseFailure'),
      );
    });
  });
}


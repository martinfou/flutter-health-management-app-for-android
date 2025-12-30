import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/data/repositories/medication_repository_impl.dart';
import 'package:health_app/features/medication_management/data/datasources/local/medication_local_datasource.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';

// Mock data source
class MockMedicationLocalDataSource implements MedicationLocalDataSource {
  Medication? medicationToReturn;
  List<Medication>? medicationsToReturn;
  MedicationLog? logToReturn;
  List<MedicationLog>? logsToReturn;
  Failure? failureToReturn;
  Medication? savedMedication;
  MedicationLog? savedLog;
  String? deletedId;

  @override
  Future<Either<Failure, Medication>> getMedication(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (medicationToReturn == null) {
      return Left(NotFoundFailure('Medication'));
    }
    return Right(medicationToReturn!);
  }

  @override
  Future<Either<Failure, List<Medication>>> getMedicationsByUserId(
    String userId,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(medicationsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Medication>>> getActiveMedications(
    String userId,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(medicationsToReturn ?? []);
  }

  @override
  Future<Either<Failure, Medication>> saveMedication(
    Medication medication,
  ) async {
    savedMedication = medication;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(medication);
  }

  @override
  Future<Either<Failure, Medication>> updateMedication(
    Medication medication,
  ) async {
    savedMedication = medication;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(medication);
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, MedicationLog>> getMedicationLog(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (logToReturn == null) {
      return Left(NotFoundFailure('Medication log'));
    }
    return Right(logToReturn!);
  }

  @override
  Future<Either<Failure, List<MedicationLog>>>
      getMedicationLogsByMedicationId(String medicationId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(logsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<MedicationLog>>> getMedicationLogsByDateRange(
    String medicationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(logsToReturn ?? []);
  }

  @override
  Future<Either<Failure, MedicationLog>> saveMedicationLog(
    MedicationLog log,
  ) async {
    savedLog = log;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(log);
  }

  @override
  Future<Either<Failure, void>> deleteMedicationLog(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }
}

void main() {
  late MedicationRepositoryImpl repository;
  late MockMedicationLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockMedicationLocalDataSource();
    repository = MedicationRepositoryImpl(mockDataSource);
  });

  group('saveMedication', () {
    test('should return validation failure when medication name is empty',
        () async {
      // Arrange
      final medication = Medication(
        id: 'test-id',
        userId: 'user-1',
        name: '', // Empty name
        dosage: '150mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMedication(medication);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Medication name cannot be empty'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when times list is empty', () async {
      // Arrange
      final medication = Medication(
        id: 'test-id',
        userId: 'user-1',
        name: 'Wellbutrin',
        dosage: '150mg',
        frequency: MedicationFrequency.daily,
        times: [], // Empty times
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMedication(medication);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('At least one time must be specified'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when start date is in future',
        () async {
      // Arrange
      final medication = Medication(
        id: 'test-id',
        userId: 'user-1',
        name: 'Wellbutrin',
        dosage: '150mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now().add(Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMedication(medication);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Start date cannot be in the future'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when end date is before start date',
        () async {
      // Arrange
      final startDate = DateTime.now();
      final medication = Medication(
        id: 'test-id',
        userId: 'user-1',
        name: 'Wellbutrin',
        dosage: '150mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: startDate,
        endDate: startDate.subtract(Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMedication(medication);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('End date must be after start date'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should save valid medication', () async {
      // Arrange
      final medication = Medication(
        id: 'test-id',
        userId: 'user-1',
        name: 'Wellbutrin',
        dosage: '150mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMedication(medication);

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.savedMedication, isNotNull);
      expect(mockDataSource.savedMedication!.id, 'test-id');
    });
  });

  group('getMedicationLogsByDateRange', () {
    test('should return validation failure when start date is after end date',
        () async {
      // Arrange
      final startDate = DateTime(2024, 1, 15);
      final endDate = DateTime(2024, 1, 10);

      // Act
      final result = await repository.getMedicationLogsByDateRange(
        'medication-id',
        startDate,
        endDate,
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Start date must be before or equal to end date'),
          );
        },
        (_) => fail('Should fail'),
      );
    });
  });

  group('saveMedicationLog', () {
    test('should return validation failure when dosage is empty', () async {
      // Arrange
      final log = MedicationLog(
        id: 'test-id',
        medicationId: 'medication-id',
        takenAt: DateTime.now(),
        dosage: '', // Empty dosage
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMedicationLog(log);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Dosage cannot be empty'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when taken date is in future',
        () async {
      // Arrange
      final log = MedicationLog(
        id: 'test-id',
        medicationId: 'medication-id',
        takenAt: DateTime.now().add(Duration(days: 1)),
        dosage: '150mg',
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMedicationLog(log);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Taken date cannot be in the future'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should save valid medication log', () async {
      // Arrange
      final log = MedicationLog(
        id: 'test-id',
        medicationId: 'medication-id',
        takenAt: DateTime.now(),
        dosage: '150mg',
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMedicationLog(log);

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.savedLog, isNotNull);
      expect(mockDataSource.savedLog!.id, 'test-id');
    });
  });
}


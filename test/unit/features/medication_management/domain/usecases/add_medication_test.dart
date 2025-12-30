import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:health_app/features/medication_management/domain/usecases/add_medication.dart';

// Manual mock for MedicationRepository
class MockMedicationRepository implements MedicationRepository {
  Medication? savedMedication;
  Failure? failureToReturn;

  @override
  Future<Result<Medication>> saveMedication(Medication medication) async {
    savedMedication = medication;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(medication);
  }

  @override
  Future<Result<Medication>> getMedication(String id) async {
    throw UnimplementedError();
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
  Future<Result<MedicationLog>> saveMedicationLog(MedicationLog log) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMedicationLog(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late AddMedicationUseCase useCase;
  late MockMedicationRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicationRepository();
    useCase = AddMedicationUseCase(mockRepository);
  });

  group('AddMedicationUseCase', () {
    test('should save medication successfully when valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      final times = [TimeOfDay(hour: 8, minute: 0)];
      final startDate = DateTime.now();

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Aspirin',
        dosage: '100mg',
        frequency: MedicationFrequency.daily,
        times: times,
        startDate: startDate,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (medication) {
          expect(medication.name, 'Aspirin');
          expect(medication.dosage, '100mg');
          expect(medication.frequency, MedicationFrequency.daily);
          expect(medication.times, times);
          expect(medication.reminderEnabled, true);
          expect(medication.id, isNotEmpty);
        },
      );
      expect(mockRepository.savedMedication, isNotNull);
    });

    test('should generate ID when not provided', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      final times = [TimeOfDay(hour: 8, minute: 0)];

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: times,
        startDate: DateTime.now(),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (medication) => expect(medication.id, isNotEmpty),
      );
    });

    test('should return ValidationFailure when name is empty', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: '   ',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('name cannot be empty'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when dosage is empty', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '   ',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
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

    test('should return ValidationFailure when times list is empty', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [],
        startDate: DateTime.now(),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have at least one scheduled time'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when duplicate times', () async {
      // Arrange
      final duplicateTime = TimeOfDay(hour: 8, minute: 0);

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [duplicateTime, duplicateTime],
        startDate: DateTime.now(),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('duplicate scheduled times'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when hour is invalid', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 25, minute: 0)], // Invalid hour
        startDate: DateTime.now(),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Invalid hour'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when minute is invalid', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 60)], // Invalid minute
        startDate: DateTime.now(),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Invalid minute'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when times count does not match frequency', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily, // Expects 1 time
        times: [
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ], // But has 2 times
        startDate: DateTime.now(),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('does not match frequency'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should accept flexible times for weekly and asNeeded frequencies', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      final times = [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 20, minute: 0),
      ];

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.weekly, // Flexible
        times: times,
        startDate: DateTime.now(),
      );

      // Assert
      expect(result.isRight(), true);
    });

    test('should return ValidationFailure when start date is in future', () async {
      // Arrange
      final futureDate = DateTime.now().add(Duration(days: 1));

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: futureDate,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot be in the future'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when end date is before start date', () async {
      // Arrange
      final startDate = DateTime.now();
      final endDate = startDate.subtract(Duration(days: 1));

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('End date must be after start date'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should accept end date equal to start date', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      final startDate = DateTime.now();
      final endDate = startDate;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('End date must be after start date'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should save medication with reminder disabled', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
        reminderEnabled: false,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (medication) {
          expect(medication.reminderEnabled, false);
        },
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Medication',
        dosage: '50mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: 8, minute: 0)],
        startDate: DateTime.now(),
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


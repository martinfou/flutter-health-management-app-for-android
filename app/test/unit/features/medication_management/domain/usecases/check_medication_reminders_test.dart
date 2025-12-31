import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:health_app/features/medication_management/domain/usecases/check_medication_reminders.dart';

// Manual mock for MedicationRepository
class MockMedicationRepository implements MedicationRepository {
  String? lastUserId;
  String? lastMedicationId;
  List<Medication>? activeMedications;
  List<MedicationLog>? medicationLogs;
  Failure? failureToReturn;

  @override
  Future<Result<List<Medication>>> getActiveMedications(String userId) async {
    lastUserId = userId;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(activeMedications ?? []);
  }

  @override
  Future<Result<Medication>> getMedication(String id) async {
    lastMedicationId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    final medication = activeMedications?.firstWhere(
      (m) => m.id == id,
      orElse: () => throw StateError('Medication not found'),
    );
    if (medication == null) {
      return Left(NotFoundFailure('Medication'));
    }
    return Right(medication);
  }

  @override
  Future<Result<List<MedicationLog>>> getMedicationLogsByDateRange(
    String medicationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(medicationLogs ?? []);
  }

  @override
  Future<Result<List<Medication>>> getMedicationsByUserId(String userId) async {
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
  Future<Result<MedicationLog>> saveMedicationLog(MedicationLog log) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMedicationLog(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late CheckMedicationRemindersUseCase useCase;
  late MockMedicationRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicationRepository();
    useCase = CheckMedicationRemindersUseCase(mockRepository);
  });

  group('CheckMedicationRemindersUseCase', () {
    test('should return reminders for medications not taken', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final scheduledTime = TimeOfDay(hour: now.hour, minute: now.minute);
      
      // Create medication with scheduled time that has passed
      final medication = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Aspirin',
        dosage: '100mg',
        frequency: MedicationFrequency.daily,
        times: [scheduledTime],
        startDate: today.subtract(Duration(days: 7)),
        reminderEnabled: true,
        createdAt: now,
        updatedAt: now,
      );
      
      mockRepository.activeMedications = [medication];
      mockRepository.medicationLogs = []; // Not taken

      // Act
      final result = await useCase.call('user-id');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (reminders) {
          expect(reminders.length, greaterThan(0));
          expect(reminders.first.medication.id, 'medication-1');
          expect(reminders.first.isTaken, false);
        },
      );
    });

    test('should not return reminders for medications already taken', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final scheduledTime = TimeOfDay(hour: now.hour, minute: now.minute);
      
      final medication = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Aspirin',
        dosage: '100mg',
        frequency: MedicationFrequency.daily,
        times: [scheduledTime],
        startDate: today.subtract(Duration(days: 7)),
        reminderEnabled: true,
        createdAt: now,
        updatedAt: now,
      );
      
      // Medication has been taken today
      final log = MedicationLog(
        id: 'log-1',
        medicationId: 'medication-1',
        takenAt: now,
        dosage: '100mg',
        createdAt: now,
      );
      
      mockRepository.activeMedications = [medication];
      mockRepository.medicationLogs = [log];

      // Act
      final result = await useCase.call('user-id');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (reminders) {
          // Should not have reminders for taken medications
          expect(reminders.where((r) => r.medication.id == 'medication-1').isEmpty, true);
        },
      );
    });

    test('should skip medications with reminders disabled', () async {
      // Arrange
      final now = DateTime.now();
      final medication = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Aspirin',
        dosage: '100mg',
        frequency: MedicationFrequency.daily,
        times: [TimeOfDay(hour: now.hour, minute: now.minute)],
        startDate: now.subtract(Duration(days: 7)),
        reminderEnabled: false, // Reminders disabled
        createdAt: now,
        updatedAt: now,
      );
      
      mockRepository.activeMedications = [medication];
      mockRepository.medicationLogs = [];

      // Act
      final result = await useCase.call('user-id');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (reminders) {
          expect(reminders.isEmpty, true);
        },
      );
    });

    test('should skip future scheduled times', () async {
      // Arrange
      final now = DateTime.now();
      final futureTime = TimeOfDay(
        hour: (now.hour + 1) % 24,
        minute: now.minute,
      );
      
      final medication = Medication(
        id: 'medication-1',
        userId: 'user-id',
        name: 'Aspirin',
        dosage: '100mg',
        frequency: MedicationFrequency.daily,
        times: [futureTime], // Future time
        startDate: now.subtract(Duration(days: 7)),
        reminderEnabled: true,
        createdAt: now,
        updatedAt: now,
      );
      
      mockRepository.activeMedications = [medication];
      mockRepository.medicationLogs = [];

      // Act
      final result = await useCase.call('user-id');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (reminders) {
          // Should not have reminders for future times
          expect(reminders.isEmpty, true);
        },
      );
    });

    test('should return empty list when no active medications', () async {
      // Arrange
      mockRepository.activeMedications = [];

      // Act
      final result = await useCase.call('user-id');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (reminders) {
          expect(reminders.isEmpty, true);
        },
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await useCase.call('user-id');

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

    group('getRemindersForMedication', () {
      test('should get reminders for specific medication', () async {
        // Arrange
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final scheduledTime = TimeOfDay(hour: now.hour, minute: now.minute);
        
        final medication = Medication(
          id: 'medication-1',
          userId: 'user-id',
          name: 'Aspirin',
          dosage: '100mg',
          frequency: MedicationFrequency.daily,
          times: [scheduledTime],
          startDate: today.subtract(Duration(days: 7)),
          reminderEnabled: true,
          createdAt: now,
          updatedAt: now,
        );
        
        mockRepository.activeMedications = [medication];
        mockRepository.medicationLogs = [];

        // Act
        final result = await useCase.getRemindersForMedication('medication-1');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (reminders) {
            expect(reminders.length, greaterThan(0));
            expect(reminders.first.medication.id, 'medication-1');
          },
        );
      });

      test('should return empty list for inactive medication', () async {
        // Arrange
        final now = DateTime.now();
        final pastDate = now.subtract(Duration(days: 30));
        
        final medication = Medication(
          id: 'medication-1',
          userId: 'user-id',
          name: 'Aspirin',
          dosage: '100mg',
          frequency: MedicationFrequency.daily,
          times: [TimeOfDay(hour: 8, minute: 0)],
          startDate: pastDate,
          endDate: pastDate.add(Duration(days: 7)), // Ended
          reminderEnabled: true,
          createdAt: now,
          updatedAt: now,
        );
        
        mockRepository.activeMedications = [medication];

        // Act
        final result = await useCase.getRemindersForMedication('medication-1');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (reminders) {
            expect(reminders.isEmpty, true);
          },
        );
      });

      test('should return empty list for medication with reminders disabled', () async {
        // Arrange
        final now = DateTime.now();
        final medication = Medication(
          id: 'medication-1',
          userId: 'user-id',
          name: 'Aspirin',
          dosage: '100mg',
          frequency: MedicationFrequency.daily,
          times: [TimeOfDay(hour: now.hour, minute: now.minute)],
          startDate: now.subtract(Duration(days: 7)),
          reminderEnabled: false,
          createdAt: now,
          updatedAt: now,
        );
        
        mockRepository.activeMedications = [medication];

        // Act
        final result = await useCase.getRemindersForMedication('medication-1');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (reminders) {
            expect(reminders.isEmpty, true);
          },
        );
      });

      test('should return NotFoundFailure when medication does not exist', () async {
        // Arrange
        mockRepository.activeMedications = [];
        mockRepository.failureToReturn = NotFoundFailure('Medication');

        // Act
        final result = await useCase.getRemindersForMedication('non-existent');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NotFoundFailure>());
          },
          (_) => fail('Should return NotFoundFailure'),
        );
      });
    });
  });
}


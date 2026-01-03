import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_providers.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

// Mock for MedicationRepository
class MockMedicationRepository implements MedicationRepository {
  List<Medication>? medicationsToReturn;
  Failure? failureToReturn;

  @override
  Future<MedicationResult> getMedication(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<MedicationListResult> getMedicationsByUserId(String userId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(medicationsToReturn ?? []);
  }

  @override
  Future<MedicationListResult> getActiveMedications(String userId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(medicationsToReturn ?? []);
  }

  @override
  Future<MedicationResult> saveMedication(Medication medication) async {
    throw UnimplementedError();
  }

  @override
  Future<MedicationResult> updateMedication(Medication medication) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMedication(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<MedicationLogResult> getMedicationLog(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<MedicationLogListResult> getMedicationLogsByMedicationId(
    String medicationId,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<MedicationLogListResult> getMedicationLogsByDateRange(
    String medicationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<MedicationLogResult> saveMedicationLog(MedicationLog log) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMedicationLog(String id) async {
    throw UnimplementedError();
  }
}

// Mock for UserProfileRepository
class MockUserProfileRepository implements UserProfileRepository {
  UserProfile? profileToReturn;
  Failure? failureToReturn;

  @override
  Future<UserProfileResult> getUserProfile(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfileResult> getCurrentUserProfile() async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (profileToReturn == null) {
      return Left(NotFoundFailure('UserProfile'));
    }
    return Right(profileToReturn!);
  }

  @override
  Future<UserProfileResult> saveUserProfile(UserProfile profile) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfileResult> updateUserProfile(UserProfile profile) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteUserProfile(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> userProfileExists(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockMedicationRepository mockMedicationRepository;
  late MockUserProfileRepository mockUserProfileRepository;
  late ProviderContainer container;

  setUp(() {
    mockMedicationRepository = MockMedicationRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    
    container = ProviderContainer(
      overrides: [
        medicationRepositoryProvider.overrideWithValue(mockMedicationRepository),
        userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('medicationsProvider', () {
    test('should return medications when user exists and has medications', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      final now = DateTime.now();
      final medications = [
        Medication(
          id: 'med-1',
          userId: 'user-123',
          name: 'Aspirin',
          dosage: '100mg',
          frequency: MedicationFrequency.daily,
          times: [TimeOfDay(hour: 8, minute: 0)],
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        Medication(
          id: 'med-2',
          userId: 'user-123',
          name: 'Vitamin D',
          dosage: '1000 IU',
          frequency: MedicationFrequency.daily,
          times: [TimeOfDay(hour: 12, minute: 0)],
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockMedicationRepository.medicationsToReturn = medications;

      // Act
      final result = await container.read(medicationsProvider.future);

      // Assert
      expect(result, hasLength(2));
      expect(result[0].id, 'med-1');
      expect(result[0].name, 'Aspirin');
      expect(result[1].id, 'med-2');
      expect(result[1].name, 'Vitamin D');
    });

    test('should return empty list when user not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      // Act
      final result = await container.read(medicationsProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when repository returns failure', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockMedicationRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await container.read(medicationsProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when no medications exist', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockMedicationRepository.medicationsToReturn = [];

      // Act
      final result = await container.read(medicationsProvider.future);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('activeMedicationsProvider', () {
    test('should return active medications when user exists and has active medications', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      final now = DateTime.now();
      final medications = [
        Medication(
          id: 'med-1',
          userId: 'user-123',
          name: 'Aspirin',
          dosage: '100mg',
          frequency: MedicationFrequency.daily,
          times: [TimeOfDay(hour: 8, minute: 0)],
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockMedicationRepository.medicationsToReturn = medications;

      // Act
      final result = await container.read(activeMedicationsProvider.future);

      // Assert
      expect(result, hasLength(1));
      expect(result[0].id, 'med-1');
      expect(result[0].name, 'Aspirin');
    });

    test('should return empty list when user not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      // Act
      final result = await container.read(activeMedicationsProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when repository returns failure', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockMedicationRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await container.read(activeMedicationsProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when no active medications exist', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockMedicationRepository.medicationsToReturn = [];

      // Act
      final result = await container.read(activeMedicationsProvider.future);

      // Assert
      expect(result, isEmpty);
    });
  });
}


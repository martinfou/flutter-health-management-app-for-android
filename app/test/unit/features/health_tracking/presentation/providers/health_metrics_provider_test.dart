import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

// Mock for HealthTrackingRepository
class MockHealthTrackingRepository implements HealthTrackingRepository {
  List<HealthMetric>? metricsToReturn;
  Failure? failureToReturn;

  @override
  Future<HealthMetricResult> getHealthMetric(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthMetricListResult> getHealthMetricsByUserId(String userId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metricsToReturn ?? []);
  }

  @override
  Future<HealthMetricListResult> getHealthMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthMetricResult> getHealthMetricByDate(
    String userId,
    DateTime date,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthMetricResult> getLatestWeight(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthMetricResult> saveHealthMetric(HealthMetric metric) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthMetricResult> updateHealthMetric(HealthMetric metric) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteHealthMetric(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteHealthMetricsByUserId(String userId) async {
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
  late MockHealthTrackingRepository mockHealthRepository;
  late MockUserProfileRepository mockUserProfileRepository;
  late ProviderContainer container;

  setUp(() {
    mockHealthRepository = MockHealthTrackingRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    
    container = ProviderContainer(
      overrides: [
        healthTrackingRepositoryProvider.overrideWithValue(mockHealthRepository),
        userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('currentUserIdProvider', () {
    test('should return user ID when user profile exists', () async {
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

      // Act
      final result = await container.read(currentUserIdProvider.future);

      // Assert
      expect(result, 'user-123');
    });

    test('should return null when user profile not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      // Act
      final result = await container.read(currentUserIdProvider.future);

      // Assert
      expect(result, isNull);
    });
  });

  group('healthMetricsProvider', () {
    test('should return health metrics when user exists and has metrics', () async {
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
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-123',
          date: now,
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-123',
          date: now.subtract(Duration(days: 1)),
          weight: 74.5,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockHealthRepository.metricsToReturn = metrics;

      // Act
      final result = await container.read(healthMetricsProvider.future);

      // Assert
      expect(result, hasLength(2));
      expect(result[0].id, 'metric-1');
      expect(result[1].id, 'metric-2');
    });

    test('should return empty list when user not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      // Act
      final result = await container.read(healthMetricsProvider.future);

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
      mockHealthRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await container.read(healthMetricsProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when no metrics exist', () async {
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
      mockHealthRepository.metricsToReturn = [];

      // Act
      final result = await container.read(healthMetricsProvider.future);

      // Assert
      expect(result, isEmpty);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/get_weight_trend.dart';
import 'package:health_app/features/health_tracking/presentation/providers/weight_trend_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';

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

  group('weightTrendProvider', () {
    test('should return weight trend when sufficient data exists', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 14 days of metrics with increasing weight
      for (int i = 0; i < 14; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-123',
          date: today.subtract(Duration(days: 13 - i)),
          weight: 75.0 + (i * 0.2), // Increasing weight
          createdAt: now,
          updatedAt: now,
        ));
      }
      mockHealthRepository.metricsToReturn = metrics;

      // Wait for healthMetricsProvider to load
      await container.read(healthMetricsProvider.future);

      // Act
      final result = container.read(weightTrendProvider);

      // Assert
      expect(result, isNotNull);
      expect(result!.trend, WeightTrend.increasing);
      expect(result.change, greaterThan(0.1));
      expect(result.message, contains('increasing'));
    });

    test('should return null when metrics list is empty', () async {
      // Arrange
      mockHealthRepository.metricsToReturn = [];

      // Wait for healthMetricsProvider to load
      await container.read(healthMetricsProvider.future);

      // Act
      final result = container.read(weightTrendProvider);

      // Assert
      expect(result, isNull);
    });

    test('should return null when insufficient data', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-123',
          date: today,
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockHealthRepository.metricsToReturn = metrics;

      // Wait for healthMetricsProvider to load
      await container.read(healthMetricsProvider.future);

      // Act
      final result = container.read(weightTrendProvider);

      // Assert
      expect(result, isNull);
    });

    test('should return null when healthMetricsProvider is loading', () {
      // Arrange - don't set metrics, so provider will be loading
      mockHealthRepository.metricsToReturn = null;

      // Act
      final result = container.read(weightTrendProvider);

      // Assert
      expect(result, isNull);
    });

    test('should return null when healthMetricsProvider has error', () async {
      // Arrange
      mockHealthRepository.failureToReturn = DatabaseFailure('Database error');

      // Wait for healthMetricsProvider to fail
      try {
        await container.read(healthMetricsProvider.future);
      } catch (_) {
        // Expected to fail
      }

      // Act
      final result = container.read(weightTrendProvider);

      // Assert
      expect(result, isNull);
    });
  });
}


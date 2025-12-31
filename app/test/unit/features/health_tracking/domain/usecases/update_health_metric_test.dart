import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/health_tracking/domain/usecases/update_health_metric.dart';

// Manual mock for HealthTrackingRepository
class MockHealthTrackingRepository implements HealthTrackingRepository {
  HealthMetric? existingMetric;
  HealthMetric? updatedMetric;
  Failure? failureToReturn;
  Failure? getMetricFailure;

  @override
  Future<Result<HealthMetric>> getHealthMetric(String id) async {
    if (getMetricFailure != null) {
      return Left(getMetricFailure!);
    }
    if (existingMetric != null && existingMetric!.id == id) {
      return Right(existingMetric!);
    }
    return Left(NotFoundFailure('Metric not found'));
  }

  @override
  Future<Result<HealthMetric>> updateHealthMetric(HealthMetric metric) async {
    updatedMetric = metric;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metric);
  }

  @override
  Future<Result<HealthMetric>> saveHealthMetric(HealthMetric metric) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<HealthMetric>>> getHealthMetricsByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<HealthMetric>>> getHealthMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<HealthMetric>> getHealthMetricByDate(String userId, DateTime date) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<HealthMetric>> getLatestWeight(String userId) async {
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

void main() {
  late UpdateHealthMetricUseCase useCase;
  late MockHealthTrackingRepository mockRepository;

  setUp(() {
    mockRepository = MockHealthTrackingRepository();
    useCase = UpdateHealthMetricUseCase(mockRepository);
  });

  group('UpdateHealthMetricUseCase', () {
    final testUserId = 'test-user-id';
    final testDate = DateTime(2024, 1, 15);
    final originalCreatedAt = DateTime(2024, 1, 1);

    test('should update health metric successfully when valid', () async {
      // Arrange
      final existingMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      mockRepository.existingMetric = existingMetric;
      mockRepository.failureToReturn = null;
      mockRepository.getMetricFailure = null;

      final updatedData = existingMetric.copyWith(weight: 76.0);

      // Act
      final result = await useCase.call(updatedData);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (metric) {
          expect(metric.id, 'metric-id');
          expect(metric.weight, 76.0);
          expect(metric.userId, testUserId);
          expect(metric.createdAt, originalCreatedAt); // Preserved
          expect(metric.updatedAt.isAfter(originalCreatedAt), true); // Updated
        },
      );
      expect(mockRepository.updatedMetric, isNotNull);
    });

    test('should preserve original createdAt when updating', () async {
      // Arrange
      final existingMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      mockRepository.existingMetric = existingMetric;
      mockRepository.failureToReturn = null;

      final updatedData = existingMetric.copyWith(
        weight: 77.0,
        createdAt: DateTime(2024, 2, 1), // Attempt to change createdAt
      );

      // Act
      final result = await useCase.call(updatedData);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (metric) {
          expect(metric.createdAt, originalCreatedAt); // Original preserved
          expect(metric.updatedAt.isAfter(originalCreatedAt), true); // Updated timestamp
        },
      );
    });

    test('should return ValidationFailure when ID is empty', () async {
      // Arrange
      final metricWithoutId = HealthMetric(
        id: '',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final result = await useCase.call(metricWithoutId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Metric ID is required'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return NotFoundFailure when metric does not exist', () async {
      // Arrange
      mockRepository.existingMetric = null;
      mockRepository.getMetricFailure = NotFoundFailure('Metric not found');

      final metric = HealthMetric(
        id: 'non-existent-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final result = await useCase.call(metric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, contains('not found'));
        },
        (_) => fail('Should return NotFoundFailure'),
      );
    });

    test('should return ValidationFailure when weight is invalid', () async {
      // Arrange
      final existingMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      mockRepository.existingMetric = existingMetric;

      final invalidMetric = existingMetric.copyWith(
        weight: HealthConstants.maxWeightKg + 1,
      );

      // Act
      final result = await useCase.call(invalidMetric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Weight must be between'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should preserve original date when updating (does not validate new date)', () async {
      // Arrange
      // Note: UpdateHealthMetricUseCase preserves the original date from existing metric
      // so it doesn't validate the date from the input metric
      final existingMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      mockRepository.existingMetric = existingMetric;
      mockRepository.failureToReturn = null;

      final differentDate = DateTime(2024, 1, 20);
      final updatedMetric = existingMetric.copyWith(
        weight: 77.0,
        date: differentDate, // Attempt to change date, but will be preserved
      );

      // Act
      final result = await useCase.call(updatedMetric);

      // Assert
      // The date should be preserved from existing metric, not validated from input
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure - date is preserved from existing metric'),
        (metric) {
          final metricDate = DateTime(metric.date.year, metric.date.month, metric.date.day);
          final expectedDate = DateTime(testDate.year, testDate.month, testDate.day);
          expect(metricDate, expectedDate); // Original date preserved
        },
      );
    });

    test('should return ValidationFailure when updated metric has no data', () async {
      // Arrange
      final existingMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      mockRepository.existingMetric = existingMetric;

      // Create metric with all data fields null
      final emptyMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: null,
        sleepQuality: null,
        energyLevel: null,
        restingHeartRate: null,
        systolicBP: null,
        diastolicBP: null,
        bodyMeasurements: null,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );

      // Act
      final result = await useCase.call(emptyMetric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have at least one data field'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should preserve userId when updating', () async {
      // Arrange
      final existingMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      mockRepository.existingMetric = existingMetric;
      mockRepository.failureToReturn = null;

      final updatedData = existingMetric.copyWith(
        weight: 78.0,
        userId: 'different-user-id', // Attempt to change userId
      );

      // Act
      final result = await useCase.call(updatedData);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (metric) {
          expect(metric.userId, testUserId); // Original preserved
          expect(metric.weight, 78.0); // Updated
        },
      );
    });

    test('should preserve date when updating', () async {
      // Arrange
      final existingMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      mockRepository.existingMetric = existingMetric;
      mockRepository.failureToReturn = null;

      final differentDate = DateTime(2024, 1, 20);
      final updatedData = existingMetric.copyWith(
        weight: 79.0,
        date: differentDate, // Attempt to change date
      );

      // Act
      final result = await useCase.call(updatedData);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (metric) {
          final metricDate = DateTime(metric.date.year, metric.date.month, metric.date.day);
          final expectedDate = DateTime(testDate.year, testDate.month, testDate.day);
          expect(metricDate, expectedDate); // Original preserved
          expect(metric.weight, 79.0); // Updated
        },
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      final existingMetric = HealthMetric(
        id: 'metric-id',
        userId: testUserId,
        date: testDate,
        weight: 75.0,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      mockRepository.existingMetric = existingMetric;
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      final updatedData = existingMetric.copyWith(weight: 80.0);

      // Act
      final result = await useCase.call(updatedData);

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


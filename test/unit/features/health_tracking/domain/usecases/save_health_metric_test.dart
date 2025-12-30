import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/health_tracking/domain/usecases/save_health_metric.dart';

// Manual mock for HealthTrackingRepository
class MockHealthTrackingRepository implements HealthTrackingRepository {
  HealthMetric? savedMetric;
  Failure? failureToReturn;

  @override
  Future<Result<HealthMetric>> saveHealthMetric(HealthMetric metric) async {
    savedMetric = metric;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metric);
  }

  @override
  Future<Result<HealthMetric>> getHealthMetric(String id) async {
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
  Future<Result<HealthMetric>> updateHealthMetric(HealthMetric metric) async {
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
  late SaveHealthMetricUseCase useCase;
  late MockHealthTrackingRepository mockRepository;

  setUp(() {
    mockRepository = MockHealthTrackingRepository();
    useCase = SaveHealthMetricUseCase(mockRepository);
  });

  group('SaveHealthMetricUseCase', () {
    final testUserId = 'test-user-id';
    final testDate = DateTime.now();
    final testMetric = HealthMetric(
      id: '',
      userId: testUserId,
      date: testDate,
      weight: 75.0,
      createdAt: testDate,
      updatedAt: testDate,
    );

    test('should save health metric successfully when valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(testMetric);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (metric) {
          expect(metric.id, isNotEmpty);
          expect(metric.weight, 75.0);
          expect(metric.userId, testUserId);
        },
      );
      expect(mockRepository.savedMetric, isNotNull);
    });

    test('should generate ID when metric has empty ID', () async {
      // Arrange
      final metricWithoutId = testMetric.copyWith(id: '');
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(metricWithoutId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (metric) => expect(metric.id, isNotEmpty),
      );
    });

    test('should return ValidationFailure when date is in future', () async {
      // Arrange
      final futureDate = DateTime.now().add(Duration(days: 1));
      final futureMetric = testMetric.copyWith(date: futureDate);

      // Act
      final result = await useCase.call(futureMetric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot be in the future'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
      expect(mockRepository.savedMetric, isNull);
    });

    test('should return ValidationFailure when weight is below minimum', () async {
      // Arrange
      final invalidMetric = testMetric.copyWith(weight: HealthConstants.minWeightKg - 1);

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

    test('should return ValidationFailure when weight is above maximum', () async {
      // Arrange
      final invalidMetric = testMetric.copyWith(weight: HealthConstants.maxWeightKg + 1);

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

    test('should return ValidationFailure when sleep quality is below minimum', () async {
      // Arrange
      final invalidMetric = testMetric.copyWith(
        weight: null,
        sleepQuality: HealthConstants.minSleepQuality - 1,
      );

      // Act
      final result = await useCase.call(invalidMetric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Sleep quality must be between'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when sleep quality is above maximum', () async {
      // Arrange
      final invalidMetric = testMetric.copyWith(
        weight: null,
        sleepQuality: HealthConstants.maxSleepQuality + 1,
      );

      // Act
      final result = await useCase.call(invalidMetric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Sleep quality must be between'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when energy level is invalid', () async {
      // Arrange
      final invalidMetric = testMetric.copyWith(
        weight: null,
        energyLevel: HealthConstants.maxSleepQuality + 1,
      );

      // Act
      final result = await useCase.call(invalidMetric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Energy level must be between'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when resting heart rate is below minimum', () async {
      // Arrange
      final invalidMetric = testMetric.copyWith(
        weight: null,
        restingHeartRate: HealthConstants.minRestingHeartRate - 1,
      );

      // Act
      final result = await useCase.call(invalidMetric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Resting heart rate must be between'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when resting heart rate is above maximum', () async {
      // Arrange
      final invalidMetric = testMetric.copyWith(
        weight: null,
        restingHeartRate: HealthConstants.maxRestingHeartRate + 1,
      );

      // Act
      final result = await useCase.call(invalidMetric);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Resting heart rate must be between'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when metric has no data', () async {
      // Arrange
      final emptyMetric = HealthMetric(
        id: '',
        userId: testUserId,
        date: testDate,
        weight: null,
        sleepQuality: null,
        energyLevel: null,
        restingHeartRate: null,
        bodyMeasurements: null,
        createdAt: testDate,
        updatedAt: testDate,
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

    test('should update updatedAt timestamp when saving', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(testMetric);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (metric) {
          expect(metric.updatedAt, isNotNull);
          expect(metric.updatedAt.isAfter(testDate) || metric.updatedAt.isAtSameMomentAs(testDate), true);
        },
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await useCase.call(testMetric);

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


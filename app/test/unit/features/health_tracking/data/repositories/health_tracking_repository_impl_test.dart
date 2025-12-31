import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/data/repositories/health_tracking_repository_impl.dart';
import 'package:health_app/features/health_tracking/data/datasources/local/health_tracking_local_datasource.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

// Mock data source
class MockHealthTrackingLocalDataSource
    implements HealthTrackingLocalDataSource {
  HealthMetric? metricToReturn;
  List<HealthMetric>? metricsToReturn;
  Failure? failureToReturn;
  HealthMetric? savedMetric;
  String? deletedId;

  @override
  Future<Either<Failure, HealthMetric>> getHealthMetric(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (metricToReturn == null) {
      return Left(NotFoundFailure('Health metric'));
    }
    return Right(metricToReturn!);
  }

  @override
  Future<Either<Failure, List<HealthMetric>>> getHealthMetricsByUserId(
    String userId,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metricsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<HealthMetric>>> getHealthMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metricsToReturn ?? []);
  }

  @override
  Future<Either<Failure, HealthMetric>> getHealthMetricByDate(
    String userId,
    DateTime date,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (metricToReturn == null) {
      return Left(NotFoundFailure('Health metric'));
    }
    return Right(metricToReturn!);
  }

  @override
  Future<Either<Failure, HealthMetric>> getLatestWeight(String userId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (metricToReturn == null) {
      return Left(NotFoundFailure('Health metric'));
    }
    return Right(metricToReturn!);
  }

  @override
  Future<Either<Failure, HealthMetric>> saveHealthMetric(
    HealthMetric metric,
  ) async {
    savedMetric = metric;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metric);
  }

  @override
  Future<Either<Failure, HealthMetric>> updateHealthMetric(
    HealthMetric metric,
  ) async {
    savedMetric = metric;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metric);
  }

  @override
  Future<Either<Failure, void>> deleteHealthMetric(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteHealthMetricsByUserId(
    String userId,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<HealthMetric>>> getHealthMetricsPaginated({
    required String userId,
    required int page,
    required int pageSize,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metricsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<HealthMetric>>> saveHealthMetricsBatch(
    List<HealthMetric> metrics,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(metrics);
  }
}

void main() {
  late HealthTrackingRepositoryImpl repository;
  late MockHealthTrackingLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHealthTrackingLocalDataSource();
    repository = HealthTrackingRepositoryImpl(mockDataSource);
  });

  group('getHealthMetric', () {
    test('should return health metric when found', () async {
      // Arrange
      final metric = HealthMetric(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now(),
        weight: 75.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockDataSource.metricToReturn = metric;

      // Act
      final result = await repository.getHealthMetric('test-id');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (returnedMetric) {
          expect(returnedMetric.id, 'test-id');
          expect(returnedMetric.weight, 75.0);
        },
      );
    });

    test('should return failure when not found', () async {
      // Arrange
      mockDataSource.metricToReturn = null;
      mockDataSource.failureToReturn = NotFoundFailure('Health metric');

      // Act
      final result = await repository.getHealthMetric('non-existent');

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });

  group('getHealthMetricsByDateRange', () {
    test('should return validation failure when start date is after end date',
        () async {
      // Arrange
      final startDate = DateTime(2024, 1, 15);
      final endDate = DateTime(2024, 1, 10);

      // Act
      final result = await repository.getHealthMetricsByDateRange(
        'user-1',
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

    test('should return metrics when date range is valid', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 10);
      final endDate = DateTime(2024, 1, 15);
      final metrics = [
        HealthMetric(
          id: '1',
          userId: 'user-1',
          date: DateTime(2024, 1, 12),
          weight: 75.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      mockDataSource.metricsToReturn = metrics;

      // Act
      final result = await repository.getHealthMetricsByDateRange(
        'user-1',
        startDate,
        endDate,
      );

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should not fail'),
        (returnedMetrics) {
          expect(returnedMetrics.length, 1);
        },
      );
    });
  });

  group('saveHealthMetric', () {
    test('should return validation failure when metric has no data', () async {
      // Arrange
      final metric = HealthMetric(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveHealthMetric(metric);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('At least one metric'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when date is in future', () async {
      // Arrange
      final metric = HealthMetric(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now().add(Duration(days: 1)),
        weight: 75.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveHealthMetric(metric);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Date cannot be in the future'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when weight is out of range',
        () async {
      // Arrange
      final metric = HealthMetric(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now(),
        weight: 10.0, // Below minimum
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveHealthMetric(metric);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Weight must be between'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should save valid health metric', () async {
      // Arrange
      final metric = HealthMetric(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now(),
        weight: 75.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveHealthMetric(metric);

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.savedMetric, isNotNull);
      expect(mockDataSource.savedMetric!.id, 'test-id');
    });
  });

  group('deleteHealthMetric', () {
    test('should delete health metric successfully', () async {
      // Act
      final result = await repository.deleteHealthMetric('test-id');

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.deletedId, 'test-id');
    });
  });
}


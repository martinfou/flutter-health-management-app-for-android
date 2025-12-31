import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/health_tracking/domain/usecases/delete_health_metric.dart';

// Manual mock for HealthTrackingRepository
class MockHealthTrackingRepository implements HealthTrackingRepository {
  String? deletedId;
  Failure? failureToReturn;

  @override
  Future<Result<void>> deleteHealthMetric(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }

  @override
  Future<Result<HealthMetric>> saveHealthMetric(HealthMetric metric) async {
    throw UnimplementedError();
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
  Future<Result<void>> deleteHealthMetricsByUserId(String userId) async {
    throw UnimplementedError();
  }
}

void main() {
  late DeleteHealthMetricUseCase useCase;
  late MockHealthTrackingRepository mockRepository;

  setUp(() {
    mockRepository = MockHealthTrackingRepository();
    useCase = DeleteHealthMetricUseCase(mockRepository);
  });

  group('DeleteHealthMetricUseCase', () {
    test('should delete health metric successfully when ID is valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      const metricId = 'metric-id-123';

      // Act
      final result = await useCase.call(metricId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (_) => expect(mockRepository.deletedId, metricId),
      );
    });

    test('should return ValidationFailure when ID is empty', () async {
      // Act
      final result = await useCase.call('');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Metric ID is required'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
      expect(mockRepository.deletedId, isNull);
    });

    test('should propagate NotFoundFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = NotFoundFailure('Metric not found');
      const metricId = 'non-existent-id';

      // Act
      final result = await useCase.call(metricId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, contains('not found'));
        },
        (_) => fail('Should return NotFoundFailure'),
      );
      expect(mockRepository.deletedId, metricId);
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');
      const metricId = 'metric-id';

      // Act
      final result = await useCase.call(metricId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (_) => fail('Should return DatabaseFailure'),
      );
      expect(mockRepository.deletedId, metricId);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/get_weight_trend.dart';

void main() {
  late GetWeightTrendUseCase useCase;

  setUp(() {
    useCase = GetWeightTrendUseCase();
  });

  group('GetWeightTrendUseCase', () {
    test('should detect increasing trend', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 14 days of metrics with increasing weight
      for (int i = 0; i < 14; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 13 - i)),
          weight: 75.0 + (i * 0.2), // Increasing weight
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (trendResult) {
          expect(trendResult.trend, WeightTrend.increasing);
          expect(trendResult.change, greaterThan(0.1));
          expect(trendResult.message, contains('increasing'));
        },
      );
    });

    test('should detect decreasing trend', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 14 days of metrics with decreasing weight
      for (int i = 0; i < 14; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 13 - i)),
          weight: 75.0 - (i * 0.2), // Decreasing weight
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (trendResult) {
          expect(trendResult.trend, WeightTrend.decreasing);
          expect(trendResult.change, lessThan(-0.1));
          expect(trendResult.message, contains('decreasing'));
        },
      );
    });

    test('should detect stable trend', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 14 days of metrics with stable weight
      for (int i = 0; i < 14; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 13 - i)),
          weight: 75.0, // Stable weight
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (trendResult) {
          expect(trendResult.trend, WeightTrend.stable);
          expect(trendResult.change.abs(), lessThanOrEqualTo(0.1));
          expect(trendResult.message, contains('stable'));
        },
      );
    });

    test('should return ValidationFailure when metrics list is empty', () {
      // Arrange
      final metrics = <HealthMetric>[];

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot be empty'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure with insufficient current data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create only 5 days of metrics (less than 7)
      for (int i = 0; i < 5; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 4 - i)),
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Insufficient data'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure with insufficient previous data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 7 days of current data but only 5 days of previous data
      for (int i = 0; i < 12; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 11 - i)),
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Insufficient data'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should calculate correct averages for both periods', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 14 days: first 7 at 75.0, next 7 at 76.0
      for (int i = 0; i < 14; i++) {
        final weight = i < 7 ? 75.0 : 76.0;
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 13 - i)),
          weight: weight,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (trendResult) {
          expect(trendResult.previousAverage, closeTo(75.0, 0.1));
          expect(trendResult.currentAverage, closeTo(76.0, 0.1));
          expect(trendResult.change, closeTo(1.0, 0.1));
          expect(trendResult.trend, WeightTrend.increasing);
        },
      );
    });

    test('should round averages to 1 decimal place', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 14 days with weights that will result in repeating decimals
      for (int i = 0; i < 14; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 13 - i)),
          weight: 75.333333,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (trendResult) {
          // Check that averages are rounded to 1 decimal place
          final currentString = trendResult.currentAverage.toString();
          final previousString = trendResult.previousAverage.toString();
          expect(currentString.split('.').length, 2);
          expect(previousString.split('.').length, 2);
          expect(currentString.split('.')[1].length, lessThanOrEqualTo(1));
          expect(previousString.split('.')[1].length, lessThanOrEqualTo(1));
        },
      );
    });

    test('should handle metrics outside date range', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 14 days within range
      for (int i = 0; i < 14; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 13 - i)),
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Add metrics outside range (should be ignored)
      metrics.add(HealthMetric(
        id: 'old',
        userId: 'user-id',
        date: today.subtract(Duration(days: 20)),
        weight: 80.0,
        createdAt: now,
        updatedAt: now,
      ));
      metrics.add(HealthMetric(
        id: 'future',
        userId: 'user-id',
        date: today.add(Duration(days: 1)),
        weight: 70.0,
        createdAt: now,
        updatedAt: now,
      ));

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (trendResult) {
          // Should only use the 14 metrics in range
          expect(trendResult.currentAverage, closeTo(75.0, 0.1));
          expect(trendResult.previousAverage, closeTo(75.0, 0.1));
        },
      );
    });
  });
}


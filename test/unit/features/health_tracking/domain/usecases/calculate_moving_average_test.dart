import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/calculate_moving_average.dart';

void main() {
  late CalculateMovingAverageUseCase useCase;

  setUp(() {
    useCase = CalculateMovingAverageUseCase();
  });

  group('CalculateMovingAverageUseCase', () {
    test('should calculate 7-day average correctly with exactly 7 days', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = List.generate(7, (index) {
        return HealthMetric(
          id: 'metric-$index',
          userId: 'user-id',
          date: today.subtract(Duration(days: 6 - index)),
          weight: 75.0 + (index * 0.1),
          createdAt: now,
          updatedAt: now,
        );
      });

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (average) {
          expect(average, closeTo(75.3, 0.1)); // Average of 75.0 to 75.6
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

    test('should return ValidationFailure when less than 7 days of data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = List.generate(5, (index) {
        return HealthMetric(
          id: 'metric-$index',
          userId: 'user-id',
          date: today.subtract(Duration(days: 4 - index)),
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        );
      });

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

    test('should skip metrics without weight data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[
        // 7 metrics, but 2 without weight
        HealthMetric(
          id: '1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 6)),
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: '2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 6)),
          weight: 75.0, // Has weight to ensure 7 days with weight
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: '2b',
          userId: 'user-id',
          date: today.subtract(Duration(days: 5)),
          weight: null, // No weight - this should be skipped
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: '3',
          userId: 'user-id',
          date: today.subtract(Duration(days: 4)),
          weight: 75.2,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: '4',
          userId: 'user-id',
          date: today.subtract(Duration(days: 3)),
          weight: 75.4,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: '5',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          weight: 75.3, // Has weight to ensure 7 days with weight
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: '6',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          weight: 75.6,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: '7',
          userId: 'user-id',
          date: today,
          weight: 75.8,
          createdAt: now,
          updatedAt: now,
        ),
        // Add 2 more with weight to ensure we have 7 with weight
        HealthMetric(
          id: '8',
          userId: 'user-id',
          date: today.subtract(Duration(days: 7)),
          weight: 74.8,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: '9',
          userId: 'user-id',
          date: today.subtract(Duration(days: 8)),
          weight: 74.6,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (average) {
          expect(average, isA<double>());
          expect(average, greaterThan(0));
        },
      );
    });

    test('should handle metrics outside the 7-day window', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[
        // 7 metrics within window
        ...List.generate(7, (index) {
          return HealthMetric(
            id: 'metric-$index',
            userId: 'user-id',
            date: today.subtract(Duration(days: 6 - index)),
            weight: 75.0,
            createdAt: now,
            updatedAt: now,
          );
        }),
        // Metrics outside window (should be ignored)
        HealthMetric(
          id: 'old-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 10)),
          weight: 80.0,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'future-1',
          userId: 'user-id',
          date: today.add(Duration(days: 1)),
          weight: 70.0,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (average) {
          expect(average, closeTo(75.0, 0.1)); // Should only use the 7 metrics in window
        },
      );
    });

    test('should round average to 1 decimal place', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = List.generate(7, (index) {
        return HealthMetric(
          id: 'metric-$index',
          userId: 'user-id',
          date: today.subtract(Duration(days: 6 - index)),
          weight: 75.333333, // Will result in repeating decimal
          createdAt: now,
          updatedAt: now,
        );
      });

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (average) {
          // Check that it's rounded to 1 decimal place
          final stringValue = average.toString();
          final decimalPart = stringValue.split('.')[1];
          expect(decimalPart.length, lessThanOrEqualTo(1));
        },
      );
    });

    test('should handle all same weight values', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = List.generate(7, (index) {
        return HealthMetric(
          id: 'metric-$index',
          userId: 'user-id',
          date: today.subtract(Duration(days: 6 - index)),
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        );
      });

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (average) {
          expect(average, 75.0);
        },
      );
    });
  });
}


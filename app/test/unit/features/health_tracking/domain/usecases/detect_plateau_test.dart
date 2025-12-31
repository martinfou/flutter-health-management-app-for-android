import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/detect_plateau.dart';

void main() {
  late DetectPlateauUseCase useCase;

  setUp(() {
    useCase = DetectPlateauUseCase();
  });

  group('DetectPlateauUseCase', () {
    test('should detect plateau when weight unchanged for 3 weeks', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 21 days of metrics with stable weight
      for (int i = 0; i < 21; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 20 - i)),
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
        (plateauResult) {
          expect(plateauResult.isPlateau, true);
          expect(plateauResult.message, contains('unchanged'));
          expect(plateauResult.averageWeight, closeTo(75.0, 0.1));
        },
      );
    });

    test('should detect plateau when weight and measurements unchanged', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 21 days of metrics with stable weight and measurements
      for (int i = 0; i < 21; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 20 - i)),
          weight: 75.0,
          bodyMeasurements: {
            'waist': 80.0,
            'hips': 100.0,
          },
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
        (plateauResult) {
          expect(plateauResult.isPlateau, true);
          expect(plateauResult.message, contains('Weight and measurements'));
        },
      );
    });

    test('should return no plateau when weight is changing', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 21 days of metrics with changing weight
      for (int i = 0; i < 21; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 20 - i)),
          weight: 75.0 - (i * 0.1), // Decreasing weight
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
        (plateauResult) {
          expect(plateauResult.isPlateau, false);
          expect(plateauResult.message, contains('Weight is changing'));
        },
      );
    });

    test('should return no plateau when measurements are changing', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 21 days of metrics with stable weight but changing measurements
      for (int i = 0; i < 21; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 20 - i)),
          weight: 75.0,
          bodyMeasurements: {
            'waist': 80.0 + (i * 0.5), // Changing waist
            'hips': 100.0,
          },
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
        (plateauResult) {
          // Should still detect weight plateau even if measurements change
          expect(plateauResult.isPlateau, true);
        },
      );
    });

    test('should return no plateau with insufficient data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create only 5 days of metrics
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
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (plateauResult) {
          expect(plateauResult.isPlateau, false);
          expect(plateauResult.message, contains('Insufficient data'));
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

    test('should handle weight within tolerance as unchanged', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 21 days with weight varying within tolerance
      for (int week = 0; week < 3; week++) {
        for (int day = 0; day < 7; day++) {
          final dayIndex = week * 7 + day;
          // Weight varies within ±0.1 kg (within 0.2 kg tolerance)
          final weight = 75.0 + (week * 0.05) + (day * 0.01);
          metrics.add(HealthMetric(
            id: 'metric-$dayIndex',
            userId: 'user-id',
            date: today.subtract(Duration(days: 20 - dayIndex)),
            weight: weight,
            createdAt: now,
            updatedAt: now,
          ));
        }
      }

      // Act
      final result = useCase.call(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (plateauResult) {
          // Should detect plateau since weight is within tolerance
          expect(plateauResult.isPlateau, true);
        },
      );
    });

    test('should handle missing body measurements gracefully', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = <HealthMetric>[];

      // Create 21 days with stable weight but no measurements
      for (int i = 0; i < 21; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: 20 - i)),
          weight: 75.0,
          bodyMeasurements: null,
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
        (plateauResult) {
          // Should still detect weight plateau even without measurements
          expect(plateauResult.isPlateau, true);
          expect(plateauResult.message, contains('Weight unchanged'));
        },
      );
    });
  });
}


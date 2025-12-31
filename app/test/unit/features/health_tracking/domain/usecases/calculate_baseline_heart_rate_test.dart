import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/calculate_baseline_heart_rate.dart';

void main() {
  late CalculateBaselineHeartRateUseCase useCase;

  setUp(() {
    useCase = CalculateBaselineHeartRateUseCase();
  });

  group('CalculateBaselineHeartRateUseCase', () {
    test('should calculate initial baseline from first 7 days', () {
      // Arrange
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 10));
      final metrics = <HealthMetric>[];

      // Create 10 days of metrics with heart rate data
      for (int i = 0; i < 10; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: startDate.add(Duration(days: i)),
          restingHeartRate: 70 + i, // Varying heart rate
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.calculateInitialBaseline(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (baseline) {
          // Should be average of first 7 days: 70, 71, 72, 73, 74, 75, 76 = 73.0
          expect(baseline, closeTo(73.0, 0.1));
        },
      );
    });

    test('should return ValidationFailure when metrics list is empty', () {
      // Arrange
      final metrics = <HealthMetric>[];

      // Act
      final result = useCase.calculateInitialBaseline(metrics);

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

    test('should return ValidationFailure with insufficient data', () {
      // Arrange
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 10));
      final metrics = <HealthMetric>[];

      // Create only 5 days of metrics
      for (int i = 0; i < 5; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: startDate.add(Duration(days: i)),
          restingHeartRate: 70,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.calculateInitialBaseline(metrics);

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

    test('should skip metrics without heart rate data', () {
      // Arrange
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 10));
      final metrics = <HealthMetric>[];

      // Create 10 metrics, ensuring first 7 have heart rate (some later ones don't)
      for (int i = 0; i < 10; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: startDate.add(Duration(days: i)),
          // First 7 days all have heart rate, then alternate
          restingHeartRate: i < 7 ? 70 + (i % 3) : (i % 2 == 0 ? 70 : null),
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.calculateInitialBaseline(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (baseline) {
          // Should calculate from the first 7 metrics with heart rate
          expect(baseline, isA<double>());
          expect(baseline, greaterThan(0));
        },
      );
    });

    test('should sort metrics by date before calculating', () {
      // Arrange
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 10));
      final metrics = <HealthMetric>[];

      // Create metrics in reverse order
      for (int i = 9; i >= 0; i--) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: startDate.add(Duration(days: i)),
          restingHeartRate: 70 + i,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.calculateInitialBaseline(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (baseline) {
          // Should still use first 7 days (sorted by date)
          expect(baseline, closeTo(73.0, 0.1));
        },
      );
    });

    test('should round baseline to 1 decimal place', () {
      // Arrange
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 10));
      final metrics = <HealthMetric>[];

      // Create 7 days with heart rates that will result in repeating decimal
      for (int i = 0; i < 7; i++) {
        metrics.add(HealthMetric(
          id: 'metric-$i',
          userId: 'user-id',
          date: startDate.add(Duration(days: i)),
          restingHeartRate: 70,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final result = useCase.calculateInitialBaseline(metrics);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (baseline) {
          // Check that it's rounded to 1 decimal place
          final stringValue = baseline.toString();
          final decimalPart = stringValue.split('.')[1];
          expect(decimalPart.length, lessThanOrEqualTo(1));
        },
      );
    });

    group('recalculateMonthlyBaseline', () {
      test('should recalculate baseline for a specific month', () {
        // Arrange
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final metrics = <HealthMetric>[];

        // Create metrics for the month
        for (int i = 0; i < 30; i++) {
          metrics.add(HealthMetric(
            id: 'metric-$i',
            userId: 'user-id',
            date: monthStart.add(Duration(days: i)),
            restingHeartRate: 70 + (i % 5), // Varying heart rate
            createdAt: now,
            updatedAt: now,
          ));
        }

        // Act
        final result = useCase.recalculateMonthlyBaseline(metrics, monthStart);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (baseline) {
            expect(baseline, isA<double>());
            expect(baseline, greaterThan(0));
          },
        );
      });

      test('should return ValidationFailure when no data for month', () {
        // Arrange
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final metrics = <HealthMetric>[];

        // Create metrics for a different month
        final otherMonth = monthStart.subtract(Duration(days: 60));
        for (int i = 0; i < 10; i++) {
          metrics.add(HealthMetric(
            id: 'metric-$i',
            userId: 'user-id',
            date: otherMonth.add(Duration(days: i)),
            restingHeartRate: 70,
            createdAt: now,
            updatedAt: now,
          ));
        }

        // Act
        final result = useCase.recalculateMonthlyBaseline(metrics, monthStart);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('No heart rate data'));
          },
          (_) => fail('Should return ValidationFailure'),
        );
      });

      test('should return ValidationFailure when metrics list is empty', () {
        // Arrange
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final metrics = <HealthMetric>[];

        // Act
        final result = useCase.recalculateMonthlyBaseline(metrics, monthStart);

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
    });

    group('call method', () {
      test('should call calculateInitialBaseline', () {
        // Arrange
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 10));
        final metrics = <HealthMetric>[];

        // Create 7 days of metrics
        for (int i = 0; i < 7; i++) {
          metrics.add(HealthMetric(
            id: 'metric-$i',
            userId: 'user-id',
            date: startDate.add(Duration(days: i)),
            restingHeartRate: 70,
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
          (baseline) {
            expect(baseline, 70.0);
          },
        );
      });
    });
  });
}


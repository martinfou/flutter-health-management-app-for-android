import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/safety/resting_heart_rate_alert.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

void main() {
  group('RestingHeartRateAlert', () {
    test('should return alert when heart rate > 100 BPM for 3 consecutive days', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 105,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          restingHeartRate: 102,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          restingHeartRate: 108,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = RestingHeartRateAlert.check(metrics);

      // Assert
      expect(alert, isNotNull);
      expect(alert!.type, AlertType.safety);
      expect(alert.title, 'Elevated Resting Heart Rate');
      expect(alert.severity, AlertSeverity.high);
      expect(alert.requiresAcknowledgment, true);
      expect(alert.cannotDismiss, true);
      expect(alert.message, contains('100 BPM'));
      expect(alert.message, contains('3 consecutive days'));
    });

    test('should return null when insufficient data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 105,
          createdAt: now,
          updatedAt: now,
        ),
        // Only 2 days, need 3
      ];

      // Act
      final alert = RestingHeartRateAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when heart rate not elevated', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 85,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          restingHeartRate: 90,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          restingHeartRate: 88,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = RestingHeartRateAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when not consecutive days', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 3)),
          restingHeartRate: 105,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          restingHeartRate: 102,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          restingHeartRate: 108,
          createdAt: now,
          updatedAt: now,
        ),
        // Gap on day 2, so not consecutive
      ];

      // Act
      final alert = RestingHeartRateAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when some days missing heart rate', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 105,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          // Missing heart rate
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          restingHeartRate: 108,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = RestingHeartRateAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when heart rate exactly at threshold', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 100, // Exactly at threshold
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          restingHeartRate: 100,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          restingHeartRate: 100,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = RestingHeartRateAlert.check(metrics);

      // Assert
      expect(alert, isNull); // Should be > 100, not >=
    });

    test('should handle metrics with other data but missing heart rate', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          weight: 75.0,
          // No heart rate
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          weight: 74.5,
          // No heart rate
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          weight: 74.0,
          // No heart rate
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = RestingHeartRateAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/safety/elevated_heart_rate_alert.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

void main() {
  group('ElevatedHeartRateAlert', () {
    test('should return alert when heart rate > baseline + 20 BPM for 3 days', () {
      // Arrange
      final baseline = 70.0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 95, // 25 BPM above baseline
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          restingHeartRate: 92, // 22 BPM above baseline
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          restingHeartRate: 93, // 23 BPM above baseline
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = ElevatedHeartRateAlert.check(metrics, baseline);

      // Assert
      expect(alert, isNotNull);
      expect(alert!.type, AlertType.safety);
      expect(alert.title, 'Elevated Heart Rate from Baseline');
      expect(alert.severity, AlertSeverity.high);
      expect(alert.requiresAcknowledgment, true);
      expect(alert.cannotDismiss, true);
      expect(alert.message, contains('20 BPM'));
      expect(alert.message, contains('baseline'));
    });

    test('should return null when baseline not established', () {
      // Arrange
      final baseline = 0.0; // Invalid baseline
      final now = DateTime.now();
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: DateTime.now(),
          restingHeartRate: 100,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = ElevatedHeartRateAlert.check(metrics, baseline);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when insufficient data', () {
      // Arrange
      final baseline = 70.0;
      final now = DateTime.now();
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: DateTime.now(),
          restingHeartRate: 95,
          createdAt: now,
          updatedAt: now,
        ),
        // Only 1 day, need 3
      ];

      // Act
      final alert = ElevatedHeartRateAlert.check(metrics, baseline);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when heart rate not elevated enough', () {
      // Arrange
      final baseline = 70.0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 85, // 15 BPM above baseline (not enough)
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          restingHeartRate: 88, // 18 BPM above baseline
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          restingHeartRate: 87, // 17 BPM above baseline
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = ElevatedHeartRateAlert.check(metrics, baseline);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when heart rate exactly at threshold', () {
      // Arrange
      final baseline = 70.0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 90, // Exactly 20 BPM above baseline
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
          restingHeartRate: 90,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = ElevatedHeartRateAlert.check(metrics, baseline);

      // Assert
      expect(alert, isNull); // Should be > baseline + 20, not >=
    });

    test('should return null when not consecutive days', () {
      // Arrange
      final baseline = 70.0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 3)),
          restingHeartRate: 95,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          restingHeartRate: 92,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today,
          restingHeartRate: 93,
          createdAt: now,
          updatedAt: now,
        ),
        // Gap on day 2, so not consecutive
      ];

      // Act
      final alert = ElevatedHeartRateAlert.check(metrics, baseline);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when some days missing heart rate', () {
      // Arrange
      final baseline = 70.0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          restingHeartRate: 95,
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
          restingHeartRate: 93,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = ElevatedHeartRateAlert.check(metrics, baseline);

      // Assert
      expect(alert, isNull);
    });
  });
}


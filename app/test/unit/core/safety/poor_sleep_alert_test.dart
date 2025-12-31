import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/safety/poor_sleep_alert.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

void main() {
  group('PoorSleepAlert', () {
    test('should return alert when sleep quality < 4 for 5 consecutive days', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 4)),
          sleepQuality: 3,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 3)),
          sleepQuality: 2,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          sleepQuality: 1,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-4',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          sleepQuality: 3,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-5',
          userId: 'user-id',
          date: today,
          sleepQuality: 2,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = PoorSleepAlert.check(metrics);

      // Assert
      expect(alert, isNotNull);
      expect(alert!.type, AlertType.warning);
      expect(alert.title, 'Poor Sleep Quality');
      expect(alert.severity, AlertSeverity.medium);
      expect(alert.requiresAcknowledgment, true);
      expect(alert.cannotDismiss, false);
      expect(alert.message, contains('4/10'));
      expect(alert.message, contains('5 consecutive days'));
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
          sleepQuality: 3,
          createdAt: now,
          updatedAt: now,
        ),
        // Only 1 day, need 5
      ];

      // Act
      final alert = PoorSleepAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when sleep quality is good', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 4)),
          sleepQuality: 7,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 3)),
          sleepQuality: 8,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          sleepQuality: 6,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-4',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          sleepQuality: 7,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-5',
          userId: 'user-id',
          date: today,
          sleepQuality: 8,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = PoorSleepAlert.check(metrics);

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
          date: today.subtract(Duration(days: 5)),
          sleepQuality: 3,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 3)),
          sleepQuality: 2,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          sleepQuality: 1,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-4',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          sleepQuality: 3,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-5',
          userId: 'user-id',
          date: today,
          sleepQuality: 2,
          createdAt: now,
          updatedAt: now,
        ),
        // Gap on day 4, so not consecutive
      ];

      // Act
      final alert = PoorSleepAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when sleep quality exactly at threshold', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 4)),
          sleepQuality: 4, // Exactly at threshold
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 3)),
          sleepQuality: 4,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          sleepQuality: 4,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-4',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          sleepQuality: 4,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-5',
          userId: 'user-id',
          date: today,
          sleepQuality: 4,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = PoorSleepAlert.check(metrics);

      // Assert
      expect(alert, isNull); // Should be < 4, not <=
    });

    test('should return null when some days missing sleep quality', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 4)),
          sleepQuality: 3,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-2',
          userId: 'user-id',
          date: today.subtract(Duration(days: 3)),
          // Missing sleep quality
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-3',
          userId: 'user-id',
          date: today.subtract(Duration(days: 2)),
          sleepQuality: 2,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-4',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          sleepQuality: 1,
          createdAt: now,
          updatedAt: now,
        ),
        HealthMetric(
          id: 'metric-5',
          userId: 'user-id',
          date: today,
          sleepQuality: 3,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      final alert = PoorSleepAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });
  });
}


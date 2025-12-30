import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/safety/rapid_weight_loss_alert.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

void main() {
  group('RapidWeightLossAlert', () {
    test('should return alert when weight loss > 1.8 kg/week for 2 weeks', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Week 1: Average weight ~80 kg (days 14-8 ago, not including day 7)
      // Week 2: Average weight ~76 kg (days 7-0, loss of 4 kg = 2 kg/week)
      final metrics = <HealthMetric>[];
      // Week 1: days 14-8 ago
      for (int i = 14; i >= 8; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week1-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 80.0 + (i % 3) * 0.2, // Vary slightly around 80
          createdAt: now,
          updatedAt: now,
        ));
      }
      // Week 2: days 7-0 (last 7 days)
      for (int i = 7; i >= 0; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week2-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 76.0 + (i % 3) * 0.2, // Vary slightly around 76
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final alert = RapidWeightLossAlert.check(metrics);

      // Assert
      expect(alert, isNotNull);
      expect(alert!.type, AlertType.safety);
      expect(alert.title, 'Rapid Weight Loss');
      expect(alert.severity, AlertSeverity.high);
      expect(alert.requiresAcknowledgment, true);
      expect(alert.cannotDismiss, true);
      expect(alert.message, contains('1.8 kg'));
      expect(alert.message, contains('2 consecutive weeks'));
    });

    test('should return null when insufficient data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final metrics = [
        HealthMetric(
          id: 'metric-1',
          userId: 'user-id',
          date: today.subtract(Duration(days: 1)),
          weight: 75.0,
          createdAt: now,
          updatedAt: now,
        ),
        // Only 1 day, need at least 7
      ];

      // Act
      final alert = RapidWeightLossAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when weight loss is within safe range', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Week 1: Average weight ~80 kg
      // Week 2: Average weight ~79 kg (loss of 1 kg = 0.5 kg/week, safe)
      final metrics = <HealthMetric>[];
      for (int i = 13; i >= 7; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week1-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 80.0,
          createdAt: now,
          updatedAt: now,
        ));
      }
      for (int i = 6; i >= 0; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week2-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 79.0,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final alert = RapidWeightLossAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when weight loss exactly at threshold', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Week 1: Average weight ~80 kg
      // Week 2: Average weight ~76.4 kg (loss of 3.6 kg = 1.8 kg/week exactly)
      final metrics = <HealthMetric>[];
      for (int i = 13; i >= 7; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week1-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 80.0,
          createdAt: now,
          updatedAt: now,
        ));
      }
      for (int i = 6; i >= 0; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week2-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 76.4,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final alert = RapidWeightLossAlert.check(metrics);

      // Assert
      expect(alert, isNull); // Should be > 1.8, not >=
    });

    test('should return null when week 1 has no data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Only week 2 data
      final metrics = <HealthMetric>[];
      for (int i = 6; i >= 0; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week2-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 76.0,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final alert = RapidWeightLossAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should return null when week 2 has no data', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Only week 1 data
      final metrics = <HealthMetric>[];
      for (int i = 13; i >= 7; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week1-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 80.0,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final alert = RapidWeightLossAlert.check(metrics);

      // Assert
      expect(alert, isNull);
    });

    test('should handle weight gain (negative loss)', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Week 1: Average weight ~76 kg
      // Week 2: Average weight ~80 kg (gain, not loss)
      final metrics = <HealthMetric>[];
      for (int i = 13; i >= 7; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week1-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 76.0,
          createdAt: now,
          updatedAt: now,
        ));
      }
      for (int i = 6; i >= 0; i--) {
        metrics.add(HealthMetric(
          id: 'metric-week2-$i',
          userId: 'user-id',
          date: today.subtract(Duration(days: i)),
          weight: 80.0,
          createdAt: now,
          updatedAt: now,
        ));
      }

      // Act
      final alert = RapidWeightLossAlert.check(metrics);

      // Assert
      expect(alert, isNull); // Weight gain, not loss
    });
  });
}


import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/safety/safety_alert.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Elevated heart rate alert check
/// 
/// Checks if resting heart rate has increased significantly from baseline.
/// Alert triggered if heart rate increases by > 20 BPM from baseline for 3 consecutive days.
class ElevatedHeartRateAlert {
  /// Check for elevated heart rate alert
  /// 
  /// Requires baseline heart rate to be calculated first.
  /// 
  /// Returns [SafetyAlert] if condition is met, null otherwise.
  static SafetyAlert? check(
    List<HealthMetric> metrics,
    double baselineHeartRate,
  ) {
    if (baselineHeartRate <= 0) {
      return null; // Baseline not established
    }
    
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(Duration(days: HealthConstants.elevatedHeartRateAlertDays - 1));
    
    // Get last N days of metrics with resting heart rate
    final recentMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          final cutoffDate = DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day);
          return !metricDate.isBefore(cutoffDate) && m.restingHeartRate != null;
        })
        .toList();
    
    if (recentMetrics.length < HealthConstants.elevatedHeartRateAlertDays) {
      return null; // Insufficient data
    }
    
    // Sort by date to ensure consecutive days
    recentMetrics.sort((a, b) => a.date.compareTo(b.date));
    
    // Check if we have consecutive days with elevated heart rate
    final consecutiveDays = _getConsecutiveDays(
      recentMetrics,
      HealthConstants.elevatedHeartRateAlertDays,
    );
    
    if (consecutiveDays.length >= HealthConstants.elevatedHeartRateAlertDays) {
      // Check if all consecutive days have heart rate > baseline + threshold
      final allElevated = consecutiveDays.every(
        (m) => m.restingHeartRate! > (baselineHeartRate + HealthConstants.elevatedHeartRateThresholdBpm),
      );
      
      if (allElevated) {
        // Calculate current average
        final currentAvg = consecutiveDays
            .map((m) => m.restingHeartRate!.toDouble())
            .reduce((a, b) => a + b) /
            consecutiveDays.length;
        final increase = currentAvg - baselineHeartRate;
        
        return SafetyAlert(
          type: AlertType.safety,
          title: 'Elevated Heart Rate from Baseline',
          message: _getAlertMessage(baselineHeartRate, currentAvg, increase),
          severity: AlertSeverity.high,
          requiresAcknowledgment: true,
          cannotDismiss: true,
          triggeredAt: DateTime.now(),
        );
      }
    }
    
    return null;
  }

  /// Get consecutive days from recent metrics
  /// 
  /// Returns list of metrics representing consecutive days ending today.
  static List<HealthMetric> _getConsecutiveDays(
    List<HealthMetric> metrics,
    int requiredDays,
  ) {
    if (metrics.isEmpty) return [];
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Group metrics by date
    final metricsByDate = <DateTime, HealthMetric>{};
    for (final metric in metrics) {
      final dateOnly = DateTime(metric.date.year, metric.date.month, metric.date.day);
      metricsByDate[dateOnly] = metric;
    }
    
    // Check for consecutive days ending today
    final consecutiveDays = <HealthMetric>[];
    for (int i = 0; i < requiredDays; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final metric = metricsByDate[checkDate];
      if (metric != null) {
        consecutiveDays.insert(0, metric); // Insert at beginning to maintain order
      } else {
        return []; // Gap found, not consecutive
      }
    }
    
    return consecutiveDays;
  }

  /// Get alert message
  static String _getAlertMessage(double baseline, double current, double increase) {
    return '''⚠️ Safety Alert: Elevated Heart Rate from Baseline

Your resting heart rate has increased by more than ${HealthConstants.elevatedHeartRateThresholdBpm} BPM from your 
baseline for ${HealthConstants.elevatedHeartRateAlertDays} consecutive days.

Your baseline: ${baseline.toStringAsFixed(1)} BPM
Current average: ${current.toStringAsFixed(1)} BPM
Increase: ${increase.toStringAsFixed(1)} BPM

This may indicate:
- Medication side effects
- Dehydration
- Stress or illness
- Need to adjust exercise intensity

Please consult your healthcare provider if this persists or if you 
experience other symptoms.''';
  }
}


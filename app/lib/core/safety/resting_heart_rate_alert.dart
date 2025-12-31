import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/safety/safety_alert.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Resting heart rate alert check
/// 
/// Checks if resting heart rate is above threshold for consecutive days.
/// Alert triggered if heart rate > 100 BPM for 3 consecutive days.
class RestingHeartRateAlert {
  /// Check for resting heart rate alert
  /// 
  /// Returns [SafetyAlert] if condition is met, null otherwise.
  static SafetyAlert? check(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(Duration(days: HealthConstants.restingHeartRateAlertDays - 1));
    
    // Get last N days of metrics with resting heart rate
    final recentMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          final cutoffDate = DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day);
          return !metricDate.isBefore(cutoffDate) && m.restingHeartRate != null;
        })
        .toList();
    
    if (recentMetrics.length < HealthConstants.restingHeartRateAlertDays) {
      return null; // Insufficient data
    }
    
    // Sort by date to ensure consecutive days
    recentMetrics.sort((a, b) => a.date.compareTo(b.date));
    
    // Check if we have consecutive days with elevated heart rate
    final consecutiveDays = _getConsecutiveDays(
      recentMetrics,
      HealthConstants.restingHeartRateAlertDays,
    );
    
    if (consecutiveDays.length >= HealthConstants.restingHeartRateAlertDays) {
      // Check if all consecutive days have heart rate > threshold
      final allElevated = consecutiveDays.every(
        (m) => m.restingHeartRate! > HealthConstants.restingHeartRateAlertThreshold,
      );
      
      if (allElevated) {
        return SafetyAlert(
          type: AlertType.safety,
          title: 'Elevated Resting Heart Rate',
          message: _getAlertMessage(),
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
  static String _getAlertMessage() {
    return '''⚠️ Safety Alert: Elevated Resting Heart Rate

Your resting heart rate has been above ${HealthConstants.restingHeartRateAlertThreshold} BPM for ${HealthConstants.restingHeartRateAlertDays} consecutive days. 
This may indicate:
- Dehydration
- Stress or anxiety
- Medication side effects
- Underlying health condition

Please consult your healthcare provider if this persists or if you 
experience other symptoms such as chest pain, dizziness, or shortness of breath.''';
  }
}


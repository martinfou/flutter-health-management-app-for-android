import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/safety/safety_alert.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Poor sleep quality alert check
/// 
/// Checks if sleep quality is below threshold for consecutive days.
/// Alert triggered if sleep quality < 4/10 for 5 consecutive days.
class PoorSleepAlert {
  /// Check for poor sleep alert
  /// 
  /// Returns [SafetyAlert] if condition is met, null otherwise.
  static SafetyAlert? check(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(Duration(days: HealthConstants.poorSleepQualityAlertDays - 1));
    
    // Get last N days of metrics with sleep quality
    final recentMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          final cutoffDate = DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day);
          return !metricDate.isBefore(cutoffDate) && m.sleepQuality != null;
        })
        .toList();
    
    if (recentMetrics.length < HealthConstants.poorSleepQualityAlertDays) {
      return null; // Insufficient data
    }
    
    // Sort by date to ensure consecutive days
    recentMetrics.sort((a, b) => a.date.compareTo(b.date));
    
    // Check if we have consecutive days with poor sleep
    final consecutiveDays = _getConsecutiveDays(
      recentMetrics,
      HealthConstants.poorSleepQualityAlertDays,
    );
    
    if (consecutiveDays.length >= HealthConstants.poorSleepQualityAlertDays) {
      // Check if all consecutive days have sleep quality < threshold
      final allPoor = consecutiveDays.every(
        (m) => m.sleepQuality! < HealthConstants.poorSleepQualityThreshold,
      );
      
      if (allPoor) {
        return SafetyAlert(
          type: AlertType.warning,
          title: 'Poor Sleep Quality',
          message: _getAlertMessage(),
          severity: AlertSeverity.medium,
          requiresAcknowledgment: true,
          cannotDismiss: false,
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
    return '''⚠️ Warning: Poor Sleep Quality

Your sleep quality has been below ${HealthConstants.poorSleepQualityThreshold}/10 for ${HealthConstants.poorSleepQualityAlertDays} consecutive days. 
Poor sleep can affect:
- Weight loss progress
- Energy levels
- Medication effectiveness
- Overall health

Consider:
- Reviewing your sleep hygiene
- Adjusting medication timing (consult healthcare provider)
- Managing stress and anxiety
- Consulting your healthcare provider if sleep issues persist''';
  }
}


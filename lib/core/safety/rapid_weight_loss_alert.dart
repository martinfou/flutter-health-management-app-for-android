import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/safety/safety_alert.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Rapid weight loss alert check
/// 
/// Checks if weight loss exceeds threshold for consecutive weeks.
/// Alert triggered if weight loss > 1.8 kg/week for 2 consecutive weeks.
class RapidWeightLossAlert {
  /// Check for rapid weight loss alert
  /// 
  /// Returns [SafetyAlert] if condition is met, null otherwise.
  static SafetyAlert? check(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(Duration(days: 13)); // 14 days total
    
    // Get metrics from last 2 weeks with weight data
    final recentMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          final cutoffDate = DateTime(twoWeeksAgo.year, twoWeeksAgo.month, twoWeeksAgo.day);
          return !metricDate.isBefore(cutoffDate) && m.weight != null;
        })
        .toList();
    
    if (recentMetrics.length < 7) {
      return null; // Insufficient data (need at least some data in each week)
    }
    
    // Sort by date
    recentMetrics.sort((a, b) => a.date.compareTo(b.date));
    
    // Calculate average weight for week 1 (days 8-14 ago)
    final week1Start = now.subtract(Duration(days: 14));
    final week1End = now.subtract(Duration(days: 7));
    final week1Metrics = recentMetrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          final startDate = DateTime(week1Start.year, week1Start.month, week1Start.day);
          final endDate = DateTime(week1End.year, week1End.month, week1End.day);
          return !metricDate.isBefore(startDate) && metricDate.isBefore(endDate);
        })
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
    
    // Calculate average weight for week 2 (last 7 days)
    final week2Start = now.subtract(Duration(days: 7));
    final week2Metrics = recentMetrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          final startDate = DateTime(week2Start.year, week2Start.month, week2Start.day);
          return !metricDate.isBefore(startDate);
        })
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
    
    if (week1Metrics.isEmpty || week2Metrics.isEmpty) {
      return null; // Insufficient data for either week
    }
    
    // Calculate average weight for each week
    final week1Avg = week1Metrics.reduce((a, b) => a + b) / week1Metrics.length;
    final week2Avg = week2Metrics.reduce((a, b) => a + b) / week2Metrics.length;
    
    // Calculate weight loss per week
    final weightLoss = week1Avg - week2Avg;
    final weeklyLoss = weightLoss / HealthConstants.rapidWeightLossAlertWeeks;
    
    if (weeklyLoss > HealthConstants.rapidWeightLossThresholdKg) {
      return SafetyAlert(
        type: AlertType.safety,
        title: 'Rapid Weight Loss',
        message: _getAlertMessage(weeklyLoss),
        severity: AlertSeverity.high,
        requiresAcknowledgment: true,
        cannotDismiss: true,
        triggeredAt: DateTime.now(),
      );
    }
    
    return null;
  }

  /// Get alert message
  static String _getAlertMessage(double weeklyLoss) {
    final lossLbs = weeklyLoss * 2.20462; // Convert kg to lbs
    return '''⚠️ Safety Alert: Rapid Weight Loss

You've lost more than ${HealthConstants.rapidWeightLossThresholdKg} kg (${HealthConstants.rapidWeightLossThresholdLbs} lbs) per week for ${HealthConstants.rapidWeightLossAlertWeeks} consecutive weeks. 
Your average weekly loss: ${weeklyLoss.toStringAsFixed(1)} kg (${lossLbs.toStringAsFixed(1)} lbs)

Rapid weight loss can be unsafe and may indicate:
- Inadequate nutrition
- Muscle loss
- Dehydration
- Underlying health condition

Sustainable weight loss is typically 0.5-1 kg (1-2 lbs) per week. 
Please consult your healthcare provider to ensure your weight loss 
plan is safe and appropriate for your health needs.''';
  }
}


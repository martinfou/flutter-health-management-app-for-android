// Packages
import 'package:riverpod/riverpod.dart';

// Project
import 'package:health_app/core/safety/safety_alert.dart';
import 'package:health_app/core/safety/resting_heart_rate_alert.dart';
import 'package:health_app/core/safety/rapid_weight_loss_alert.dart';
import 'package:health_app/core/safety/poor_sleep_alert.dart';
import 'package:health_app/core/safety/elevated_heart_rate_alert.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Provider for active safety alerts
/// 
/// Checks all alert types and returns list of active alerts.
final activeSafetyAlertsProvider = FutureProvider<List<SafetyAlert>>((ref) async {
  final metricsAsync = await ref.read(healthMetricsProvider.future);
  
  final alerts = <SafetyAlert>[];
  
  // Check resting heart rate alert
  final restingHeartRateAlert = RestingHeartRateAlert.check(metricsAsync);
  if (restingHeartRateAlert != null) {
    alerts.add(restingHeartRateAlert);
  }
  
  // Check rapid weight loss alert
  final rapidWeightLossAlert = RapidWeightLossAlert.check(metricsAsync);
  if (rapidWeightLossAlert != null) {
    alerts.add(rapidWeightLossAlert);
  }
  
  // Check poor sleep alert
  final poorSleepAlert = PoorSleepAlert.check(metricsAsync);
  if (poorSleepAlert != null) {
    alerts.add(poorSleepAlert);
  }
  
  // Check elevated heart rate alert (requires baseline calculation)
  // For MVP, we'll calculate a simple baseline from first 7 days
  final baselineHeartRate = _calculateBaselineHeartRate(metricsAsync);
  if (baselineHeartRate > 0) {
    final elevatedHeartRateAlert = ElevatedHeartRateAlert.check(
      metricsAsync,
      baselineHeartRate,
    );
    if (elevatedHeartRateAlert != null) {
      alerts.add(elevatedHeartRateAlert);
    }
  }
  
  return alerts;
});

/// Calculate baseline heart rate from first 7 days of metrics
double _calculateBaselineHeartRate(List<HealthMetric> metrics) {
  if (metrics.isEmpty) return 0.0;
  
  // Sort by date to get first metrics
  final sortedMetrics = List<HealthMetric>.from(metrics)
    ..sort((a, b) => a.date.compareTo(b.date));
  
  // Get first 7 days with heart rate data
  final firstSevenDays = <HealthMetric>[];
  final seenDates = <DateTime>{};
  
  for (final metric in sortedMetrics) {
    if (metric.restingHeartRate == null) continue;
    
    final dateOnly = DateTime(
      metric.date.year,
      metric.date.month,
      metric.date.day,
    );
    
    if (!seenDates.contains(dateOnly)) {
      seenDates.add(dateOnly);
      firstSevenDays.add(metric);
      
      if (firstSevenDays.length >= 7) break;
    }
  }
  
  if (firstSevenDays.isEmpty) return 0.0;
  
  // Calculate average
  final sum = firstSevenDays
      .map((m) => m.restingHeartRate!)
      .reduce((a, b) => a + b);
  return sum / firstSevenDays.length;
}

/// Provider for acknowledged alerts (stored by alert title for simplicity)
/// 
/// In a production app, this would be persisted to Hive.
final acknowledgedAlertsProvider = StateProvider<Set<String>>((ref) => <String>{});


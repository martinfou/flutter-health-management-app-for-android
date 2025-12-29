# Clinical Safety Protocols

## Overview

This document defines clinical safety protocols, alert systems, and safety thresholds for the Flutter Health Management App for Android. These protocols ensure user safety by detecting concerning health metrics and providing appropriate guidance.

**Reference**: Based on requirements in `artifacts/requirements.md` and health domain specifications in `artifacts/phase-1-foundations/health-domain-specifications.md`.

## Safety Alert System

### Alert Types

1. **Safety Alerts**: Critical health concerns requiring immediate attention
2. **Warning Alerts**: Health concerns requiring monitoring
3. **Information Alerts**: Helpful health information

### Alert Display Requirements

- **Prominent Display**: Alert must be clearly visible on relevant screens
- **Persistent**: Alert remains visible until acknowledged or condition resolves
- **Actionable**: Alert includes guidance on next steps
- **Non-Dismissible**: Safety alerts cannot be permanently dismissed (only acknowledged)
- **Reappearance**: Alert reappears if condition persists or recurs

## Safety Alert Thresholds

### 1. Resting Heart Rate Alert

**Condition**: Resting heart rate > 100 BPM (tachycardia)

**Duration**: 3 consecutive days

**Threshold Details**:
- **Value**: > 100 beats per minute
- **Consecutive Days**: 3 days in a row
- **Measurement**: Resting heart rate (not active/exercise heart rate)

**Alert Message**:
```
⚠️ Safety Alert: Elevated Resting Heart Rate

Your resting heart rate has been above 100 BPM for 3 consecutive days. 
This may indicate:
- Dehydration
- Stress or anxiety
- Medication side effects
- Underlying health condition

Please consult your healthcare provider if this persists or if you 
experience other symptoms such as chest pain, dizziness, or shortness of breath.
```

**Implementation**:
```dart
class RestingHeartRateAlert {
  static SafetyAlert? check(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(Duration(days: 2));
    
    // Get last 3 days of metrics with resting heart rate
    final recentMetrics = metrics
        .where((m) => 
            !m.date.isBefore(threeDaysAgo) &&
            m.restingHeartRate != null)
        .toList();
    
    if (recentMetrics.length < 3) {
      return null; // Insufficient data
    }
    
    // Check if all 3 days have heart rate > 100 BPM
    final allElevated = recentMetrics.every((m) => m.restingHeartRate! > 100);
    
    if (allElevated) {
      return SafetyAlert(
        type: AlertType.safety,
        title: 'Elevated Resting Heart Rate',
        message: _getAlertMessage(),
        severity: AlertSeverity.high,
        requiresAcknowledgment: true,
        cannotDismiss: true,
      );
    }
    
    return null;
  }
}
```

### 2. Rapid Weight Loss Alert

**Condition**: Weight loss > 4 lbs/week (1.8 kg/week)

**Duration**: 2 consecutive weeks

**Threshold Details**:
- **Rate**: > 1.8 kg/week (4 lbs/week)
- **Consecutive Weeks**: 2 weeks in a row
- **Calculation**: Compare average weight of week 1 vs week 2

**Alert Message**:
```
⚠️ Safety Alert: Rapid Weight Loss

You've lost more than 1.8 kg (4 lbs) per week for 2 consecutive weeks. 
Rapid weight loss can be unsafe and may indicate:
- Inadequate nutrition
- Muscle loss
- Dehydration
- Underlying health condition

Sustainable weight loss is typically 0.5-1 kg (1-2 lbs) per week. 
Please consult your healthcare provider to ensure your weight loss 
plan is safe and appropriate for your health needs.
```

**Implementation**:
```dart
class RapidWeightLossAlert {
  static SafetyAlert? check(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(Duration(days: 13));
    
    // Get metrics from last 2 weeks
    final recentMetrics = metrics
        .where((m) => !m.date.isBefore(twoWeeksAgo))
        .where((m) => m.weight != null)
        .toList();
    
    if (recentMetrics.length < 7) {
      return null; // Insufficient data
    }
    
    // Calculate average weight for week 1 (days 8-14 ago)
    final week1Metrics = recentMetrics
        .where((m) => 
            m.date.isAfter(now.subtract(Duration(days: 14))) &&
            m.date.isBefore(now.subtract(Duration(days: 7))))
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
    
    // Calculate average weight for week 2 (last 7 days)
    final week2Metrics = recentMetrics
        .where((m) => !m.date.isBefore(now.subtract(Duration(days: 7))))
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
    
    if (week1Metrics.isEmpty || week2Metrics.isEmpty) {
      return null;
    }
    
    final week1Avg = week1Metrics.reduce((a, b) => a + b) / week1Metrics.length;
    final week2Avg = week2Metrics.reduce((a, b) => a + b) / week2Metrics.length;
    
    final weightLoss = week1Avg - week2Avg;
    final weeklyLoss = weightLoss / 2; // Average per week
    
    if (weeklyLoss > 1.8) { // 1.8 kg/week threshold
      return SafetyAlert(
        type: AlertType.safety,
        title: 'Rapid Weight Loss',
        message: _getAlertMessage(),
        severity: AlertSeverity.high,
        requiresAcknowledgment: true,
        cannotDismiss: true,
      );
    }
    
    return null;
  }
}
```

### 3. Poor Sleep Alert

**Condition**: Sleep quality < 4/10

**Duration**: 5 consecutive days

**Threshold Details**:
- **Value**: < 4 out of 10
- **Consecutive Days**: 5 days in a row
- **Scale**: 1-10 (1 = very poor, 10 = excellent)

**Alert Message**:
```
⚠️ Warning: Poor Sleep Quality

Your sleep quality has been below 4/10 for 5 consecutive days. 
Poor sleep can affect:
- Weight loss progress
- Energy levels
- Medication effectiveness
- Overall health

Consider:
- Reviewing your sleep hygiene
- Adjusting medication timing (consult healthcare provider)
- Managing stress and anxiety
- Consulting your healthcare provider if sleep issues persist
```

**Implementation**:
```dart
class PoorSleepAlert {
  static SafetyAlert? check(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(Duration(days: 4));
    
    // Get last 5 days of metrics with sleep quality
    final recentMetrics = metrics
        .where((m) => 
            !m.date.isBefore(fiveDaysAgo) &&
            m.sleepQuality != null)
        .toList();
    
    if (recentMetrics.length < 5) {
      return null; // Insufficient data
    }
    
    // Check if all 5 days have sleep quality < 4
    final allPoor = recentMetrics.every((m) => m.sleepQuality! < 4);
    
    if (allPoor) {
      return SafetyAlert(
        type: AlertType.warning,
        title: 'Poor Sleep Quality',
        message: _getAlertMessage(),
        severity: AlertSeverity.medium,
        requiresAcknowledgment: true,
        cannotDismiss: false,
      );
    }
    
    return null;
  }
}
```

### 4. Elevated Heart Rate Alert

**Condition**: Resting heart rate increases by > 20 BPM from baseline

**Duration**: 3 consecutive days

**Baseline Definition**:
- **Initial Baseline**: Average resting heart rate from first 7 days of tracking
- **Recalculation**: Baseline recalculated monthly to account for fitness improvements
- **Usage**: Most recent baseline calculation is used for alert calculations
- **Minimum Data**: At least 7 days of heart rate data required before baseline is established

**Alert Message**:
```
⚠️ Safety Alert: Elevated Heart Rate from Baseline

Your resting heart rate has increased by more than 20 BPM from your 
baseline for 3 consecutive days.

Your baseline: [baseline] BPM
Current average: [current] BPM
Increase: [increase] BPM

This may indicate:
- Medication side effects
- Dehydration
- Stress or illness
- Need to adjust exercise intensity

Please consult your healthcare provider if this persists or if you 
experience other symptoms.
```

**Implementation**:
```dart
class ElevatedHeartRateAlert {
  static SafetyAlert? check(
    List<HealthMetric> metrics,
    double baselineHeartRate,
  ) {
    if (baselineHeartRate <= 0) {
      return null; // Baseline not established
    }
    
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(Duration(days: 2));
    
    // Get last 3 days of metrics with resting heart rate
    final recentMetrics = metrics
        .where((m) => 
            !m.date.isBefore(threeDaysAgo) &&
            m.restingHeartRate != null)
        .toList();
    
    if (recentMetrics.length < 3) {
      return null; // Insufficient data
    }
    
    // Calculate average heart rate for last 3 days
    final heartRates = recentMetrics
        .map((m) => m.restingHeartRate!)
        .toList();
    final currentAvg = heartRates.reduce((a, b) => a + b) / heartRates.length;
    
    // Check if increase > 20 BPM from baseline
    final increase = currentAvg - baselineHeartRate;
    
    if (increase > 20) {
      return SafetyAlert(
        type: AlertType.safety,
        title: 'Elevated Heart Rate from Baseline',
        message: _getAlertMessage(baselineHeartRate, currentAvg, increase),
        severity: AlertSeverity.high,
        requiresAcknowledgment: true,
        cannotDismiss: true,
      );
    }
    
    return null;
  }
  
  static double calculateBaseline(List<HealthMetric> metrics) {
    // Get first 7 days of heart rate data
    final sortedMetrics = metrics
        .where((m) => m.restingHeartRate != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    if (sortedMetrics.length < 7) {
      return 0; // Insufficient data for baseline
    }
    
    // Get first 7 days
    final first7Days = sortedMetrics.take(7).toList();
    final heartRates = first7Days
        .map((m) => m.restingHeartRate!)
        .toList();
    
    return heartRates.reduce((a, b) => a + b) / heartRates.length;
  }
  
  static double recalculateMonthlyBaseline(
    List<HealthMetric> metrics,
    DateTime monthStart,
  ) {
    final monthEnd = monthStart.add(Duration(days: 30));
    
    // Get all heart rate data from the month
    final monthMetrics = metrics
        .where((m) => 
            !m.date.isBefore(monthStart) &&
            m.date.isBefore(monthEnd) &&
            m.restingHeartRate != null)
        .toList();
    
    if (monthMetrics.isEmpty) {
      return 0; // No data for this month
    }
    
    final heartRates = monthMetrics
        .map((m) => m.restingHeartRate!)
        .toList();
    
    return heartRates.reduce((a, b) => a + b) / heartRates.length;
  }
}
```

## Baseline Calculation

### Resting Heart Rate Baseline

**Initial Calculation**:
1. Collect resting heart rate data for first 7 days
2. Calculate average: sum(heart rates) / count
3. Store as baseline
4. Use for elevated heart rate alert calculations

**Monthly Recalculation**:
1. At start of each month, recalculate baseline using previous month's data
2. Update stored baseline value
3. Use updated baseline for alert calculations
4. Maintain history of baseline changes for tracking fitness improvements

**Implementation**:
```dart
class BaselineCalculator {
  static double? calculateInitialBaseline(List<HealthMetric> metrics) {
    final sortedMetrics = metrics
        .where((m) => m.restingHeartRate != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    if (sortedMetrics.length < 7) {
      return null; // Insufficient data
    }
    
    // Get first 7 days
    final first7Days = sortedMetrics.take(7).toList();
    final heartRates = first7Days
        .map((m) => m.restingHeartRate!)
        .toList();
    
    return heartRates.reduce((a, b) => a + b) / heartRates.length;
  }
  
  static double? recalculateMonthlyBaseline(
    List<HealthMetric> metrics,
    DateTime monthStart,
  ) {
    final monthEnd = monthStart.add(Duration(days: 30));
    
    final monthMetrics = metrics
        .where((m) => 
            !m.date.isBefore(monthStart) &&
            m.date.isBefore(monthEnd) &&
            m.restingHeartRate != null)
        .toList();
    
    if (monthMetrics.isEmpty) {
      return null;
    }
    
    final heartRates = monthMetrics
        .map((m) => m.restingHeartRate!)
        .toList();
    
    return heartRates.reduce((a, b) => a + b) / heartRates.length;
  }
}
```

## Pause Protocol

### When to Pause

**Situations Requiring Pause**:
1. **Safety Alerts**: When any safety alert is triggered and persists
2. **Severe Side Effects**: Severe medication side effects
3. **Illness**: Acute illness or infection
4. **Healthcare Provider Recommendation**: When healthcare provider recommends pausing
5. **Rapid Weight Loss**: When rapid weight loss alert is triggered

### Pause Protocol Steps

1. **Acknowledge Alert**: User acknowledges safety alert
2. **Show Pause Guidance**: Display pause protocol guidance
3. **Consult Healthcare Provider**: Recommend consulting healthcare provider
4. **Temporary Pause**: Option to temporarily pause tracking (not delete data)
5. **Resume Guidance**: Provide guidance on when to resume

**Pause Guidance Message**:
```
⏸️ Pause Protocol

Based on your health metrics, we recommend pausing your current 
weight loss plan and consulting your healthcare provider.

This does NOT mean you've failed. Your health and safety are the 
top priority.

Next Steps:
1. Consult your healthcare provider
2. Review your current plan with them
3. Adjust plan as recommended
4. Resume tracking when ready

Your data will be saved and you can resume tracking at any time.
```

## Alert Management

### Alert Acknowledgment

- **Safety Alerts**: Must be acknowledged, cannot be permanently dismissed
- **Warning Alerts**: Can be acknowledged and dismissed, but reappear if condition persists
- **Information Alerts**: Can be dismissed permanently

### Alert Persistence

- **Safety Alerts**: Remain visible until condition resolves or user acknowledges
- **Reappearance**: Alerts reappear if condition recurs after resolution
- **History**: Maintain alert history for healthcare provider review

### Alert Escalation

- **First Occurrence**: Show alert with guidance
- **Persistent**: If condition persists beyond threshold duration + 2 days, show escalated message
- **Severe**: If multiple safety alerts occur simultaneously, show urgent guidance

## Data Privacy and Healthcare Provider Sharing

### Export for Healthcare Provider

- **Format**: PDF or JSON export of health metrics and alerts
- **Content**: All health metrics, medication logs, side effects, safety alerts
- **Privacy**: User controls what to share
- **Timeline**: Export data for specific date ranges

### Alert Reporting

- **Summary**: Generate alert summary report
- **Timeline**: Show alert history with dates and resolutions
- **Context**: Include relevant health metrics around alert time

## Implementation Notes

### Alert Checking Frequency

- **Real-time**: Check alerts when new health metric is entered
- **Daily**: Run daily check for all active alerts
- **Background**: Background task checks alerts periodically

### Alert Storage

- Store alert history in local database
- Track alert acknowledgment status
- Maintain alert resolution timeline

### Performance Considerations

- Efficient alert checking algorithms
- Cache baseline calculations
- Optimize date range queries

## References

- **Requirements**: `artifacts/requirements.md` - Clinical safety rules and thresholds
- **Health Domain**: `artifacts/phase-1-foundations/health-domain-specifications.md` - Health metric tracking
- **Data Models**: `artifacts/phase-1-foundations/data-models.md` - HealthMetric entity

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Clinical Safety Protocols Complete


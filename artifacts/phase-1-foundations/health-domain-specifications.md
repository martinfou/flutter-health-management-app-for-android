# Health Domain Specifications

## Overview

This document defines health domain feature specifications, health metric tracking logic, calculations, and algorithms for the Flutter Health Management App for Android. These specifications translate health management strategies into actionable app features.

**Reference**: Based on requirements in `artifacts/requirements.md` and clinical safety protocols in `artifacts/phase-1-foundations/clinical-safety-protocols.md`.

## Health Metric Tracking Logic

### 7-Day Moving Average Calculation

**Purpose**: Calculate 7-day moving average of weight to smooth out daily fluctuations and show meaningful trends.

**Algorithm**:
```
1. Get all weight entries for the last 7 days (inclusive of today)
2. Filter entries where weight is not null
3. If less than 7 entries exist, return null (insufficient data)
4. Calculate average: sum(weights) / count(weights)
5. Return average rounded to 1 decimal place
```

**Implementation**:
```dart
class MovingAverageCalculator {
  static double? calculate7DayAverage(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 6)); // Inclusive of today
    
    // Filter to only include metrics from the last 7 days with weight data
    final recentMetrics = metrics
        .where((m) => 
            !m.date.isBefore(sevenDaysAgo) && 
            m.date.isBefore(now.add(Duration(days: 1))) &&
            m.weight != null)
        .toList();
    
    if (recentMetrics.length < 7) {
      return null; // Insufficient data
    }
    
    final weights = recentMetrics.map((m) => m.weight!).toList();
    final sum = weights.fold(0.0, (a, b) => a + b);
    final average = sum / weights.length;
    
    return double.parse(average.toStringAsFixed(1));
  }
}
```

**Display Rules**:
- Show "Insufficient data" if less than 7 days of weight entries
- Display average with 1 decimal place (e.g., "75.2 kg")
- Update automatically when new weight entry is added
- Show trend indicator: ↑ (increasing), ↓ (decreasing), → (stable)

### Plateau Detection Algorithm

**Purpose**: Automatically identify weight loss plateaus to help users understand when progress has stalled.

**Definition**: A plateau occurs when:
1. Weight is unchanged (within ±0.2 kg tolerance) for 3 consecutive weeks (21 days)
2. AND body measurements (waist, hips) are unchanged (within ±1 cm tolerance) for the same period

**Algorithm**:
```
1. Get all weight entries for the last 21 days
2. Group by week (7-day periods)
3. Calculate average weight for each week
4. Check if all 3 weekly averages are within ±0.2 kg
5. If weight plateau detected:
   a. Get body measurements for the same period
   b. Check if waist and hips measurements are unchanged (±1 cm)
6. If both conditions met: Trigger plateau alert
```

**Implementation**:
```dart
class PlateauDetector {
  static PlateauResult detectPlateau(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final twentyOneDaysAgo = now.subtract(Duration(days: 20));
    
    // Get metrics from last 21 days
    final recentMetrics = metrics
        .where((m) => !m.date.isBefore(twentyOneDaysAgo))
        .where((m) => m.weight != null)
        .toList();
    
    if (recentMetrics.length < 7) {
      return PlateauResult.noPlateau('Insufficient data');
    }
    
    // Group by week
    final week1 = recentMetrics
        .where((m) => m.date.isAfter(now.subtract(Duration(days: 7))))
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
    
    final week2 = recentMetrics
        .where((m) => 
            m.date.isAfter(now.subtract(Duration(days: 14))) &&
            m.date.isBefore(now.subtract(Duration(days: 7))))
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
    
    final week3 = recentMetrics
        .where((m) => 
            m.date.isAfter(now.subtract(Duration(days: 21))) &&
            m.date.isBefore(now.subtract(Duration(days: 14))))
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
    
    if (week1.isEmpty || week2.isEmpty || week3.isEmpty) {
      return PlateauResult.noPlateau('Insufficient weekly data');
    }
    
    // Calculate weekly averages
    final avg1 = week1.reduce((a, b) => a + b) / week1.length;
    final avg2 = week2.reduce((a, b) => a + b) / week2.length;
    final avg3 = week3.reduce((a, b) => a + b) / week3.length;
    
    // Check if all averages are within ±0.2 kg
    final tolerance = 0.2;
    final maxAvg = [avg1, avg2, avg3].reduce((a, b) => a > b ? a : b);
    final minAvg = [avg1, avg2, avg3].reduce((a, b) => a < b ? a : b);
    
    if (maxAvg - minAvg > tolerance) {
      return PlateauResult.noPlateau('Weight is changing');
    }
    
    // Check body measurements
    final measurements = recentMetrics
        .where((m) => m.bodyMeasurements != null)
        .map((m) => m.bodyMeasurements!)
        .toList();
    
    if (measurements.isNotEmpty) {
      final waistValues = measurements
          .where((m) => m.containsKey('waist'))
          .map((m) => m['waist']!)
          .toList();
      
      final hipsValues = measurements
          .where((m) => m.containsKey('hips'))
          .map((m) => m['hips']!)
          .toList();
      
      if (waistValues.isNotEmpty && hipsValues.isNotEmpty) {
        final waistMax = waistValues.reduce((a, b) => a > b ? a : b);
        final waistMin = waistValues.reduce((a, b) => a < b ? a : b);
        final hipsMax = hipsValues.reduce((a, b) => a > b ? a : b);
        final hipsMin = hipsValues.reduce((a, b) => a < b ? a : b);
        
        final measurementTolerance = 1.0; // cm
        
        if (waistMax - waistMin <= measurementTolerance &&
            hipsMax - hipsMin <= measurementTolerance) {
          return PlateauResult.plateauDetected(
            'Weight and measurements unchanged for 3 weeks',
            avg1,
          );
        }
      }
    }
    
    return PlateauResult.noPlateau('Measurements are changing');
  }
}

class PlateauResult {
  final bool isPlateau;
  final String message;
  final double? averageWeight;
  
  PlateauResult._(this.isPlateau, this.message, this.averageWeight);
  
  factory PlateauResult.plateauDetected(String message, double avgWeight) {
    return PlateauResult._(true, message, avgWeight);
  }
  
  factory PlateauResult.noPlateau(String reason) {
    return PlateauResult._(false, reason, null);
  }
}
```

**Alert Display**:
- Show plateau alert when detected
- Message: "Your weight and measurements have been unchanged for 3 weeks. This may indicate a plateau. Consider adjusting your nutrition or exercise plan."
- Provide suggestions: Review nutrition, increase activity, consult healthcare provider

## KPI Tracking

### Key Performance Indicators

**Weight Loss Rate**:
- Calculate: (Starting weight - Current weight) / Days tracked
- Display: kg/week or lbs/week
- Target: 0.5-1 kg/week (1-2 lbs/week) for sustainable loss

**Waist-to-Hip Ratio**:
- Calculate: Waist measurement / Hip measurement
- Display: Ratio with interpretation
- Health ranges:
  - Men: < 0.90 (healthy), 0.90-0.99 (moderate risk), ≥ 1.0 (high risk)
  - Women: < 0.80 (healthy), 0.80-0.84 (moderate risk), ≥ 0.85 (high risk)

**Body Mass Index (BMI)**:
- Calculate: Weight (kg) / (Height (m))²
- Display: BMI value with category
- Categories:
  - Underweight: < 18.5
  - Normal: 18.5-24.9
  - Overweight: 25-29.9
  - Obese: ≥ 30

**Resting Heart Rate Trend**:
- Track: Average resting heart rate over time
- Display: Trend chart showing improvement
- Interpretation: Lower resting heart rate indicates improved fitness

### Non-Scale Victories (NSVs)

**Purpose**: Track progress beyond weight to maintain motivation.

**NSV Categories**:
1. **Clothing Fit**: Track when clothes fit better
2. **Energy Levels**: Track energy level improvements
3. **Sleep Quality**: Track sleep quality improvements
4. **Strength/Stamina**: Track exercise performance improvements
5. **Appetite Suppression**: Track medication-related appetite changes
6. **Mood**: Track mood improvements
7. **Joint Health**: Track reduction in joint pain
8. **Blood Pressure**: Track blood pressure improvements (if measured)

**Tracking Implementation**:
```dart
class NonScaleVictory {
  final String id;
  final String userId;
  final NSVCategory category;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  
  NonScaleVictory({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.date,
    required this.createdAt,
  });
}

enum NSVCategory {
  clothingFit,
  energyLevel,
  sleepQuality,
  strengthStamina,
  appetiteSuppression,
  mood,
  jointHealth,
  bloodPressure,
  other;
}
```

## Data Interpretation Logic

### Weight Trend Analysis

**Interpretation Rules**:
- **Increasing Trend**: Weight increasing over 7-day period → Review nutrition and exercise
- **Decreasing Trend**: Weight decreasing over 7-day period → Monitor rate (should be 0.5-1 kg/week)
- **Stable Trend**: Weight stable → Check if plateau (3 weeks unchanged)
- **Fluctuating**: Daily variations normal, focus on 7-day average

### Sleep Quality Analysis

**Interpretation**:
- **Excellent (8-10)**: Optimal sleep, maintain current routine
- **Good (6-7)**: Adequate sleep, minor improvements possible
- **Fair (4-5)**: Poor sleep, review sleep hygiene, consider healthcare provider
- **Poor (1-3)**: Very poor sleep, consult healthcare provider

### Energy Level Analysis

**Interpretation**:
- **High (8-10)**: Excellent energy, maintain current routine
- **Moderate (5-7)**: Adequate energy, monitor for changes
- **Low (1-4)**: Low energy, review nutrition, sleep, medication side effects

## Medication Management Workflows

### Medication-Aware Nutrition

**Protein-First Strategy**:
- Prioritize protein intake at each meal
- Target: 35% of calories from protein
- Rationale: Supports medication effectiveness, maintains muscle mass during weight loss

**Volume Management**:
- For medications causing nausea: Smaller, more frequent meals
- For medications affecting appetite: Focus on nutrient-dense foods
- Track side effects and adjust meal timing accordingly

**Implementation**:
```dart
class MedicationAwareNutrition {
  static MealPlan adjustMealPlan(
    MealPlan plan,
    List<Medication> medications,
  ) {
    // Check for medications that affect appetite/nausea
    final hasNauseaSideEffect = medications.any((m) =>
        m.sideEffects.any((se) =>
            se.name.toLowerCase().contains('nausea') &&
            se.isOngoing));
    
    if (hasNauseaSideEffect) {
      // Adjust to smaller, more frequent meals
      return plan.adjustToSmallerMeals();
    }
    
    // Ensure protein-first approach
    return plan.ensureProteinFirst();
  }
}
```

### Medication Reminder System

**Reminder Logic**:
- Generate reminders based on medication schedule
- Send notification at scheduled time
- Track medication logs (taken/not taken)
- Show missed dose alerts

**Implementation**:
```dart
class MedicationReminderGenerator {
  static List<Notification> generateReminders(Medication medication) {
    final reminders = <Notification>[];
    
    if (!medication.reminderEnabled) {
      return reminders;
    }
    
    for (final timeOfDay in medication.times) {
      reminders.add(Notification(
        id: '${medication.id}_${timeOfDay.hour}_${timeOfDay.minute}',
        title: 'Medication Reminder',
        body: 'Time to take ${medication.name} (${medication.dosage})',
        scheduledTime: _calculateNextOccurrence(timeOfDay),
        repeatDaily: medication.frequency == MedicationFrequency.daily,
      ));
    }
    
    return reminders;
  }
}
```

## Behavioral Support Features

### Habit Tracking

**Habit Categories**:
1. **Nutrition Habits**: Log meals, track macros, meal prep
2. **Exercise Habits**: Daily movement, workout completion
3. **Sleep Habits**: Consistent bedtime, sleep duration
4. **Medication Habits**: Take medications on time
5. **Self-Care Habits**: Progress photos, journaling

**Tracking Implementation**:
```dart
class Habit {
  final String id;
  final String userId;
  final String name;
  final HabitCategory category;
  final List<DateTime> completedDates;
  final int currentStreak;
  final int longestStreak;
  
  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.completedDates,
    required this.currentStreak,
    required this.longestStreak,
  });
  
  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }
  
  void markCompleted() {
    if (!isCompletedToday()) {
      completedDates.add(DateTime.now());
      // Update streak logic
    }
  }
}

enum HabitCategory {
  nutrition,
  exercise,
  sleep,
  medication,
  selfCare,
  other;
}
```

### Identity-Based Goal Setting

**Purpose**: Shift focus from weight loss to health identity transformation.

**Goal Types**:
1. **Health Identity Goals**: "I am a person who prioritizes health"
2. **Behavior Goals**: "I exercise 3 times per week"
3. **Outcome Goals**: "I lose 20 kg" (supporting, not primary)

**Implementation**:
- Primary focus on identity and behavior goals
- Outcome goals as supporting metrics
- Celebrate identity and behavior achievements
- Track progress toward identity transformation

### Progress Visualization

**Chart Types**:
1. **Weight Trend**: Line chart showing 7-day moving average
2. **Macro Tracking**: Bar chart showing daily macro percentages
3. **Sleep Quality**: Line chart showing sleep quality over time
4. **Energy Levels**: Line chart showing energy trends
5. **Exercise Frequency**: Bar chart showing workout frequency
6. **Habit Streaks**: Visual representation of habit completion

**Display Requirements**:
- Show trends over time (7 days, 30 days, 90 days, 1 year)
- Highlight milestones and achievements
- Show goal progress indicators
- Display NSVs prominently

## Weekly Check-in Format (Post-MVP)

**Purpose**: Interactive reflection and progress review with LLM-powered insights.

**Components**:
1. **Progress Summary**: Weight, measurements, macros, exercise summary
2. **Reflection Questions**: 
   - What went well this week?
   - What challenges did you face?
   - What would you like to improve?
3. **LLM-Powered Insights**: Personalized feedback based on progress
4. **Recommendations**: Actionable suggestions for next week
5. **Celebrations**: Highlight achievements and NSVs

**Implementation** (Post-MVP):
- Generate weekly review using LLM API
- Include personalized insights and recommendations
- Save review to local database
- Allow user to add notes and reflections

## References

- **Requirements**: `artifacts/requirements.md` - Health tracking requirements and calculations
- **Clinical Safety**: `artifacts/phase-1-foundations/clinical-safety-protocols.md` - Safety protocols
- **Data Models**: `artifacts/phase-1-foundations/data-models.md` - Entity definitions

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Health Domain Specifications Complete


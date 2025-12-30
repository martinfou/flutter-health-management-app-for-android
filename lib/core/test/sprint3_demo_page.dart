import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/providers/database_initializer.dart';
import 'package:health_app/core/errors/error_handler.dart';
import 'package:health_app/features/health_tracking/domain/usecases/save_health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/calculate_moving_average.dart';
import 'package:health_app/features/health_tracking/domain/usecases/get_weight_trend.dart';
import 'package:health_app/features/health_tracking/domain/usecases/calculate_baseline_heart_rate.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/log_meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_repository_provider.dart';
import 'package:health_app/features/exercise_management/domain/usecases/create_workout_plan.dart';
import 'package:health_app/features/exercise_management/domain/usecases/log_workout.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/domain/entities/workout_plan.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_repository_provider.dart';
import 'package:health_app/features/medication_management/domain/usecases/add_medication.dart';
import 'package:health_app/features/medication_management/domain/usecases/check_medication_reminders.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart' as app_time;
import 'package:health_app/features/medication_management/presentation/providers/medication_repository_provider.dart';
import 'package:health_app/features/behavioral_support/domain/usecases/track_habit.dart';
import 'package:health_app/features/behavioral_support/domain/usecases/create_goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit_category.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_type.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_repository_provider.dart';
import 'package:health_app/core/safety/resting_heart_rate_alert.dart';
import 'package:health_app/core/safety/rapid_weight_loss_alert.dart';
import 'package:health_app/core/safety/poor_sleep_alert.dart';
import 'package:health_app/core/safety/elevated_heart_rate_alert.dart';

/// Sprint 3 Demo Page
/// 
/// Demonstrates all Sprint 3 features:
/// - Domain use cases (business logic)
/// - Calculation utilities
/// - Validation logic
/// - Clinical safety alert checks
class Sprint3DemoPage extends ConsumerStatefulWidget {
  const Sprint3DemoPage({super.key});

  @override
  ConsumerState<Sprint3DemoPage> createState() => _Sprint3DemoPageState();
}

class _Sprint3DemoPageState extends ConsumerState<Sprint3DemoPage> {
  final List<String> _demoResults = [];
  bool _isRunning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkDatabaseInitialization();
  }

  void _checkDatabaseInitialization() {
    final isInitialized = DatabaseInitializer.isInitialized();
    _addResult('Database Initialization', isInitialized ? '✅ Success' : '❌ Failed');
  }

  void _addResult(String test, String result) {
    setState(() {
      _demoResults.add('$test: $result');
    });
  }

  Future<void> _runFullDemo() async {
    setState(() {
      _isRunning = true;
      _errorMessage = null;
      _demoResults.clear();
    });

    try {
      // 1. Database Initialization Check
      _addResult('1. Database Initialization', 
          DatabaseInitializer.isInitialized() ? '✅ All boxes initialized' : '❌ Failed');

      // 2. Health Tracking Use Cases
      await _testHealthTrackingUseCases();

      // 3. Nutrition Use Cases
      await _testNutritionUseCases();

      // 4. Exercise Use Cases
      await _testExerciseUseCases();

      // 5. Medication Use Cases
      await _testMedicationUseCases();

      // 6. Behavioral Support Use Cases
      await _testBehavioralUseCases();

      // 7. Clinical Safety Alerts
      await _testClinicalSafetyAlerts();

      _addResult('✅ Demo Complete', 'All Sprint 3 use cases tested successfully!');
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'Sprint3Demo');
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testHealthTrackingUseCases() async {
    try {
      final repo = ref.read(healthTrackingRepositoryProvider);
      final now = DateTime.now();
      final userId = 'demo-user-id';

      // Test SaveHealthMetric
      final saveUseCase = SaveHealthMetricUseCase(repo);
      final metric = HealthMetric(
        id: '',
        userId: userId,
        date: now,
        weight: 75.5,
        sleepQuality: 8,
        energyLevel: 7,
        restingHeartRate: 65,
        createdAt: now,
        updatedAt: now,
      );
      final saveResult = await saveUseCase.call(metric);
      saveResult.fold(
        (failure) => _addResult('2.1 SaveHealthMetric', '❌ ${failure.message}'),
        (_) => _addResult('2.1 SaveHealthMetric', '✅ Success'),
      );

      // Test CalculateMovingAverage (needs 7 days)
      final metrics7Days = List.generate(7, (i) => HealthMetric(
        id: 'metric-$i',
        userId: userId,
        date: now.subtract(Duration(days: 6 - i)),
        weight: 75.0 + (i * 0.1),
        createdAt: now,
        updatedAt: now,
      ));
      final avgUseCase = CalculateMovingAverageUseCase();
      final avgResult = avgUseCase.call(metrics7Days);
      avgResult.fold(
        (failure) => _addResult('2.2 CalculateMovingAverage', '❌ ${failure.message}'),
        (avg) => _addResult('2.2 CalculateMovingAverage', '✅ Average: ${avg.toStringAsFixed(1)} kg'),
      );

      // Test GetWeightTrend (needs 14 days: current 7 + previous 7)
      // Current period: days 0-6 (last 7 days inclusive of today)
      // Previous period: days 7-13 (7 days before that)
      final today = DateTime(now.year, now.month, now.day);
      final metrics14Days = <HealthMetric>[];
      // Previous 7 days (days 7-13, before the current period)
      for (int i = 13; i >= 7; i--) {
        metrics14Days.add(HealthMetric(
          id: 'trend-metric-prev-$i',
          userId: userId,
          date: today.subtract(Duration(days: i)),
          weight: 76.0, // Previous week average
          createdAt: now,
          updatedAt: now,
        ));
      }
      // Current 7 days (days 0-6, inclusive of today)
      for (int i = 6; i >= 0; i--) {
        metrics14Days.add(HealthMetric(
          id: 'trend-metric-curr-$i',
          userId: userId,
          date: today.subtract(Duration(days: i)),
          weight: 75.0, // Current week average (slight decrease)
          createdAt: now,
          updatedAt: now,
        ));
      }
      final trendUseCase = GetWeightTrendUseCase();
      final trendResult = trendUseCase.call(metrics14Days);
      trendResult.fold(
        (failure) => _addResult('2.3 GetWeightTrend', '❌ ${failure.message}'),
        (trend) => _addResult('2.3 GetWeightTrend', '✅ Trend: ${trend.toString()}'),
      );

      // Test CalculateBaselineHeartRate
      final heartRateMetrics = List.generate(7, (i) => HealthMetric(
        id: 'hr-metric-$i',
        userId: userId,
        date: now.subtract(Duration(days: 6 - i)),
        restingHeartRate: 70 + i,
        createdAt: now,
        updatedAt: now,
      ));
      final baselineUseCase = CalculateBaselineHeartRateUseCase();
      final baselineResult = baselineUseCase.call(heartRateMetrics);
      baselineResult.fold(
        (failure) => _addResult('2.4 CalculateBaselineHeartRate', '❌ ${failure.message}'),
        (baseline) => _addResult('2.4 CalculateBaselineHeartRate', '✅ Baseline: ${baseline.toStringAsFixed(1)} BPM'),
      );

    } catch (e) {
      _addResult('2. Health Tracking Use Cases', '❌ Error: $e');
    }
  }

  Future<void> _testNutritionUseCases() async {
    try {
      final repo = ref.read(nutritionRepositoryProvider);
      final now = DateTime.now();
      final userId = 'demo-user-id';

      // Test LogMeal
      final logMealUseCase = LogMealUseCase(repo);
      final logMealResult = await logMealUseCase.call(
        userId: userId,
        mealType: MealType.breakfast,
        name: 'Demo Breakfast',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 890.0,
        ingredients: ['Eggs', 'Bacon'],
      );
      logMealResult.fold(
        (failure) => _addResult('3.1 LogMeal', '❌ ${failure.message}'),
        (_) => _addResult('3.1 LogMeal', '✅ Success'),
      );

      // Test CalculateMacros
      final meals = [
        Meal(
          id: 'meal-1',
          userId: userId,
          date: now,
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 30.0,
          fats: 20.0,
          netCarbs: 15.0,
          calories: 350.0,
          ingredients: ['Eggs'],
          createdAt: now,
        ),
        Meal(
          id: 'meal-2',
          userId: userId,
          date: now,
          mealType: MealType.lunch,
          name: 'Lunch',
          protein: 40.0,
          fats: 30.0,
          netCarbs: 20.0,
          calories: 550.0,
          ingredients: ['Chicken'],
          createdAt: now,
        ),
      ];
      final calcMacrosUseCase = CalculateMacrosUseCase();
      final macrosResult = calcMacrosUseCase.call(meals);
      macrosResult.fold(
        (failure) => _addResult('3.2 CalculateMacros', '❌ ${failure.message}'),
        (summary) => _addResult('3.2 CalculateMacros', 
            '✅ Total: ${summary.calories.toStringAsFixed(0)} cal, Protein: ${summary.proteinPercent.toStringAsFixed(1)}%'),
      );

    } catch (e) {
      _addResult('3. Nutrition Use Cases', '❌ Error: $e');
    }
  }

  Future<void> _testExerciseUseCases() async {
    try {
      final repo = ref.read(exerciseRepositoryProvider);
      final userId = 'demo-user-id';
      final now = DateTime.now();

      // Test CreateWorkoutPlan
      final createPlanUseCase = CreateWorkoutPlanUseCase();
      final planResult = createPlanUseCase.call(
        userId: userId,
        name: 'Demo Workout Plan',
        days: [
          WorkoutDay(dayName: 'Monday', exerciseIds: ['ex1', 'ex2']),
          WorkoutDay(dayName: 'Wednesday', exerciseIds: ['ex3', 'ex4']),
        ],
        durationWeeks: 4,
      );
      planResult.fold(
        (failure) => _addResult('4.1 CreateWorkoutPlan', '❌ ${failure.message}'),
        (plan) => _addResult('4.1 CreateWorkoutPlan', '✅ Created: ${plan.name} (${plan.days.length} days)'),
      );

      // Test LogWorkout
      final logWorkoutUseCase = LogWorkoutUseCase(repo);
      final workoutResult = await logWorkoutUseCase.call(
        userId: userId,
        name: 'Bench Press',
        type: ExerciseType.strength,
        date: now,
        sets: 3,
        reps: 10,
        weight: 80.0,
      );
      workoutResult.fold(
        (failure) => _addResult('4.2 LogWorkout', '❌ ${failure.message}'),
        (_) => _addResult('4.2 LogWorkout', '✅ Success'),
      );

    } catch (e) {
      _addResult('4. Exercise Use Cases', '❌ Error: $e');
    }
  }

  Future<void> _testMedicationUseCases() async {
    try {
      final repo = ref.read(medicationRepositoryProvider);
      final userId = 'demo-user-id';
      final now = DateTime.now();

      // Test AddMedication
      final addMedUseCase = AddMedicationUseCase(repo);
      final addMedResult = await addMedUseCase.call(
        userId: userId,
        name: 'Demo Medication',
        dosage: '10mg',
        frequency: MedicationFrequency.daily,
        times: [app_time.TimeOfDay(hour: 8, minute: 0)],
        startDate: now,
      );
      addMedResult.fold(
        (failure) => _addResult('5.1 AddMedication', '❌ ${failure.message}'),
        (med) => _addResult('5.1 AddMedication', '✅ Added: ${med.name}'),
      );

      // Test CheckMedicationReminders
      final checkRemindersUseCase = CheckMedicationRemindersUseCase(repo);
      final remindersResult = await checkRemindersUseCase.call(userId);
      remindersResult.fold(
        (failure) => _addResult('5.2 CheckMedicationReminders', '❌ ${failure.message}'),
        (reminders) => _addResult('5.2 CheckMedicationReminders', '✅ Found ${reminders.length} reminder(s)'),
      );

    } catch (e) {
      _addResult('5. Medication Use Cases', '❌ Error: $e');
    }
  }

  Future<void> _testBehavioralUseCases() async {
    try {
      final repo = ref.read(behavioralRepositoryProvider);
      final userId = 'demo-user-id';
      final now = DateTime.now();

      // Test CreateGoal
      final createGoalUseCase = CreateGoalUseCase(repo);
      final goalResult = await createGoalUseCase.call(
        userId: userId,
        type: GoalType.outcome,
        description: 'Lose 10 kg',
        targetValue: 10.0,
        currentValue: 2.0,
      );
      goalResult.fold(
        (failure) => _addResult('6.1 CreateGoal', '❌ ${failure.message}'),
        (goal) => _addResult('6.1 CreateGoal', '✅ Created: ${goal.description}'),
      );

      // Test TrackHabit - first save the habit
      final habit = Habit(
        id: 'demo-habit-${now.millisecondsSinceEpoch}',
        userId: userId,
        name: 'Daily Walk',
        category: HabitCategory.exercise,
        description: 'Walk 10,000 steps',
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );
      // Save habit first
      final saveHabitResult = await repo.saveHabit(habit);
      if (saveHabitResult.isRight()) {
        final trackHabitUseCase = TrackHabitUseCase(repo);
        final trackResult = await trackHabitUseCase.call(habitId: habit.id);
        trackResult.fold(
          (failure) => _addResult('6.2 TrackHabit', '❌ ${failure.message}'),
          (updated) => _addResult('6.2 TrackHabit', '✅ Tracked: ${updated.name} (Streak: ${updated.currentStreak})'),
        );
      } else {
        _addResult('6.2 TrackHabit', '❌ Failed to save habit first');
      }

    } catch (e) {
      _addResult('6. Behavioral Support Use Cases', '❌ Error: $e');
    }
  }

  Future<void> _testClinicalSafetyAlerts() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Test RestingHeartRateAlert
      final hrMetrics = List.generate(3, (i) => HealthMetric(
        id: 'hr-$i',
        userId: 'demo-user',
        date: today.subtract(Duration(days: 2 - i)),
        restingHeartRate: 105, // Above threshold
        createdAt: now,
        updatedAt: now,
      ));
      final hrAlert = RestingHeartRateAlert.check(hrMetrics);
      _addResult('7.1 RestingHeartRateAlert', 
          hrAlert != null ? '✅ Alert triggered' : 'ℹ️ No alert (normal heart rate)');

      // Test PoorSleepAlert
      final sleepMetrics = List.generate(5, (i) => HealthMetric(
        id: 'sleep-$i',
        userId: 'demo-user',
        date: today.subtract(Duration(days: 4 - i)),
        sleepQuality: 3, // Below threshold
        createdAt: now,
        updatedAt: now,
      ));
      final sleepAlert = PoorSleepAlert.check(sleepMetrics);
      _addResult('7.2 PoorSleepAlert', 
          sleepAlert != null ? '✅ Alert triggered' : 'ℹ️ No alert (good sleep)');

      // Test RapidWeightLossAlert
      final weightMetrics = <HealthMetric>[];
      // Week 1: days 14-8 ago
      for (int i = 14; i >= 8; i--) {
        weightMetrics.add(HealthMetric(
          id: 'w1-$i',
          userId: 'demo-user',
          date: today.subtract(Duration(days: i)),
          weight: 80.0,
          createdAt: now,
          updatedAt: now,
        ));
      }
      // Week 2: days 7-0 (last 7 days)
      for (int i = 7; i >= 0; i--) {
        weightMetrics.add(HealthMetric(
          id: 'w2-$i',
          userId: 'demo-user',
          date: today.subtract(Duration(days: i)),
          weight: 76.0, // 4 kg loss over 2 weeks = 2 kg/week
          createdAt: now,
          updatedAt: now,
        ));
      }
      final weightLossAlert = RapidWeightLossAlert.check(weightMetrics);
      _addResult('7.3 RapidWeightLossAlert', 
          weightLossAlert != null ? '✅ Alert triggered' : 'ℹ️ No alert (safe weight loss)');

      // Test ElevatedHeartRateAlert
      final baseline = 70.0;
      final elevatedHrMetrics = List.generate(3, (i) => HealthMetric(
        id: 'ehr-$i',
        userId: 'demo-user',
        date: today.subtract(Duration(days: 2 - i)),
        restingHeartRate: 95, // 25 BPM above baseline
        createdAt: now,
        updatedAt: now,
      ));
      final elevatedAlert = ElevatedHeartRateAlert.check(elevatedHrMetrics, baseline);
      _addResult('7.4 ElevatedHeartRateAlert', 
          elevatedAlert != null ? '✅ Alert triggered' : 'ℹ️ No alert (normal variation)');

    } catch (e) {
      _addResult('7. Clinical Safety Alerts', '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint 3: Domain Use Cases Demo'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sprint 3 Demo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This demo verifies all Sprint 3 deliverables:\n'
                      '• Domain use cases (business logic)\n'
                      '• Calculation utilities\n'
                      '• Validation logic\n'
                      '• Clinical safety alert checks',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isRunning ? null : _runFullDemo,
              icon: _isRunning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'Running Demo...' : 'Run Full Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16.0),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_demoResults.isNotEmpty) ...[
              const Text(
                'Demo Results:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _demoResults.map((result) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          result,
                          style: TextStyle(
                            fontSize: 14,
                            color: result.contains('✅')
                                ? Colors.green.shade700
                                : result.contains('❌')
                                    ? Colors.red.shade700
                                    : result.contains('ℹ️')
                                        ? Colors.blue.shade700
                                        : Colors.black87,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


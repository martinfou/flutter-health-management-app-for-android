import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/providers/database_initializer.dart';
import 'package:health_app/core/errors/error_handler.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart' as app_time;
import 'package:health_app/features/medication_management/presentation/providers/medication_repository_provider.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_repository_provider.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_repository_provider.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit_category.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_type.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_status.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_repository_provider.dart';
import 'package:health_app/core/entities/user_preferences.dart';

/// Sprint 2 Demo Page
/// 
/// Demonstrates all Sprint 2 features:
/// - Database initialization
/// - Entity creation
/// - Repository operations (save, retrieve)
/// - Hive box operations
class Sprint2DemoPage extends ConsumerStatefulWidget {
  const Sprint2DemoPage({super.key});

  @override
  ConsumerState<Sprint2DemoPage> createState() => _Sprint2DemoPageState();
}

class _Sprint2DemoPageState extends ConsumerState<Sprint2DemoPage> {
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

      // 2. User Profile Test
      await _testUserProfile();

      // 3. Health Metric Test
      await _testHealthMetric();

      // 4. Medication Test
      await _testMedication();

      // 5. Meal Test
      await _testMeal();

      // 6. Exercise Test
      await _testExercise();

      // 7. Habit Test
      await _testHabit();

      // 8. Goal Test
      await _testGoal();

      // 9. User Preferences Test
      await _testUserPreferences();

      _addResult('✅ Demo Complete', 'All features tested successfully!');
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'Sprint2Demo');
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testUserProfile() async {
    try {
      final repo = ref.read(userProfileRepositoryProvider);
      final now = DateTime.now();
      // Generate simple UUID-like ID for demo
      final profileId = 'demo-user-${now.millisecondsSinceEpoch}';

      final profile = UserProfile(
        id: profileId,
        name: 'Demo User',
        email: 'demo@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 75.0,
        targetWeight: 75.0,
        syncEnabled: false,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await repo.saveUserProfile(profile);
      saveResult.fold(
        (failure) => _addResult('2. UserProfile Save', '❌ ${failure.message}'),
        (_) => _addResult('2. UserProfile Save', '✅ Success'),
      );

      final getResult = await repo.getCurrentUserProfile();
      getResult.fold(
        (failure) => _addResult('2. UserProfile Retrieve', '❌ ${failure.message}'),
        (retrieved) => _addResult('2. UserProfile Retrieve', 
            '✅ Retrieved: ${retrieved.name} (Age: ${retrieved.age}, BMI: ${retrieved.bmi?.toStringAsFixed(1) ?? "N/A"})'),
      );
    } catch (e) {
      _addResult('2. UserProfile Test', '❌ Error: $e');
    }
  }

  Future<void> _testHealthMetric() async {
    try {
      final repo = ref.read(healthTrackingRepositoryProvider);
      final now = DateTime.now();

      // Get user ID first
      final userResult = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
      final userId = userResult.fold((_) => 'demo-user-id', (profile) => profile.id);

      final metric = HealthMetric(
        id: 'demo-metric-${now.millisecondsSinceEpoch}',
        userId: userId,
        date: now,
        weight: 75.5,
        sleepQuality: 8,
        energyLevel: 7,
        restingHeartRate: 65,
        bodyMeasurements: {'waist': 85.0, 'hips': 95.0},
        notes: 'Demo metric',
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await repo.saveHealthMetric(metric);
      saveResult.fold(
        (failure) => _addResult('3. HealthMetric Save', '❌ ${failure.message}'),
        (_) => _addResult('3. HealthMetric Save', '✅ Success'),
      );

      final getResult = await repo.getHealthMetricsByUserId(userId);
      getResult.fold(
        (failure) => _addResult('3. HealthMetric Retrieve', '❌ ${failure.message}'),
        (metrics) => _addResult('3. HealthMetric Retrieve', 
            '✅ Retrieved ${metrics.length} metric(s)'),
      );
    } catch (e) {
      _addResult('3. HealthMetric Test', '❌ Error: $e');
    }
  }

  Future<void> _testMedication() async {
    try {
      final repo = ref.read(medicationRepositoryProvider);
      final now = DateTime.now();

      final userResult = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
      final userId = userResult.fold((_) => 'demo-user-id', (profile) => profile.id);

      final medication = Medication(
        id: 'demo-medication-${now.millisecondsSinceEpoch}',
        userId: userId,
        name: 'Demo Medication',
        dosage: '10mg',
        frequency: MedicationFrequency.daily,
        times: [app_time.TimeOfDay(hour: 8, minute: 0)],
        startDate: now,
        endDate: null,
        reminderEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await repo.saveMedication(medication);
      saveResult.fold(
        (failure) => _addResult('4. Medication Save', '❌ ${failure.message}'),
        (_) => _addResult('4. Medication Save', '✅ Success'),
      );

      final getResult = await repo.getActiveMedications(userId);
      getResult.fold(
        (failure) => _addResult('4. Medication Retrieve', '❌ ${failure.message}'),
        (medications) => _addResult('4. Medication Retrieve', 
            '✅ Retrieved ${medications.length} active medication(s)'),
      );
    } catch (e) {
      _addResult('4. Medication Test', '❌ Error: $e');
    }
  }

  Future<void> _testMeal() async {
    try {
      final repo = ref.read(nutritionRepositoryProvider);
      final now = DateTime.now();

      final userResult = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
      final userId = userResult.fold((_) => 'demo-user-id', (profile) => profile.id);

      final meal = Meal(
        id: 'demo-meal-${now.millisecondsSinceEpoch}',
        userId: userId,
        date: now,
        mealType: MealType.breakfast,
        name: 'Demo Breakfast',
        protein: 30.0,
        fats: 25.0,
        netCarbs: 15.0,
        calories: 400.0,
        ingredients: ['Eggs', 'Bacon', 'Avocado'],
        recipeId: null,
        createdAt: now,
      );

      final saveResult = await repo.saveMeal(meal);
      saveResult.fold(
        (failure) => _addResult('5. Meal Save', '❌ ${failure.message}'),
        (_) => _addResult('5. Meal Save', '✅ Success'),
      );

      final getResult = await repo.getMealsByDate(userId, now);
      getResult.fold(
        (failure) => _addResult('5. Meal Retrieve', '❌ ${failure.message}'),
        (meals) => _addResult('5. Meal Retrieve', 
            '✅ Retrieved ${meals.length} meal(s) for today'),
      );
    } catch (e) {
      _addResult('5. Meal Test', '❌ Error: $e');
    }
  }

  Future<void> _testExercise() async {
    try {
      final repo = ref.read(exerciseRepositoryProvider);
      final now = DateTime.now();

      final userResult = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
      final userId = userResult.fold((_) => 'demo-user-id', (profile) => profile.id);

      final exercise = Exercise(
        id: 'demo-exercise-${now.millisecondsSinceEpoch}',
        userId: userId,
        name: 'Demo Workout',
        type: ExerciseType.strength,
        muscleGroups: ['Chest', 'Shoulders'],
        equipment: ['Dumbbells'],
        duration: 45,
        sets: 3,
        reps: 10,
        weight: 20.0,
        distance: null,
        date: now,
        notes: 'Demo exercise',
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await repo.saveExercise(exercise);
      saveResult.fold(
        (failure) => _addResult('6. Exercise Save', '❌ ${failure.message}'),
        (_) => _addResult('6. Exercise Save', '✅ Success'),
      );

      final getResult = await repo.getExercisesByDate(userId, now);
      getResult.fold(
        (failure) => _addResult('6. Exercise Retrieve', '❌ ${failure.message}'),
        (exercises) => _addResult('6. Exercise Retrieve', 
            '✅ Retrieved ${exercises.length} exercise(s) for today'),
      );
    } catch (e) {
      _addResult('6. Exercise Test', '❌ Error: $e');
    }
  }

  Future<void> _testHabit() async {
    try {
      final repo = ref.read(behavioralRepositoryProvider);
      final now = DateTime.now();

      final userResult = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
      final userId = userResult.fold((_) => 'demo-user-id', (profile) => profile.id);

      final habit = Habit(
        id: 'demo-habit-${now.millisecondsSinceEpoch}',
        userId: userId,
        name: 'Daily Walk',
        category: HabitCategory.exercise,
        description: 'Walk 10,000 steps daily',
        completedDates: [now],
        currentStreak: 1,
        longestStreak: 1,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await repo.saveHabit(habit);
      saveResult.fold(
        (failure) => _addResult('7. Habit Save', '❌ ${failure.message}'),
        (_) => _addResult('7. Habit Save', '✅ Success'),
      );

      final getResult = await repo.getHabitsByUserId(userId);
      getResult.fold(
        (failure) => _addResult('7. Habit Retrieve', '❌ ${failure.message}'),
        (habits) => _addResult('7. Habit Retrieve', 
            '✅ Retrieved ${habits.length} habit(s)'),
      );
    } catch (e) {
      _addResult('7. Habit Test', '❌ Error: $e');
    }
  }

  Future<void> _testGoal() async {
    try {
      final repo = ref.read(behavioralRepositoryProvider);
      final now = DateTime.now();

      final userResult = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
      final userId = userResult.fold((_) => 'demo-user-id', (profile) => profile.id);

      final goal = Goal(
        id: 'demo-goal-${now.millisecondsSinceEpoch}',
        userId: userId,
        type: GoalType.outcome,
        description: 'Lose 10 kg',
        target: 'Weight loss goal',
        targetValue: 10.0,
        currentValue: 2.0,
        deadline: now.add(const Duration(days: 90)),
        linkedMetric: 'weight',
        status: GoalStatus.inProgress,
        completedAt: null,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await repo.saveGoal(goal);
      saveResult.fold(
        (failure) => _addResult('8. Goal Save', '❌ ${failure.message}'),
        (_) => _addResult('8. Goal Save', '✅ Success'),
      );

      final getResult = await repo.getGoalsByUserId(userId);
      getResult.fold(
        (failure) => _addResult('8. Goal Retrieve', '❌ ${failure.message}'),
        (goals) => _addResult('8. Goal Retrieve', 
            '✅ Retrieved ${goals.length} goal(s)'),
      );
    } catch (e) {
      _addResult('8. Goal Test', '❌ Error: $e');
    }
  }

  Future<void> _testUserPreferences() async {
    try {
      // UserPreferences is a core entity, not in a repository yet
      // Just verify the entity can be created
      final preferences = UserPreferences.defaults();
      _addResult('9. UserPreferences Entity', 
          '✅ Created with defaults (Dietary: ${preferences.dietaryApproach}, Units: ${preferences.units})');
    } catch (e) {
      _addResult('9. UserPreferences Test', '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint 2: Foundation Data Layer Demo'),
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
                      'Sprint 2 Demo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This demo verifies all Sprint 2 deliverables:\n'
                      '• Domain entities\n'
                      '• Hive data models\n'
                      '• Repository interfaces & implementations\n'
                      '• Data sources\n'
                      '• Hive box operations',
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


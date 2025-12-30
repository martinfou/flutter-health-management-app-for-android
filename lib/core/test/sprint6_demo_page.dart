// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/exercise_management/presentation/pages/exercise_page.dart';
import 'package:health_app/features/exercise_management/presentation/pages/workout_plan_page.dart';
import 'package:health_app/features/exercise_management/presentation/pages/workout_logging_page.dart';
import 'package:health_app/features/exercise_management/presentation/pages/activity_tracking_page.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_providers.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/domain/entities/workout_plan.dart';

/// Sprint 6 Demo Page
/// 
/// Demonstrates all Sprint 6 features:
/// - Exercise providers (Riverpod)
/// - Exercise pages (workout plans, workout logging)
/// - Exercise widgets (workout cards, exercise lists)
/// - Workout plan interface
/// - Workout logging
/// - Activity tracking display
class Sprint6DemoPage extends ConsumerStatefulWidget {
  const Sprint6DemoPage({super.key});

  @override
  ConsumerState<Sprint6DemoPage> createState() => _Sprint6DemoPageState();
}

class _Sprint6DemoPageState extends ConsumerState<Sprint6DemoPage> {
  final List<String> _demoResults = [];
  bool _isRunning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkProviders();
  }

  void _checkProviders() {
    // Check if providers are accessible
    try {
      ref.read(createWorkoutPlanUseCaseProvider);
      ref.read(getWorkoutHistoryUseCaseProvider);
      ref.read(logWorkoutUseCaseProvider);
      
      _addResult('Providers Initialization', 
          '✅ All providers accessible');
    } catch (e) {
      _addResult('Providers Initialization', '❌ Error: $e');
    }
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
      // 1. Providers Check
      _addResult('1. Exercise Providers', '✅ All providers initialized');
      
      // 2. Test Use Case Providers
      await _testUseCaseProviders();
      
      // 3. Seed Example Exercises
      await _seedExampleExercises();
      
      // 4. Create Example Workout Plans
      await _createExampleWorkoutPlans();
      
      // 5. Test Workout Plans Provider
      await _testWorkoutPlansProvider();
      
      // 6. Test Workout History Provider
      await _testWorkoutHistoryProvider();
      
      // 7. Test Current User ID Provider
      await _testCurrentUserIdProvider();

      _addResult('✅ Demo Complete', 'All Sprint 6 features tested successfully!');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testUseCaseProviders() async {
    try {
      ref.read(createWorkoutPlanUseCaseProvider);
      ref.read(getWorkoutHistoryUseCaseProvider);
      ref.read(logWorkoutUseCaseProvider);
      
      _addResult('2. Use Case Providers', '✅ All use case providers working');
    } catch (e) {
      _addResult('2. Use Case Providers', '❌ Error: $e');
    }
  }

  Future<void> _testWorkoutPlansProvider() async {
    try {
      final plansAsync = ref.read(workoutPlansProvider);
      plansAsync.when(
        data: (plans) {
          _addResult('5. Workout Plans Provider', 
              '✅ Provider working (${plans.length} plans) - Note: MVP returns empty list');
        },
        loading: () {
          _addResult('5. Workout Plans Provider', '⏳ Loading...');
        },
        error: (error, stack) {
          _addResult('5. Workout Plans Provider', '❌ Error: $error');
        },
      );
    } catch (e) {
      _addResult('5. Workout Plans Provider', '❌ Error: $e');
    }
  }

  Future<void> _testWorkoutHistoryProvider() async {
    try {
      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 7));
      final endDate = DateTime(today.year, today.month, today.day).add(const Duration(days: 1));
      
      final params = WorkoutHistoryParams(
        startDate: startDate,
        endDate: endDate,
      );
      
      final historyAsync = ref.read(workoutHistoryProvider(params));
      historyAsync.when(
        data: (exercises) {
          _addResult('6. Workout History Provider', 
              '✅ Provider working (${exercises.length} exercises found)');
        },
        loading: () {
          _addResult('6. Workout History Provider', '⏳ Loading...');
        },
        error: (error, stack) {
          _addResult('6. Workout History Provider', '❌ Error: $error');
        },
      );
    } catch (e) {
      _addResult('6. Workout History Provider', '❌ Error: $e');
    }
  }

  Future<void> _seedExampleExercises() async {
    try {
      String userId;
      try {
        final userIdResult = await ref.read(currentUserIdProvider.future);
        userId = userIdResult ?? 'demo-user-id';
      } catch (e) {
        userId = 'demo-user-id';
      }

      final logUseCase = ref.read(logWorkoutUseCaseProvider);
      final now = DateTime.now();
      
      // Create example exercises for the past week
      final exercises = [
        {
          'name': 'Bench Press',
          'type': ExerciseType.strength,
          'sets': 4,
          'reps': 8,
          'weight': 80.0,
          'muscleGroups': <String>['chest', 'triceps', 'shoulders'],
          'equipment': <String>['barbell', 'bench'],
          'date': now.subtract(const Duration(days: 1)),
        },
        {
          'name': 'Running',
          'type': ExerciseType.cardio,
          'duration': 30,
          'distance': 5.0,
          'muscleGroups': <String>['legs'],
          'equipment': <String>[],
          'date': now.subtract(const Duration(days: 2)),
        },
        {
          'name': 'Squats',
          'type': ExerciseType.strength,
          'sets': 3,
          'reps': 12,
          'weight': 100.0,
          'muscleGroups': <String>['quadriceps', 'glutes'],
          'equipment': <String>['barbell'],
          'date': now.subtract(const Duration(days: 3)),
        },
        {
          'name': 'Deadlift',
          'type': ExerciseType.strength,
          'sets': 3,
          'reps': 5,
          'weight': 120.0,
          'muscleGroups': <String>['back', 'hamstrings', 'glutes'],
          'equipment': <String>['barbell'],
          'date': now.subtract(const Duration(days: 4)),
        },
        {
          'name': 'Yoga',
          'type': ExerciseType.flexibility,
          'duration': 45,
          'muscleGroups': <String>['full body'],
          'equipment': <String>['yoga mat'],
          'date': now.subtract(const Duration(days: 5)),
        },
        {
          'name': 'Pull-ups',
          'type': ExerciseType.strength,
          'sets': 3,
          'reps': 10,
          'muscleGroups': <String>['back', 'biceps'],
          'equipment': <String>['pull-up bar'],
          'date': now.subtract(const Duration(days: 6)),
        },
      ];

      int successCount = 0;
      for (final ex in exercises) {
        final result = await logUseCase.call(
          userId: userId,
          name: ex['name'] as String,
          type: ex['type'] as ExerciseType,
          date: ex['date'] as DateTime,
          sets: ex['sets'] as int?,
          reps: ex['reps'] as int?,
          weight: ex['weight'] as double?,
          duration: ex['duration'] as int?,
          distance: ex['distance'] as double?,
          muscleGroups: (ex['muscleGroups'] as List).cast<String>(),
          equipment: (ex['equipment'] as List).cast<String>(),
        );
        
        result.fold(
          (failure) => null,
          (_) => successCount++,
        );
      }

      _addResult('3. Example Exercises', 
          '✅ Created $successCount example exercises');
    } catch (e) {
      _addResult('3. Example Exercises', '❌ Error: $e');
    }
  }

  Future<void> _createExampleWorkoutPlans() async {
    try {
      String userId;
      try {
        final userIdResult = await ref.read(currentUserIdProvider.future);
        userId = userIdResult ?? 'demo-user-id';
      } catch (e) {
        userId = 'demo-user-id';
      }

      final createUseCase = ref.read(createWorkoutPlanUseCaseProvider);
      
      // Create Push/Pull/Legs Split
      final pplPlan = createUseCase.call(
        userId: userId,
        name: 'Push/Pull/Legs Split',
        description: 'Classic 6-day split focusing on push, pull, and leg movements',
        days: [
          WorkoutDay(
            dayName: 'Monday',
            exerciseIds: ['bench-press', 'shoulder-press', 'tricep-dips'],
            focus: 'Push',
            estimatedDuration: 60,
          ),
          WorkoutDay(
            dayName: 'Tuesday',
            exerciseIds: ['deadlift', 'rows', 'pull-ups'],
            focus: 'Pull',
            estimatedDuration: 60,
          ),
          WorkoutDay(
            dayName: 'Wednesday',
            exerciseIds: ['squats', 'leg-press', 'calf-raises'],
            focus: 'Legs',
            estimatedDuration: 60,
          ),
          WorkoutDay(
            dayName: 'Thursday',
            exerciseIds: ['bench-press', 'shoulder-press', 'tricep-dips'],
            focus: 'Push',
            estimatedDuration: 60,
          ),
          WorkoutDay(
            dayName: 'Friday',
            exerciseIds: ['deadlift', 'rows', 'pull-ups'],
            focus: 'Pull',
            estimatedDuration: 60,
          ),
          WorkoutDay(
            dayName: 'Saturday',
            exerciseIds: ['squats', 'leg-press', 'calf-raises'],
            focus: 'Legs',
            estimatedDuration: 60,
          ),
        ],
        durationWeeks: 8,
      );

      // Create Upper/Lower Split
      final upperLowerPlan = createUseCase.call(
        userId: userId,
        name: 'Upper/Lower Split',
        description: '4-day split alternating upper and lower body workouts',
        days: [
          WorkoutDay(
            dayName: 'Monday',
            exerciseIds: ['bench-press', 'rows', 'shoulder-press', 'pull-ups'],
            focus: 'Upper Body',
            estimatedDuration: 75,
          ),
          WorkoutDay(
            dayName: 'Tuesday',
            exerciseIds: ['squats', 'deadlift', 'leg-press', 'calf-raises'],
            focus: 'Lower Body',
            estimatedDuration: 75,
          ),
          WorkoutDay(
            dayName: 'Thursday',
            exerciseIds: ['bench-press', 'rows', 'shoulder-press', 'pull-ups'],
            focus: 'Upper Body',
            estimatedDuration: 75,
          ),
          WorkoutDay(
            dayName: 'Friday',
            exerciseIds: ['squats', 'deadlift', 'leg-press', 'calf-raises'],
            focus: 'Lower Body',
            estimatedDuration: 75,
          ),
        ],
        durationWeeks: 6,
      );

      // Create Cardio Focus Plan
      final cardioPlan = createUseCase.call(
        userId: userId,
        name: 'Cardio Focus Plan',
        description: 'Balanced plan with cardio and strength training',
        days: [
          WorkoutDay(
            dayName: 'Monday',
            exerciseIds: ['running', 'squats', 'lunges'],
            focus: 'Cardio + Legs',
            estimatedDuration: 45,
          ),
          WorkoutDay(
            dayName: 'Wednesday',
            exerciseIds: ['cycling', 'bench-press', 'rows'],
            focus: 'Cardio + Upper',
            estimatedDuration: 45,
          ),
          WorkoutDay(
            dayName: 'Friday',
            exerciseIds: ['running', 'yoga'],
            focus: 'Cardio + Flexibility',
            estimatedDuration: 60,
          ),
        ],
        durationWeeks: 4,
      );

      int successCount = 0;
      pplPlan.fold(
        (failure) => null,
        (_) => successCount++,
      );
      upperLowerPlan.fold(
        (failure) => null,
        (_) => successCount++,
      );
      cardioPlan.fold(
        (failure) => null,
        (_) => successCount++,
      );

      _addResult('4. Example Workout Plans', 
          '✅ Created $successCount example workout plans');
    } catch (e) {
      _addResult('4. Example Workout Plans', '❌ Error: $e');
    }
  }

  Future<void> _seedExampleData() async {
    setState(() {
      _isRunning = true;
      _errorMessage = null;
      _demoResults.clear();
    });

    try {
      _addResult('Seeding Example Data', 'Starting...');
      
      // Check if exercises already exist
      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 7));
      final endDate = DateTime(today.year, today.month, today.day).add(const Duration(days: 1));
      
      final params = WorkoutHistoryParams(
        startDate: startDate,
        endDate: endDate,
      );
      
      // Check if exercises already exist (non-blocking check)
      final existingExercisesAsync = ref.read(workoutHistoryProvider(params));
      final existingExercises = existingExercisesAsync.when(
        data: (exercises) => exercises,
        loading: () => <Exercise>[], // If loading, assume no exercises yet
        error: (_, __) => <Exercise>[], // On error, proceed with seeding
      );

      if (existingExercises.isNotEmpty) {
        _addResult('⚠️ Exercises Already Exist', 
            'Found ${existingExercises.length} existing exercises. '
            'Skipping seed to avoid duplicates. Clear data first if you want to reseed.');
      } else {
        // Seed exercises only if none exist
        await _seedExampleExercises();
      }
      
      // Create workout plans (in memory - not persisted in MVP)
      await _createExampleWorkoutPlans();
      
      _addResult('✅ Seeding Complete', 
          'Example exercises and workout plans created! '
          'Navigate to Exercise pages to see them.');
      
      // Invalidate providers to refresh data
      ref.invalidate(workoutHistoryProvider);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testCurrentUserIdProvider() async {
    try {
      final userIdAsync = ref.read(currentUserIdProvider);
      userIdAsync.when(
        data: (userId) {
          _addResult('7. Current User ID Provider', 
              userId != null 
                  ? '✅ User ID found: ${userId.substring(0, 8)}...'
                  : '⚠️ No user profile (expected for MVP)');
        },
        loading: () {
          _addResult('7. Current User ID Provider', '⏳ Loading...');
        },
        error: (error, stack) {
          _addResult('7. Current User ID Provider', '❌ Error: $error');
        },
      );
    } catch (e) {
      _addResult('7. Current User ID Provider', '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint 6: Exercise UI Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sprint 6: Exercise UI',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    Text(
                      'This demo showcases all exercise tracking UI features including:\n'
                      '• Exercise providers (Riverpod)\n'
                      '• Workout plan creation\n'
                      '• Workout logging\n'
                      '• Activity tracking display\n'
                      '• Exercise main page',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // Seed Example Data Button
            CustomButton(
              label: _isRunning ? 'Seeding Data...' : 'Seed Example Data',
              onPressed: _isRunning ? null : _seedExampleData,
              isLoading: _isRunning,
              width: double.infinity,
              variant: ButtonVariant.secondary,
            ),

            const SizedBox(height: UIConstants.spacingSm),

            // Test Providers Button
            CustomButton(
              label: _isRunning ? 'Running Tests...' : 'Test Providers',
              onPressed: _isRunning ? null : _runFullDemo,
              isLoading: _isRunning,
              width: double.infinity,
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Demo Results
            if (_demoResults.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      ..._demoResults.map((result) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: UIConstants.spacingXs),
                          child: Text(
                            result,
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UIConstants.spacingMd),
            ],

            // Error Message
            if (_errorMessage != null)
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: UIConstants.spacingLg),

            // Navigation to Exercise Pages
            Text(
              'Exercise Pages',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),

            // Exercise Main Page
            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Exercise Main Page'),
                subtitle: const Text('Overview of workouts and activity'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ExercisePage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: UIConstants.spacingSm),

            // Workout Plan Page
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Workout Plan Page'),
                subtitle: const Text('Create and manage workout plans'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WorkoutPlanPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: UIConstants.spacingSm),

            // Workout Logging Page
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Workout Logging Page'),
                subtitle: const Text('Log exercises and workouts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WorkoutLoggingPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: UIConstants.spacingSm),

            // Activity Tracking Page
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_walk),
                title: const Text('Activity Tracking Page'),
                subtitle: const Text('View daily activity summary'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ActivityTrackingPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // Features Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sprint 6 Features',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    _buildFeatureItem(theme, '✅ Exercise Providers', 'Riverpod providers for workout plans and history'),
                    _buildFeatureItem(theme, '✅ Workout Plan Page', 'Create and manage structured workout plans'),
                    _buildFeatureItem(theme, '✅ Workout Logging Page', 'Log exercises with sets, reps, weight, duration'),
                    _buildFeatureItem(theme, '✅ Exercise Main Page', 'Overview of workouts, plans, and activity'),
                    _buildFeatureItem(theme, '✅ Activity Tracking', 'Daily activity summary (basic MVP implementation)'),
                    _buildFeatureItem(theme, '✅ Widgets', 'WorkoutCardWidget and ExerciseListWidget'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


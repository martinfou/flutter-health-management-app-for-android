# Exercise Module Specification

## Overview

The Exercise Module provides comprehensive exercise and movement tracking including workout plan creation, exercise logging, activity tracking, and Google Fit/Health Connect integration. The module supports strength training, cardio, flexibility exercises, and activity monitoring.

**Reference**: 
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Data Models: `artifacts/phase-1-foundations/data-models.md`
- Health Domain: `artifacts/phase-1-foundations/health-domain-specifications.md`
- Integration: `artifacts/phase-3-integration/integration-specifications.md`

## Module Structure

```
lib/features/exercise_management/
├── data/
│   ├── models/
│   │   ├── exercise_model.dart
│   │   └── workout_plan_model.dart
│   ├── repositories/
│   │   └── exercise_repository_impl.dart
│   └── datasources/
│       ├── local/
│       │   └── exercise_local_datasource.dart
│       └── remote/ (post-MVP)
│           └── google_fit_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── exercise.dart
│   │   └── workout_plan.dart
│   ├── repositories/
│   │   └── exercise_repository.dart
│   └── usecases/
│       ├── create_workout_plan.dart
│       ├── log_workout.dart
│       ├── get_workout_history.dart
│       └── sync_with_google_fit.dart
└── presentation/
    ├── pages/
    │   ├── exercise_page.dart
    │   ├── workout_plan_page.dart
    │   ├── workout_logging_page.dart
    │   └── activity_tracking_page.dart
    ├── widgets/
    │   ├── workout_card_widget.dart
    │   └── exercise_list_widget.dart
    └── providers/
        ├── workout_plans_provider.dart
        └── workout_history_provider.dart
```

## Workout Plan Creation

### Features

- Create custom workout plans
- Pre-defined workout templates (Push/Pull splits, Zone-2 cardio)
- Exercise library integration
- Schedule workouts by day
- Progressive overload tracking

### Workout Plan Structure

**WorkoutPlan Entity**:
```dart
class WorkoutPlan {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<WorkoutDay> days; // Monday, Tuesday, etc.
  final DateTime startDate;
  final int durationWeeks;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class WorkoutDay {
  final String dayName; // Monday, Tuesday, etc.
  final List<Exercise> exercises;
  final String? focus; // Push, Pull, Legs, Cardio, etc.
  final int? estimatedDuration; // minutes
}
```

### UI Components

**Workout Plan Creation Screen**:
- Plan name input
- Description text area
- Day selector (select days of week)
- Exercise selector (add exercises to each day)
- Duration input (weeks)
- Save button

**Workout Plan View**:
- Plan overview
- Weekly schedule view
- Exercise list for each day
- Progress tracking
- Mark workout as complete

### Business Logic

**CreateWorkoutPlanUseCase**:
```dart
class CreateWorkoutPlanUseCase {
  final ExerciseRepository repository;
  
  Future<Either<Failure, WorkoutPlan>> call({
    required String name,
    required String description,
    required List<WorkoutDay> days,
    required int durationWeeks,
  }) async {
    final plan = WorkoutPlan(
      id: UUID().v4(),
      userId: currentUserId,
      name: name,
      description: description,
      days: days,
      startDate: DateTime.now(),
      durationWeeks: durationWeeks,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return await repository.saveWorkoutPlan(plan);
  }
}
```

## Exercise Logging

### Features

- Log individual exercises
- Track sets, reps, weight
- Track duration for cardio
- Track distance for running/cycling
- Add notes
- Link to workout plan

### UI Components

**Workout Logging Screen**:
- Date picker
- Exercise selector (or add new)
- Exercise details:
  - Sets input
  - Reps input
  - Weight input (for strength)
  - Duration input (for cardio)
  - Distance input (for running/cycling)
- Notes field
- Add exercise button
- Save workout button

**Exercise Entry Form**:
- Exercise name
- Exercise type (strength, cardio, flexibility, other)
- Muscle groups (multi-select)
- Equipment needed
- Instructions (optional)

### Business Logic

**LogWorkoutUseCase**:
```dart
class LogWorkoutUseCase {
  final ExerciseRepository repository;
  
  Future<Either<Failure, Exercise>> call({
    required String name,
    required ExerciseType type,
    required DateTime date,
    int? sets,
    int? reps,
    double? weight,
    int? duration,
    double? distance,
    String? notes,
    String? workoutPlanId,
  }) async {
    final exercise = Exercise(
      id: UUID().v4(),
      userId: currentUserId,
      name: name,
      type: type,
      muscleGroups: [],
      equipment: [],
      duration: duration,
      sets: sets,
      reps: reps,
      weight: weight,
      distance: distance,
      date: date,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return await repository.saveExercise(exercise);
  }
}
```

## Activity Tracking

### Features

- Step counting (via Google Fit/Health Connect)
- Active minutes tracking
- Calories burned estimation
- Activity history view
- Daily activity goals

### Google Fit Integration

**Integration Requirements**:
- Request Google Fit permissions
- Read step count data
- Read active minutes
- Read calories burned
- Sync data to local database
- Display in activity summary

**Implementation**:
```dart
class GoogleFitIntegration {
  final GoogleFitDataSource dataSource;
  
  Future<Either<Failure, ActivityData>> getTodayActivity() async {
    try {
      final steps = await dataSource.getSteps(DateTime.now());
      final activeMinutes = await dataSource.getActiveMinutes(DateTime.now());
      final calories = await dataSource.getCaloriesBurned(DateTime.now());
      
      return Right(ActivityData(
        steps: steps,
        activeMinutes: activeMinutes,
        caloriesBurned: calories,
        date: DateTime.now(),
      ));
    } catch (e) {
      return Left(IntegrationFailure('Failed to fetch Google Fit data: $e'));
    }
  }
}
```

### Health Connect Integration

**Integration Requirements** (Android 14+):
- Request Health Connect permissions
- Read step count
- Read active minutes
- Read calories
- Sync to local database

**Note**: Health Connect is Android's unified health platform. Use when available, fallback to Google Fit.

### Activity Summary Display

**UI Components**:
- Steps progress bar (X / 10,000 steps)
- Active minutes display
- Calories burned display
- Activity history chart

## Exercise Library

### Features

- Pre-populated exercise database
- Exercise categories (strength, cardio, flexibility)
- Exercise instructions
- Muscle group targeting
- Equipment requirements
- Exercise modifications

### Exercise Database Structure

**Exercise Library Entry**:
- Name
- Type (strength, cardio, flexibility, other)
- Muscle groups targeted
- Equipment needed
- Instructions (step-by-step)
- Modifications (easier/harder variations)
- Image/video URL (optional)

### UI Components

**Exercise Library Screen**:
- Search bar
- Filter by type, muscle group, equipment
- Exercise grid/list
- Exercise cards with thumbnail

**Exercise Detail Screen**:
- Full exercise information
- Instructions
- Muscle groups diagram
- Modifications
- "Add to Workout" button

## Workout Templates

### Pre-Defined Templates

**Push/Pull Split**:
- Push Day: Chest, Shoulders, Triceps
- Pull Day: Back, Biceps
- Leg Day: Legs, Glutes
- Rest days between

**Zone-2 Cardio Program**:
- Low-intensity cardio sessions
- Target heart rate zone
- Duration: 30-60 minutes
- Frequency: 3-5 times per week

**Full Body Workout**:
- All muscle groups in one session
- Suitable for beginners
- 2-3 times per week

### Template Customization

- Users can modify templates
- Add/remove exercises
- Adjust sets/reps
- Change frequency

## Progressive Overload Tracking

### Features

- Track weight progression
- Track rep progression
- Track volume (sets × reps × weight)
- Show progress over time
- Suggest weight increases

### Business Logic

**TrackProgressionUseCase**:
- Compare current workout to previous
- Calculate volume increase
- Suggest next weight/rep target
- Display progression chart

## Integration Points

### Health Tracking Module

- Link exercise to energy levels
- Track exercise impact on sleep quality
- Display exercise correlation with weight trends

### Google Fit/Health Connect

- Sync step count
- Sync active minutes
- Sync calories burned
- Display in activity summary

## User Flows

### Workout Logging Flow

```
Exercise Screen → Log Workout → Select Date
    ↓
Add Exercises → Enter Sets/Reps/Weight → Save
    ↓
Update Activity Summary → Update Progress
```

### Workout Plan Flow

```
Exercise Screen → Workout Plans → Create Plan
    ↓
Select Template (or custom) → Customize → Save
    ↓
View Schedule → Start Workout → Log Exercises
```

## Testing Requirements

- Workout plan creation
- Exercise logging accuracy
- Google Fit integration
- Activity data sync
- Progressive overload calculations

## References

- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Data Models**: `artifacts/phase-1-foundations/data-models.md`
- **Integration**: `artifacts/phase-3-integration/integration-specifications.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Exercise Module Specification Complete


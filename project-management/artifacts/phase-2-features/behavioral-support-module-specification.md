# Behavioral Support Module Specification

## Overview

The Behavioral Support Module provides habit tracking, identity-based goal setting, progress visualization, and weekly check-ins (post-MVP with LLM). The module focuses on supporting users' health identity transformation and building sustainable health habits.

**Reference**: 
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Data Models: `artifacts/phase-1-foundations/data-models.md`
- Health Domain: `artifacts/phase-1-foundations/health-domain-specifications.md`

## Module Structure

```
lib/features/behavioral_support/
├── data/
│   ├── models/
│   │   ├── habit_model.dart
│   │   └── goal_model.dart
│   ├── repositories/
│   │   └── behavioral_support_repository_impl.dart
│   └── datasources/
│       └── local/
│           └── behavioral_support_local_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── habit.dart
│   │   └── goal.dart
│   ├── repositories/
│   │   └── behavioral_support_repository.dart
│   └── usecases/
│       ├── create_habit.dart
│       ├── complete_habit.dart
│       ├── create_goal.dart
│       ├── update_goal_progress.dart
│       ├── calculate_habit_streak.dart
│       └── get_weekly_review.dart (post-MVP)
└── presentation/
    ├── pages/
    │   ├── habits_page.dart
    │   ├── goals_page.dart
    │   ├── habit_detail_page.dart
    │   ├── goal_detail_page.dart
    │   └── weekly_review_page.dart (post-MVP)
    ├── widgets/
    │   ├── habit_card_widget.dart
    │   ├── goal_card_widget.dart
    │   ├── streak_widget.dart
    │   └── progress_chart_widget.dart
    └── providers/
        ├── habits_provider.dart
        ├── goals_provider.dart
        └── weekly_review_provider.dart (post-MVP)
```

## Habit Tracking

### Features

- Create and manage habits
- Daily habit completion tracking
- Habit streak calculation
- Habit categories
- Habit history and statistics
- Visual habit calendar

### Habit Categories

**Categories**:
1. **Nutrition Habits**: Log meals, track macros, meal prep
2. **Exercise Habits**: Daily movement, workout completion
3. **Sleep Habits**: Consistent bedtime, sleep duration
4. **Medication Habits**: Take medications on time
5. **Self-Care Habits**: Progress photos, journaling
6. **Other**: Custom habits

### UI Components

**Habits List Screen**:
- List of all habits (active and archived)
- Habit cards showing:
  - Habit name and category
  - Current streak (e.g., "🔥 7 days")
  - Longest streak
  - Completion rate (e.g., "85%")
  - Today's completion status
- Quick action: Tap to mark complete/incomplete
- Filter: All, Active, By Category
- Floating action button: "Add Habit"

**Habit Entry Screen**:
- Habit name input
- Category selector
- Description (optional)
- Target frequency (Daily, Weekly)
- Start date picker
- Save button

**Habit Detail Screen**:
- Full habit information
- Habit calendar view (30-day view)
- Streak visualization
- Statistics:
  - Current streak
  - Longest streak
  - Total completions
  - Completion rate
- Edit/Delete buttons
- Archive option

**Habit Calendar**:
- 30-day calendar view
- Marked dates show completion status
- Color coding:
  - Green: Completed
  - Red: Missed
  - Gray: Not yet occurred
- Tap date to view details

### Business Logic

**CreateHabitUseCase**:
```dart
class CreateHabitUseCase {
  final BehavioralSupportRepository repository;
  
  Future<Either<Failure, Habit>> call({
    required String name,
    required HabitCategory category,
    String? description,
    required DateTime startDate,
  }) async {
    // Validate inputs
    if (name.isEmpty || name.length > 100) {
      return Left(ValidationFailure('Habit name must be 1-100 characters'));
    }
    
    // Create habit
    final habit = Habit(
      id: UUID().v4(),
      userId: currentUserId,
      name: name,
      category: category,
      description: description,
      completedDates: [],
      startDate: startDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save to repository
    return await repository.saveHabit(habit);
  }
}
```

**CompleteHabitUseCase**:
```dart
class CompleteHabitUseCase {
  final BehavioralSupportRepository repository;
  
  Future<Either<Failure, Habit>> call({
    required String habitId,
    DateTime? date,
  }) async {
    // Get habit
    final habitResult = await repository.getHabit(habitId);
    
    return habitResult.fold(
      (failure) => Left(failure),
      (habit) async {
        final completionDate = date ?? DateTime.now();
        final dateOnly = DateTime(
          completionDate.year,
          completionDate.month,
          completionDate.day,
        );
        
        // Check if already completed for this date
        if (habit.completedDates.contains(dateOnly)) {
          return Left(ValidationFailure('Habit already completed for this date'));
        }
        
        // Add completion date
        final updatedDates = List<DateTime>.from(habit.completedDates)..add(dateOnly);
        final updatedHabit = habit.copyWith(
          completedDates: updatedDates,
          updatedAt: DateTime.now(),
        );
        
        // Calculate streak
        final streak = CalculateHabitStreakUseCase()(updatedHabit);
        final updatedHabitWithStreak = updatedHabit.copyWith(currentStreak: streak);
        
        // Save updated habit
        return await repository.saveHabit(updatedHabitWithStreak);
      },
    );
  }
}
```

**CalculateHabitStreakUseCase**:
```dart
class CalculateHabitStreakUseCase {
  int call(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    
    // Sort dates descending
    final sortedDates = List<DateTime>.from(habit.completedDates)
      ..sort((a, b) => b.compareTo(a));
    
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    
    // Check if completed today or yesterday (allow flexibility)
    final yesterday = todayOnly.subtract(Duration(days: 1));
    
    if (!sortedDates.contains(todayOnly) && !sortedDates.contains(yesterday)) {
      // Streak broken if not completed today or yesterday
      return 0;
    }
    
    // Calculate consecutive days
    int streak = 0;
    DateTime? currentDate = sortedDates.contains(todayOnly) ? todayOnly : yesterday;
    
    for (int i = 0; i < sortedDates.length; i++) {
      if (sortedDates[i] == currentDate) {
        streak++;
        currentDate = currentDate!.subtract(Duration(days: 1));
      } else if (sortedDates[i].isBefore(currentDate!)) {
        // Gap found, streak broken
        break;
      }
    }
    
    return streak;
  }
}
```

**Validation Rules**:
- **Name**: Required, 1-100 characters
- **Category**: Required, must be valid category
- **Start Date**: Required, cannot be in future
- **Description**: Optional, max 500 characters

## Identity-Based Goal Setting

### Features

- Create health identity goals
- Create behavior goals
- Create outcome goals (supporting metrics)
- Goal progress tracking
- Goal achievement celebration
- Goal visualization

### Goal Types

**1. Health Identity Goals**:
- Primary focus: "I am a person who prioritizes health"
- Examples:
  - "I am someone who makes healthy food choices"
  - "I am someone who exercises regularly"
  - "I am someone who prioritizes sleep"

**2. Behavior Goals**:
- Actionable behaviors: "I exercise 3 times per week"
- Examples:
  - "I log all meals daily"
  - "I take medications on time"
  - "I track my weight daily"

**3. Outcome Goals**:
- Supporting metrics: "I lose 20 kg"
- Examples:
  - Weight loss goals
  - Measurement goals
  - Health metric improvement goals

### UI Components

**Goals List Screen**:
- List of all goals (active and completed)
- Goal cards showing:
  - Goal name and type
  - Progress indicator
  - Target and current values
  - Deadline (if applicable)
  - Status (In Progress, Completed)
- Filter: All, Active, Completed, By Type
- Floating action button: "Add Goal"

**Goal Entry Screen**:
- Goal type selector (Identity, Behavior, Outcome)
- Goal name/description input
- Target value input (for behavior/outcome goals)
- Deadline picker (optional)
- Link to relevant metrics (for outcome goals)
- Save button

**Goal Detail Screen**:
- Full goal information
- Progress visualization (progress bar, chart)
- Current value vs target
- Time remaining (if deadline set)
- Milestones achieved
- Edit/Delete buttons
- Mark as completed option

### Business Logic

**CreateGoalUseCase**:
```dart
class CreateGoalUseCase {
  final BehavioralSupportRepository repository;
  
  Future<Either<Failure, Goal>> call({
    required GoalType type,
    required String description,
    String? target,
    double? targetValue,
    DateTime? deadline,
    String? linkedMetric,
  }) async {
    // Validate inputs
    if (description.isEmpty || description.length > 500) {
      return Left(ValidationFailure('Goal description must be 1-500 characters'));
    }
    
    if (type == GoalType.behavior || type == GoalType.outcome) {
      if (targetValue == null) {
        return Left(ValidationFailure('Target value required for behavior/outcome goals'));
      }
    }
    
    if (deadline != null && deadline.isBefore(DateTime.now())) {
      return Left(ValidationFailure('Deadline cannot be in the past'));
    }
    
    // Create goal
    final goal = Goal(
      id: UUID().v4(),
      userId: currentUserId,
      type: type,
      description: description,
      target: target,
      targetValue: targetValue,
      currentValue: 0.0,
      deadline: deadline,
      linkedMetric: linkedMetric,
      status: GoalStatus.inProgress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save to repository
    return await repository.saveGoal(goal);
  }
}
```

**UpdateGoalProgressUseCase**:
```dart
class UpdateGoalProgressUseCase {
  final BehavioralSupportRepository repository;
  
  Future<Either<Failure, Goal>> call({
    required String goalId,
    required double newValue,
  }) async {
    // Get goal
    final goalResult = await repository.getGoal(goalId);
    
    return goalResult.fold(
      (failure) => Left(failure),
      (goal) async {
        // Update current value
        final updatedGoal = goal.copyWith(
          currentValue: newValue,
          updatedAt: DateTime.now(),
        );
        
        // Check if goal achieved
        if (goal.targetValue != null && newValue >= goal.targetValue!) {
          updatedGoal = updatedGoal.copyWith(
            status: GoalStatus.completed,
            completedAt: DateTime.now(),
          );
        }
        
        // Save updated goal
        return await repository.saveGoal(updatedGoal);
      },
    );
  }
}
```

**Validation Rules**:
- **Description**: Required, 1-500 characters
- **Target Value**: Required for behavior/outcome goals
- **Deadline**: Optional, must be in future if provided
- **Linked Metric**: Optional, must be valid metric type if provided

## Progress Visualization

### Features

- Habit streak visualization
- Goal progress charts
- Weekly/monthly progress summaries
- Achievement milestones
- Visual progress indicators

### UI Components

**Habit Streak Widget**:
- Fire icon with streak number
- "🔥 7 days" display
- Streak history chart
- Motivational messages for milestones (7, 30, 100 days)

**Goal Progress Widget**:
- Progress bar showing current vs target
- Percentage complete
- Time remaining (if deadline set)
- Visual indicators (colors, icons)

**Progress Summary Widget**:
- Weekly summary card
- Monthly summary card
- Key achievements highlighted
- Stats display:
  - Habits completed this week
  - Goals progress
  - Streaks maintained

## Weekly Check-ins (Post-MVP)

### Features

**Post-MVP Feature**: Requires LLM integration

- Interactive weekly review
- LLM-powered insights and feedback
- Personalized recommendations
- Progress celebration
- Reflection questions

### Weekly Review Components

**1. Progress Summary**:
- Weight, measurements, macros, exercise summary
- Habits completed
- Goals progress

**2. Reflection Questions**:
- What went well this week?
- What challenges did you face?
- What would you like to improve?

**3. LLM-Powered Insights**:
- Personalized feedback based on progress
- Trend analysis
- Pattern recognition
- Motivational support

**4. Recommendations**:
- Actionable suggestions for next week
- Habit adjustments
- Goal refinements
- Health optimization tips

**5. Celebrations**:
- Highlight achievements
- Celebrate NSVs
- Recognize milestones
- Positive reinforcement

**Implementation Notes**:
- Weekly reviews generated using LLM API
- Reviews saved to local database
- Users can add personal notes
- Reviews accessible for future reference

## Integration Points

### Health Tracking Module

- Link habits to health metrics (e.g., "Track weight daily" habit)
- Display habit completion in health tracking screens
- Show health impact of habit adherence

### Nutrition Module

- Link nutrition habits (e.g., "Log meals daily")
- Track meal logging consistency
- Goal: "Eat within macro targets 5 days/week"

### Exercise Module

- Link exercise habits (e.g., "Exercise 3 times/week")
- Track workout completion
- Goal: "Complete weekly workout plan"

### Medication Module

- Link medication habits (e.g., "Take medications on time")
- Track medication adherence as habit
- Goal: "100% medication adherence"

## User Flows

### Create Habit Flow

```
Habits Page → Add Habit → Enter Details
    ↓
Select Category → Set Start Date → Save
    ↓
Return to Habits List → Habit Appears
```

### Complete Habit Flow

```
Habits Page → Tap Habit Card → Mark Complete
    ↓
Update Streak → Update Calendar → Save
    ↓
Return to Habits List → Streak Updated
```

### Create Goal Flow

```
Goals Page → Add Goal → Select Type
    ↓
Enter Description → Set Target → Set Deadline
    ↓
Link to Metric (optional) → Save
    ↓
Return to Goals List → Goal Appears
```

## Testing Requirements

### Unit Tests

- Habit streak calculation
- Goal progress calculation
- Goal achievement detection
- Date range calculations
- Completion tracking logic

### Widget Tests

- Habit entry form
- Goal entry form
- Streak widget display
- Progress chart rendering

### Integration Tests

- Complete habit creation flow
- Habit completion flow
- Goal creation flow
- Goal progress update flow
- Weekly review generation (post-MVP)

## Performance Considerations

- Efficient date range queries for habit completions
- Optimized streak calculations
- Fast goal progress updates
- Efficient calendar rendering

## Accessibility

- Screen reader labels for all interactive elements
- Keyboard navigation support
- High contrast mode support
- Clear visual indicators for completion status

## References

- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Data Models**: `artifacts/phase-1-foundations/data-models.md`
- **Health Domain**: `artifacts/phase-1-foundations/health-domain-specifications.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Behavioral Support Module Specification Complete


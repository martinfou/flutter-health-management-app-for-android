# Exercise Terminology Clarification

This document clarifies the terminology used in the app and identifies potential mismatches with user mental models.

## Current Codebase Model

Based on the codebase analysis:

### 1. **Exercise** (Entity: `Exercise`)
- **What it represents**: A single exercise instance with performance data
- **Contains**:
  - Exercise name (e.g., "Bench Press")
  - Type (strength, cardio, flexibility, other)
  - Performance data: sets, reps, weight, duration, distance
  - **Date** (when it was performed)
  - Muscle groups, equipment, notes
- **Two modes**:
  - **Template** (`date == null`): Reusable exercise definition in library
  - **Logged** (`date != null`): Completed exercise instance with performance data

### 2. **WorkoutPlan** (Entity: `WorkoutPlan`)
- **What it represents**: A schedule/template of exercises organized by day
- **Contains**:
  - Plan name and description
  - List of `WorkoutDay` objects (Monday, Tuesday, etc.)
  - Each `WorkoutDay` contains:
    - Day name
    - List of `exerciseIds` (references to Exercise templates)
    - Optional focus and duration
  - Start date, duration in weeks
  - Active/inactive status

### 3. **"Workout"** (Concept, not a direct entity)
- **What it currently represents**: Confusingly, the codebase uses "workout" terminology inconsistently:
  - `LogWorkoutUseCase` - Actually logs a single `Exercise` (not a collection)
  - `WorkoutLoggingPage` - Allows adding multiple `ExerciseEntry` objects (but saves them individually as `Exercise` entities)
  - `GetWorkoutHistoryUseCase` - Returns a list of `Exercise` entities (individual exercises, not grouped workouts)

## User's Mental Model (as described)

Based on your explanation:

### 1. **Exercise**
- Individual movement/activity (e.g., "Bench Press", "Running")
- Template definition of what an exercise is
- **Contains**: Name, type, muscle groups, equipment, instructions

### 2. **Workout**
- A collection of exercises performed together in one session
- Has a specific date/time
- **Contains**: List of exercises with their performance data (sets, reps, weight, etc.)
- Example: "Monday's Workout" = [Bench Press (3x10 @ 100kg), Squats (3x12 @ 80kg), Deadlifts (3x5 @ 120kg)]

### 3. **Plan**
- A collection of workouts designed to accomplish a goal
- Template/schedule that defines what workouts to do when
- **Contains**: Multiple workouts (e.g., "Monday Workout", "Wednesday Workout", "Friday Workout")
- Example: "4-Week Strength Plan" = [
    - Week 1-4: Monday Workout, Wednesday Workout, Friday Workout
  ]

## Visual Comparison

### User's Mental Model (What You Described):

```
┌─────────────────────────────────────────────┐
│  PLAN: "4-Week Strength Plan"              │
│  Goal: Build muscle                         │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ WORKOUT 1: "Monday Workout"          │ │
│  │ Date: 2025-01-27                     │ │
│  │ ┌─────────────────────────────────┐  │ │
│  │ │ EXERCISE 1: Bench Press         │  │ │
│  │ │   Sets: 3, Reps: 10, Weight: 100│  │ │
│  │ └─────────────────────────────────┘  │ │
│  │ ┌─────────────────────────────────┐  │ │
│  │ │ EXERCISE 2: Squats              │  │ │
│  │ │   Sets: 3, Reps: 12, Weight: 80 │  │ │
│  │ └─────────────────────────────────┘  │ │
│  │ ┌─────────────────────────────────┐  │ │
│  │ │ EXERCISE 3: Deadlifts           │  │ │
│  │ │   Sets: 3, Reps: 5, Weight: 120 │  │ │
│  │ └─────────────────────────────────┘  │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ WORKOUT 2: "Wednesday Workout"       │ │
│  │ Date: 2025-01-29                     │ │
│  │ [Exercises...]                       │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ WORKOUT 3: "Friday Workout"          │ │
│  │ Date: 2025-01-31                     │ │
│  │ [Exercises...]                       │ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Current Codebase Model (What Actually Exists):

```
┌─────────────────────────────────────────────┐
│  WORKOUT PLAN: "4-Week Strength Plan"      │
│  Duration: 4 weeks                          │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ WORKOUT DAY: Monday                  │ │
│  │ Exercise IDs: [id1, id2, id3]        │ │ ← Just IDs, not full exercises
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ WORKOUT DAY: Wednesday               │ │
│  │ Exercise IDs: [id4, id5]             │ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘

When user logs exercises:
┌─────────────────────────────────────────────┐
│  EXERCISE (logged): Bench Press            │ ← Separate entity
│  Date: 2025-01-27                          │
│  Sets: 3, Reps: 10, Weight: 100            │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  EXERCISE (logged): Squats                 │ ← Separate entity
│  Date: 2025-01-27                          │
│  Sets: 3, Reps: 12, Weight: 80             │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  EXERCISE (logged): Deadlifts              │ ← Separate entity
│  Date: 2025-01-27                          │
│  Sets: 3, Reps: 5, Weight: 120             │
└─────────────────────────────────────────────┘

❌ NO GROUPING: These 3 exercises are NOT grouped as a "Workout"
```

## Terminology Mismatch Analysis

### Current Model Issues:

```
Current Codebase                User's Mental Model
─────────────────────────────────────────────────────
Exercise (with date)    ❌     Workout (session)
WorkoutPlan             ❌     Plan (schedule template)
WorkoutDay              ❌     Workout (one day's session)
Exercise (template)     ✅     Exercise (definition)
```

### What's Missing:

The current codebase **does not have a "Workout" entity** that groups exercises together as a session.

**Current flow:**
1. User logs individual exercises (each saved as separate `Exercise` entity with date)
2. WorkoutPlan defines a schedule (`WorkoutDay` = day name + exercise IDs)
3. No grouping of exercises into "today's workout session"

**What should exist (based on your model):**
1. **Exercise** = Template/definition (✅ exists as template)
2. **Workout** = Session entity that contains multiple exercises performed together (❌ missing)
3. **Plan** = Schedule template with multiple workouts (partially exists as `WorkoutPlan`)

## Current Workflow vs Ideal Workflow

### Current (Actual Implementation):

```
User Action: "Log Workout"
  ↓
WorkoutLoggingPage shows list of ExerciseEntry objects
  ↓
User adds exercises to list
  ↓
Each ExerciseEntry is saved as individual Exercise entity (with date)
  ↓
Result: Multiple separate Exercise entities, not grouped as a "workout"
```

### Ideal (Your Mental Model):

```
User Action: "Log Workout"
  ↓
Create Workout entity (with date)
  ↓
Add exercises to workout (with performance data)
  ↓
Save Workout (contains multiple exercises)
  ↓
Result: One Workout entity containing multiple Exercise instances
```

## Implications

### Current Model Problems:

1. **No grouping**: Exercises logged on the same day are not grouped together as a "workout session"
2. **Terminology confusion**: "Log Workout" actually logs individual exercises
3. **History display**: Shows individual exercises, not workout sessions
4. **Plan execution**: WorkoutPlan defines a schedule, but there's no way to "start a workout from plan" and log it as a session

### What the Current Model Actually Represents:

- **Exercise** (logged) = Individual exercise performance record
- **Exercise** (template) = Exercise definition/library item
- **WorkoutPlan** = Schedule template (defines what exercises to do on which days)
- **WorkoutDay** = One day's schedule within a plan (list of exercise IDs)

## Proposed Architecture (Aligned with Your Model)

If we implement your mental model, the structure would be:

```
┌─────────────────────────────────────────────┐
│  EXERCISE (Template)                       │
│  - Name: "Bench Press"                     │
│  - Type: Strength                          │
│  - Muscle Groups: [Chest, Shoulders]       │
│  - Equipment: [Barbell]                    │
│  - date: null (template)                   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  WORKOUT (Session)                         │ ← NEW ENTITY NEEDED
│  - id: "workout-123"                       │
│  - userId: "user-1"                        │
│  - date: 2025-01-27                        │
│  - exercises: [                            │
│      ExerciseInstance (Bench Press + data),│
│      ExerciseInstance (Squats + data),     │
│      ExerciseInstance (Deadlifts + data)   │
│    ]                                       │
│  - workoutPlanId: "plan-456" (optional)    │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  PLAN (Schedule Template)                  │
│  - name: "4-Week Strength Plan"            │
│  - workouts: [                             │ ← List of Workout templates
│      WorkoutTemplate (Monday Workout),     │
│      WorkoutTemplate (Wednesday Workout),  │
│      WorkoutTemplate (Friday Workout)      │
│    ]                                       │
│  - durationWeeks: 4                        │
└─────────────────────────────────────────────┘
```

## Recommendations

### Option 1: Keep Current Model (Minor Refactoring)
- Rename terminology to be clearer:
  - "Log Workout" → "Log Exercise"
  - Keep `WorkoutPlan` as is (it's a schedule template)
  - Accept that there's no "Workout" session entity

### Option 2: Add Workout Entity (Major Refactoring)
- Create `Workout` entity:
  ```dart
  class Workout {
    final String id;
    final String userId;
    final DateTime date;
    final List<Exercise> exercises;  // Performance data for each
    final String? workoutPlanId;     // Optional: if from a plan
    // ...
  }
  ```
- Refactor to group exercises into workouts
- Update WorkoutPlan to reference Workout templates (not just Exercise IDs)
- This aligns with your mental model

### Option 3: Hybrid Approach
- Keep current `Exercise` entities for individual records
- Add `WorkoutSession` entity that groups exercises by date
- WorkoutPlan still defines schedule (WorkoutDay with exercise IDs)
- When logging, create WorkoutSession and add exercises to it

## Questions for Clarification

1. **Do you want workouts to be grouped sessions?**
   - Currently: Exercises logged on same day are separate entities
   - Your model: Exercises should be grouped into a "Workout" session

2. **Should WorkoutPlan contain Workout templates?**
   - Currently: WorkoutPlan contains WorkoutDay with Exercise IDs
   - Your model: Plan should contain multiple Workout definitions

3. **How should workout logging work?**
   - Currently: Add multiple exercises, each saved individually
   - Your model: Create one Workout, add exercises to it, save the workout

---

**Created**: 2025-01-27  
**Status**: Terminology Analysis - Awaiting User Clarification


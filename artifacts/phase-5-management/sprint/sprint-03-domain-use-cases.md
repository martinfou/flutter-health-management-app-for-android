# Sprint 3: Domain Use Cases

**Sprint Goal**: Implement all business logic use cases, calculation utilities, validation logic, and clinical safety alert checks to enable feature functionality.

**Duration**: [Start Date] - [End Date] (2 weeks)  
**Team Velocity**: Target 21 points  
**Sprint Planning Date**: [Date]  
**Sprint Review Date**: [Date]  
**Sprint Retrospective Date**: [Date]

## Sprint Overview

**Focus Areas**:
- Business logic use cases for all features
- Calculation utilities (moving averages, plateaus, macros)
- Clinical safety alert system
- Validation logic

**Key Deliverables**:
- All use cases for health tracking, nutrition, exercise, medication, behavioral support
- Calculation utilities (moving averages, plateaus, macros)
- Clinical safety alert system
- Validation logic

**Dependencies**:
- Sprint 2: Foundation Data Layer must be complete ✅

**Risks & Blockers**:
- Complex business logic
- Calculation algorithm complexity
- Clinical safety alert logic complexity

**Parallel Development**: Use cases for different features can be developed in parallel by different developers

**Current Status**: 
- ✅ All stories completed (29/29 story points, 100% complete)
- 📊 85 task points completed out of 85 total (100% complete)

## User Stories

### Story 3.1: Health Tracking Use Cases - 8 Points

**User Story**: As a developer, I want health tracking use cases implemented, so that health metric business logic can be executed.

**Acceptance Criteria**:
- [x] SaveHealthMetric use case implemented
- [x] CalculateMovingAverage use case implemented (7-day moving average)
- [x] DetectPlateau use case implemented
- [x] GetWeightTrend use case implemented
- [x] CalculateBaselineHeartRate use case implemented
- [x] All use cases return Result<T> (Either<Failure, T>)
- [x] Unit tests written (80% coverage target)

**Reference Documents**:
- `artifacts/phase-1-foundations/health-domain-specifications.md` - Health domain logic
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Health tracking specs
- `artifacts/phase-1-foundations/architecture-documentation.md` - Use case patterns

**Technical References**:
- Use Cases: `lib/features/health_tracking/domain/usecases/`
- Calculation: `CalculateMovingAverageUseCase.call()` - implements 7-day moving average
- Plateau: `DetectPlateauUseCase.call()` - returns `PlateauResult`
- Trend: `GetWeightTrendUseCase.call()` - returns `WeightTrendResult`

**Story Points**: 8

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Implementation Notes**:
- All 5 use cases implemented with comprehensive validation
- `PlateauResult` class created for plateau detection results
- `WeightTrendResult` class created for weight trend analysis
- All use cases follow Result<T> pattern with proper error handling
- Date filtering logic handles time components correctly

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-078 | Implement SaveHealthMetric use case | `SaveHealthMetricUseCase.call()` | health-tracking-module-specification.md | ✅ | 3 | Dev1 |
| T-079 | Implement CalculateMovingAverage use case | `CalculateMovingAverageUseCase.call()` | health-domain-specifications.md - 7-Day Moving Average | ✅ | 5 | Dev1 |
| T-080 | Implement DetectPlateau use case | `DetectPlateauUseCase.call()` | health-domain-specifications.md - Plateau Detection | ✅ | 5 | Dev1 |
| T-081 | Implement GetWeightTrend use case | `GetWeightTrendUseCase.call()` | health-domain-specifications.md - Weight Trend Analysis | ✅ | 3 | Dev1 |
| T-082 | Implement CalculateBaselineHeartRate use case | `CalculateBaselineHeartRateUseCase.call()` | clinical-safety-protocols.md - Baseline Calculation | ✅ | 3 | Dev1 |
| T-083 | Write unit tests for health tracking use cases | Test files in `test/unit/features/health_tracking/domain/usecases/` | ✅ | 5 | Dev1 |

**Total Task Points**: 24

---

### Story 3.2: Nutrition Use Cases - 5 Points

**User Story**: As a developer, I want nutrition use cases implemented, so that nutrition business logic can be executed.

**Acceptance Criteria**:
- [x] CalculateMacros use case implemented
- [x] LogMeal use case implemented
- [x] GetDailyMacroSummary use case implemented
- [x] SearchRecipes use case implemented
- [x] All use cases return Result<T>
- [x] Unit tests written

**Reference Documents**:
- `artifacts/phase-2-features/nutrition-module-specification.md` - Nutrition specs
- `artifacts/phase-1-foundations/health-domain-specifications.md` - Macro calculations

**Technical References**:
- Use Cases: `lib/features/nutrition_management/domain/usecases/`
- Macro Calculation: `CalculateMacrosUseCase` (returns `MacroSummary`)
- Macro Summary: `lib/features/nutrition_management/domain/usecases/calculate_macros.dart` - `MacroSummary` class

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Implementation Notes**:
- All 4 use cases implemented with comprehensive validation
- `MacroSummary` class created to return macro calculation results
- `SearchRecipesUseCase` includes both repository-based and local search methods
- All use cases follow Result<T> pattern with proper error handling

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-084 | Implement CalculateMacros use case | `CalculateMacrosUseCase.call()` | nutrition-module-specification.md - Macro Tracking | ✅ | 3 | Dev2 |
| T-085 | Implement LogMeal use case | `LogMealUseCase.call()` | nutrition-module-specification.md - Food Logging | ✅ | 3 | Dev2 |
| T-086 | Implement GetDailyMacroSummary use case | `GetDailyMacroSummaryUseCase.call()` | nutrition-module-specification.md - Macro Tracking | ✅ | 2 | Dev2 |
| T-087 | Implement SearchRecipes use case | `SearchRecipesUseCase.call()` | nutrition-module-specification.md - Recipe Database | ✅ | 3 | Dev2 |
| T-088 | Write unit tests for nutrition use cases | Test files in `test/unit/features/nutrition_management/domain/usecases/` | testing-strategy.md | ✅ | 3 | Dev2 |

**Total Task Points**: 14

---

### Story 3.3: Exercise Use Cases - 3 Points

**User Story**: As a developer, I want exercise use cases implemented, so that exercise business logic can be executed.

**Acceptance Criteria**:
- [x] CreateWorkoutPlan use case implemented
- [x] LogWorkout use case implemented
- [x] GetWorkoutHistory use case implemented
- [x] All use cases return Result<T>
- [x] Unit tests written

**Reference Documents**:
- `artifacts/phase-2-features/exercise-module-specification.md` - Exercise specs

**Technical References**:
- Use Cases: `lib/features/exercise_management/domain/usecases/`
- Entities: `lib/features/exercise_management/domain/entities/workout_plan.dart` - `WorkoutPlan` and `WorkoutDay`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Implementation Notes**:
- All 3 use cases implemented with type-specific validation
- `WorkoutPlan` and `WorkoutDay` entities created in `lib/features/exercise_management/domain/entities/workout_plan.dart`
- `CreateWorkoutPlanUseCase` validates plan structure (repository support for saving plans is post-MVP)
- `LogWorkoutUseCase` includes exercise type-specific validation (strength, cardio, flexibility, other)
- `GetWorkoutHistoryUseCase` includes date range validation and optional type filtering

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-089 | Implement CreateWorkoutPlan use case | `CreateWorkoutPlanUseCase.call()` | exercise-module-specification.md - Workout Plan Creation | ✅ | 3 | Dev3 |
| T-090 | Implement LogWorkout use case | `LogWorkoutUseCase.call()` | exercise-module-specification.md - Exercise Logging | ✅ | 3 | Dev3 |
| T-091 | Implement GetWorkoutHistory use case | `GetWorkoutHistoryUseCase.call()` | exercise-module-specification.md | ✅ | 2 | Dev3 |
| T-092 | Write unit tests for exercise use cases | Test files in `test/unit/features/exercise_management/domain/usecases/` | testing-strategy.md | ✅ | 3 | Dev3 |

**Total Task Points**: 11

---

### Story 3.4: Medication Use Cases - 3 Points

**User Story**: As a developer, I want medication use cases implemented, so that medication business logic can be executed.

**Acceptance Criteria**:
- [x] AddMedication use case implemented
- [x] LogMedicationDose use case implemented
- [x] CheckMedicationReminders use case implemented
- [x] All use cases return Result<T>
- [x] Unit tests written

**Reference Documents**:
- `artifacts/phase-2-features/medication-management-module-specification.md` - Medication specs (if exists)
- `artifacts/phase-1-foundations/data-models.md` - Medication entity

**Technical References**:
- Use Cases: `lib/features/medication_management/domain/usecases/`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Implementation Notes**:
- All 3 use cases implemented with comprehensive validation
- `MedicationReminder` result class created for reminder checks
- `AddMedicationUseCase` validates frequency matches times count, date ranges, and time validity
- `LogMedicationDoseUseCase` validates dosage and date ranges, optionally validates medication exists
- `CheckMedicationRemindersUseCase` checks active medications and determines which need reminders based on schedule and taken status
- All use cases follow Result<T> pattern with proper error handling

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-093 | Implement AddMedication use case | `AddMedicationUseCase.call()` | data-models.md - Medication | ✅ | 3 | Dev1 |
| T-094 | Implement LogMedicationDose use case | `LogMedicationDoseUseCase.call()` | data-models.md - MedicationLog | ✅ | 3 | Dev1 |
| T-095 | Implement CheckMedicationReminders use case | `CheckMedicationRemindersUseCase.call()` | platform-specifications.md - Notifications | ✅ | 3 | Dev1 |
| T-096 | Write unit tests for medication use cases | Test files in `test/unit/features/medication_management/domain/usecases/` | testing-strategy.md | ✅ | 3 | Dev1 |

**Total Task Points**: 12

---

### Story 3.5: Behavioral Support Use Cases - 2 Points

**User Story**: As a developer, I want behavioral support use cases implemented, so that habit and goal business logic can be executed.

**Acceptance Criteria**:
- [x] TrackHabit use case implemented
- [x] CreateGoal use case implemented
- [x] All use cases return Result<T>
- [x] Unit tests written

**Reference Documents**:
- `artifacts/phase-1-foundations/data-models.md` - Habit and Goal entities

**Technical References**:
- Use Cases: `lib/features/behavioral_support/domain/usecases/`

**Story Points**: 2

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Implementation Notes**:
- All 2 use cases implemented with comprehensive validation
- `TrackHabitUseCase` tracks habit completion, calculates current and longest streaks
- Streak calculation handles consecutive days and gaps correctly
- `CreateGoalUseCase` validates description, target values, and date ranges
- All use cases follow Result<T> pattern with proper error handling

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-097 | Implement TrackHabit use case | `TrackHabitUseCase.call()` | data-models.md - Habit | ✅ | 3 | Dev2 |
| T-098 | Implement CreateGoal use case | `CreateGoalUseCase.call()` | data-models.md - Goal | ✅ | 3 | Dev2 |
| T-099 | Write unit tests for behavioral use cases | Test files in `test/unit/features/behavioral_support/domain/usecases/` | testing-strategy.md | ✅ | 2 | Dev2 |

**Total Task Points**: 8

---

### Story 3.6: Clinical Safety Alert System - 8 Points

**User Story**: As a developer, I want clinical safety alert checks implemented, so that users receive safety alerts for concerning health metrics.

**Acceptance Criteria**:
- [x] RestingHeartRateAlert check implemented
- [x] RapidWeightLossAlert check implemented
- [x] PoorSleepAlert check implemented
- [x] ElevatedHeartRateAlert check implemented
- [x] All alerts follow clinical safety protocols
- [x] Alert thresholds match specifications
- [x] Unit tests written

**Reference Documents**:
- `artifacts/phase-1-foundations/clinical-safety-protocols.md` - Safety alert specifications
- `artifacts/phase-1-foundations/health-domain-specifications.md` - Health domain logic

**Technical References**:
- Safety: `lib/core/safety/`
- Alerts: `RestingHeartRateAlert`, `RapidWeightLossAlert`, `PoorSleepAlert`, `ElevatedHeartRateAlert`

**Story Points**: 8

**Priority**: 🔴 Critical (Risk Mitigation)

**Status**: ✅ Completed

**Implementation Notes**:
- All 4 alert checks implemented following clinical safety protocols
- `SafetyAlert` entity created with alert types and severity levels
- `AlertType` and `AlertSeverity` enums created
- All alerts use constants from `HealthConstants` for thresholds
- Consecutive day checking logic implemented for all alerts
- Alert messages include guidance and next steps
- All alerts follow Result<T> pattern (returns SafetyAlert or null)

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-100 | Implement RestingHeartRateAlert | `RestingHeartRateAlert.check()` | clinical-safety-protocols.md - Resting Heart Rate Alert | ✅ | 3 | Dev3 |
| T-101 | Implement RapidWeightLossAlert | `RapidWeightLossAlert.check()` | clinical-safety-protocols.md - Rapid Weight Loss Alert | ✅ | 3 | Dev3 |
| T-102 | Implement PoorSleepAlert | `PoorSleepAlert.check()` | clinical-safety-protocols.md - Poor Sleep Alert | ✅ | 2 | Dev3 |
| T-103 | Implement ElevatedHeartRateAlert | `ElevatedHeartRateAlert.check()` | clinical-safety-protocols.md - Elevated Heart Rate Alert | ✅ | 3 | Dev3 |
| T-104 | Write unit tests for safety alerts | Test files in `test/unit/core/safety/` | testing-strategy.md | ✅ | 5 | Dev3 |

**Total Task Points**: 16

---

## Sprint Summary

**Total Story Points**: 29  
**Total Task Points**: 85  
**Estimated Velocity**: 21 points (based on team capacity)

**Completed Story Points**: 29 (3.1: 8, 3.2: 5, 3.3: 3, 3.4: 3, 3.5: 2, 3.6: 8)  
**Completed Task Points**: 85 (T-078 to T-104)  
**Remaining Story Points**: 0  
**Remaining Task Points**: 0

**Progress**: 100% of story points completed (29/29) ✅

**Note**: This sprint supports parallel development. Use cases for different features can be developed simultaneously by different developers.

### Completed Deliverables

**Story 3.1 - Health Tracking Use Cases** ✅
- **Use Cases Implemented**:
  - `lib/features/health_tracking/domain/usecases/save_health_metric.dart` - `SaveHealthMetricUseCase`
  - `lib/features/health_tracking/domain/usecases/calculate_moving_average.dart` - `CalculateMovingAverageUseCase`
  - `lib/features/health_tracking/domain/usecases/detect_plateau.dart` - `DetectPlateauUseCase` (includes `PlateauResult` class)
  - `lib/features/health_tracking/domain/usecases/get_weight_trend.dart` - `GetWeightTrendUseCase` (includes `WeightTrendResult` class)
  - `lib/features/health_tracking/domain/usecases/calculate_baseline_heart_rate.dart` - `CalculateBaselineHeartRateUseCase`
- **Unit Tests**:
  - `test/unit/features/health_tracking/domain/usecases/save_health_metric_test.dart` (12 test cases)
  - `test/unit/features/health_tracking/domain/usecases/calculate_moving_average_test.dart` (8 test cases)
  - `test/unit/features/health_tracking/domain/usecases/detect_plateau_test.dart` (8 test cases)
  - `test/unit/features/health_tracking/domain/usecases/get_weight_trend_test.dart` (9 test cases)
  - `test/unit/features/health_tracking/domain/usecases/calculate_baseline_heart_rate_test.dart` (10 test cases)
- All use cases return `Result<T>` with proper error handling
- Total: 47 test cases across 5 test files

**Story 3.2 - Nutrition Use Cases** ✅
- **Use Cases Implemented**:
  - `lib/features/nutrition_management/domain/usecases/calculate_macros.dart` - `CalculateMacrosUseCase` (includes `MacroSummary` class)
  - `lib/features/nutrition_management/domain/usecases/log_meal.dart` - `LogMealUseCase`
  - `lib/features/nutrition_management/domain/usecases/get_daily_macro_summary.dart` - `GetDailyMacroSummaryUseCase`
  - `lib/features/nutrition_management/domain/usecases/search_recipes.dart` - `SearchRecipesUseCase` (includes local search method)
- **Unit Tests**:
  - `test/unit/features/nutrition_management/domain/usecases/calculate_macros_test.dart` (7 test cases)
  - `test/unit/features/nutrition_management/domain/usecases/log_meal_test.dart` (12 test cases)
  - `test/unit/features/nutrition_management/domain/usecases/get_daily_macro_summary_test.dart` (5 test cases)
  - `test/unit/features/nutrition_management/domain/usecases/search_recipes_test.dart` (10 test cases)
- All use cases return `Result<T>` with proper error handling
- Total: 34 test cases across 4 test files

**Story 3.3 - Exercise Use Cases** ✅
- **Entities Created**:
  - `lib/features/exercise_management/domain/entities/workout_plan.dart` - `WorkoutPlan` and `WorkoutDay` classes
- **Use Cases Implemented**:
  - `lib/features/exercise_management/domain/usecases/create_workout_plan.dart` - `CreateWorkoutPlanUseCase`
  - `lib/features/exercise_management/domain/usecases/log_workout.dart` - `LogWorkoutUseCase`
  - `lib/features/exercise_management/domain/usecases/get_workout_history.dart` - `GetWorkoutHistoryUseCase`
- **Unit Tests**:
  - `test/unit/features/exercise_management/domain/usecases/create_workout_plan_test.dart` (12 test cases)
  - `test/unit/features/exercise_management/domain/usecases/log_workout_test.dart` (15 test cases)
  - `test/unit/features/exercise_management/domain/usecases/get_workout_history_test.dart` (8 test cases)
- All use cases return `Result<T>` with proper error handling
- Exercise type-specific validation implemented (strength, cardio, flexibility, other)
- Total: 35 test cases across 3 test files

**Summary of Completed Work**:
- **17 use case files** created
- **1 entity file** created (WorkoutPlan/WorkoutDay)
- **1 result class** created (MedicationReminder)
- **4 alert check classes** created
- **1 safety alert entity** created (SafetyAlert)
- **2 enums** created (AlertType, AlertSeverity)
- **21 unit test files** created
- **200 total test cases** written
- All use cases follow clean architecture patterns
- All use cases use `Result<T>` (Either<Failure, T>) for error handling
- All alerts follow clinical safety protocols

### Pending Deliverables

**Story 3.4 - Medication Use Cases** ✅
- **Use Cases Implemented**:
  - `lib/features/medication_management/domain/usecases/add_medication.dart` - `AddMedicationUseCase`
  - `lib/features/medication_management/domain/usecases/log_medication_dose.dart` - `LogMedicationDoseUseCase`
  - `lib/features/medication_management/domain/usecases/check_medication_reminders.dart` - `CheckMedicationRemindersUseCase` (includes `MedicationReminder` class)
- **Unit Tests**:
  - `test/unit/features/medication_management/domain/usecases/add_medication_test.dart` (14 test cases)
  - `test/unit/features/medication_management/domain/usecases/log_medication_dose_test.dart` (10 test cases)
  - `test/unit/features/medication_management/domain/usecases/check_medication_reminders_test.dart` (11 test cases)
- All use cases return `Result<T>` with proper error handling
- Total: 35 test cases across 3 test files

**Story 3.5 - Behavioral Support Use Cases** ✅
- **Use Cases Implemented**:
  - `lib/features/behavioral_support/domain/usecases/track_habit.dart` - `TrackHabitUseCase`
  - `lib/features/behavioral_support/domain/usecases/create_goal.dart` - `CreateGoalUseCase`
- **Unit Tests**:
  - `test/unit/features/behavioral_support/domain/usecases/track_habit_test.dart` (10 test cases)
  - `test/unit/features/behavioral_support/domain/usecases/create_goal_test.dart` (11 test cases)
- All use cases return `Result<T>` with proper error handling
- Streak calculation logic implemented for habit tracking
- Total: 21 test cases across 2 test files

**Story 3.6 - Clinical Safety Alert System** ✅
- **Entities Created**:
  - `lib/core/safety/safety_alert.dart` - `SafetyAlert` class
  - `lib/core/safety/alert_type.dart` - `AlertType` and `AlertSeverity` enums
- **Alert Checks Implemented**:
  - `lib/core/safety/resting_heart_rate_alert.dart` - `RestingHeartRateAlert`
  - `lib/core/safety/rapid_weight_loss_alert.dart` - `RapidWeightLossAlert`
  - `lib/core/safety/poor_sleep_alert.dart` - `PoorSleepAlert`
  - `lib/core/safety/elevated_heart_rate_alert.dart` - `ElevatedHeartRateAlert`
- **Unit Tests**:
  - `test/unit/core/safety/resting_heart_rate_alert_test.dart` (7 test cases)
  - `test/unit/core/safety/rapid_weight_loss_alert_test.dart` (7 test cases)
  - `test/unit/core/safety/poor_sleep_alert_test.dart` (7 test cases)
  - `test/unit/core/safety/elevated_heart_rate_alert_test.dart` (7 test cases)
- All alerts follow clinical safety protocols
- Alert thresholds match specifications from `HealthConstants`
- Total: 28 test cases across 4 test files

**Sprint Burndown**:
- Day 1: 8 points completed (Story 3.1: Health Tracking Use Cases)
- Day 2: 5 points completed (Story 3.2: Nutrition Use Cases)
- Day 3: 3 points completed (Story 3.3: Exercise Use Cases)
- Day 4: 3 points completed (Story 3.4: Medication Use Cases)
- Day 5: 2 points completed (Story 3.5: Behavioral Support Use Cases)
- Day 6: 8 points completed (Story 3.6: Clinical Safety Alert System)
- Day 5: [ ] points completed
- Day 6: [ ] points completed
- Day 7: [ ] points completed
- Day 8: [ ] points completed
- Day 9: [ ] points completed
- Day 10: [ ] points completed

**Total Completed**: 29 points (100% of sprint goal) ✅

**Sprint Review Notes**:
- [Notes from sprint review]

**Sprint Retrospective Notes**:
- [Notes from retrospective]

---

## Demo to Product Owner

**Purpose**: The product owner will run the application and verify that all sprint deliverables are working correctly.

**Demo Checklist**:
- [x] Application builds and runs successfully
- [x] Health tracking use cases execute correctly (Story 3.1)
- [x] Nutrition use cases execute correctly (Story 3.2)
- [x] Exercise use cases execute correctly (Story 3.3)
- [x] Medication use cases execute correctly (Story 3.4)
- [x] Behavioral support use cases execute correctly (Story 3.5)
- [x] Clinical safety alerts trigger appropriately (Story 3.6)
- [x] Calculations (moving averages, plateaus, macros) produce accurate results
- [x] Validation logic works as expected (All stories)
- [x] All acceptance criteria from all user stories are met (Stories 3.1-3.6)
- [ ] Behavioral support use cases implemented (Story 3.5 - Pending)
- [x] No critical bugs or blockers identified in completed stories

**Demo Notes**:
- [Notes from product owner demo]

---

**Cross-Reference**: Implementation Order - Phase 3: Domain Use Cases


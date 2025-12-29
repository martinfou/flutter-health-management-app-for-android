# Test Specifications

## Overview

This document defines detailed test specifications for all modules of the Flutter Health Management App for Android, including unit tests, widget tests, and integration tests.

**Reference**: 
- Testing Strategy: `artifacts/phase-4-testing/testing-strategy.md`
- Feature Specs: `artifacts/phase-2-features/`
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`

## Health Tracking Module Tests

### Unit Tests

**CalculateMovingAverageUseCase Tests**:
- ✅ Calculate 7-day average with exactly 7 days of data
- ✅ Return null with less than 7 days of data
- ✅ Handle missing weight values (skip nulls)
- ✅ Calculate correctly with varying weights
- ✅ Handle edge cases (all same weight, all different weights)

**DetectPlateauUseCase Tests**:
- ✅ Detect plateau when weight unchanged for 3 weeks
- ✅ Detect plateau when measurements also unchanged
- ✅ Return no plateau when weight is changing
- ✅ Return no plateau when measurements are changing
- ✅ Handle insufficient data gracefully

**CalculateBaselineHeartRateUseCase Tests**:
- ✅ Calculate baseline from first 7 days
- ✅ Return null with insufficient data
- ✅ Handle missing heart rate values
- ✅ Recalculate monthly baseline correctly

### Widget Tests

**WeightEntryPage Tests**:
- ✅ Displays weight input field
- ✅ Displays date picker
- ✅ Shows 7-day average when available
- ✅ Shows "Insufficient data" when less than 7 days
- ✅ Validates weight input (20-500 kg)
- ✅ Saves weight on button tap
- ✅ Shows error for invalid weight

**WeightChartWidget Tests**:
- ✅ Displays line chart with data points
- ✅ Shows 7-day moving average overlay
- ✅ Handles empty data gracefully
- ✅ Updates when new data added

### Integration Tests

**Weight Entry Flow**:
- ✅ Navigate to weight entry
- ✅ Enter valid weight
- ✅ Save weight
- ✅ Verify weight saved in database
- ✅ Verify 7-day average updated
- ✅ Verify chart updated

## Nutrition Module Tests

### Unit Tests

**CalculateMacrosUseCase Tests**:
- ✅ Calculate daily macro totals correctly
- ✅ Calculate macro percentages by calories
- ✅ Handle empty meal list
- ✅ Validate net carbs limit (40g)
- ✅ Calculate protein percentage (35% target)
- ✅ Calculate fats percentage (55% target)

**LogMealUseCase Tests**:
- ✅ Save meal successfully
- ✅ Validate net carbs limit
- ✅ Validate required fields
- ✅ Handle recipe linking

**SearchRecipesUseCase Tests**:
- ✅ Search by name
- ✅ Filter by tags
- ✅ Filter by difficulty
- ✅ Sort by relevance

### Widget Tests

**MealLoggingPage Tests**:
- ✅ Displays meal type selector
- ✅ Displays food items list
- ✅ Allows adding food items
- ✅ Calculates meal totals
- ✅ Validates macros
- ✅ Saves meal on button tap

**MacroChartWidget Tests**:
- ✅ Displays macro breakdown
- ✅ Shows progress bars
- ✅ Color codes based on targets
- ✅ Updates when meals added

### Integration Tests

**Meal Logging Flow**:
- ✅ Navigate to meal logging
- ✅ Select meal type
- ✅ Add food items
- ✅ Verify macro calculations
- ✅ Save meal
- ✅ Verify daily totals updated

## Exercise Module Tests

### Unit Tests

**CreateWorkoutPlanUseCase Tests**:
- ✅ Create workout plan successfully
- ✅ Validate required fields
- ✅ Handle exercise assignment
- ✅ Calculate estimated duration

**LogWorkoutUseCase Tests**:
- ✅ Save exercise successfully
- ✅ Validate exercise data
- ✅ Link to workout plan
- ✅ Track progression

### Widget Tests

**WorkoutLoggingPage Tests**:
- ✅ Displays exercise selector
- ✅ Displays sets/reps/weight inputs
- ✅ Validates exercise data
- ✅ Saves workout on button tap

### Integration Tests

**Workout Logging Flow**:
- ✅ Navigate to workout logging
- ✅ Select exercise
- ✅ Enter sets/reps/weight
- ✅ Save workout
- ✅ Verify saved in database

## Data Layer Tests

### Repository Tests

**HealthTrackingRepositoryImpl Tests**:
- ✅ Save health metric
- ✅ Get health metrics by date range
- ✅ Get health metrics by user
- ✅ Update health metric
- ✅ Delete health metric
- ✅ Handle database errors

**NutritionRepositoryImpl Tests**:
- ✅ Save meal
- ✅ Get meals by date
- ✅ Get daily macro summary
- ✅ Search recipes
- ✅ Handle database errors

### Data Source Tests

**HiveDataSource Tests**:
- ✅ Save to Hive box
- ✅ Read from Hive box
- ✅ Update in Hive box
- ✅ Delete from Hive box
- ✅ Query with filters
- ✅ Handle box errors

## Integration Tests

Integration tests verify complete workflows across multiple layers and modules, ensuring data flows correctly from UI through business logic to data storage.

### Health Tracking Integration Tests

**Complete Weight Entry Flow**:
- ✅ Navigate to health tracking screen
- ✅ Tap "Add Weight" button
- ✅ Enter valid weight (75.5 kg)
- ✅ Select date (today)
- ✅ Tap "Save" button
- ✅ Verify weight saved to database
- ✅ Verify 7-day moving average calculated
- ✅ Verify weight appears in weight history
- ✅ Verify chart updated with new data point
- ✅ Verify trend indicator updated
- ✅ Verify safety alerts checked (if applicable)

**Test Data**:
- User profile with height and target weight
- 6 previous weight entries (for 7-day average calculation)
- Various weight values (75.0, 74.8, 75.2, etc.)

**Complete Measurement Entry Flow**:
- ✅ Navigate to measurements screen
- ✅ Tap "Add Measurements" button
- ✅ Enter waist measurement (90 cm)
- ✅ Enter hips measurement (100 cm)
- ✅ Enter other measurements (optional)
- ✅ Select date
- ✅ Tap "Save" button
- ✅ Verify measurements saved to database
- ✅ Verify measurements appear in history
- ✅ Verify change calculations displayed (vs previous measurement)
- ✅ Verify trend indicators updated

**Complete Sleep/Energy Entry Flow**:
- ✅ Navigate to sleep/energy screen
- ✅ Adjust sleep quality slider to 8
- ✅ Adjust energy level slider to 7
- ✅ Add optional notes
- ✅ Tap "Save" button
- ✅ Verify entry saved to database
- ✅ Verify 7-day average updated
- ✅ Verify trend chart updated
- ✅ Verify safety alerts checked (poor sleep alert if applicable)

**Plateau Detection Flow**:
- ✅ Set up 21 days of weight data (unchanged weight)
- ✅ Trigger plateau detection algorithm
- ✅ Verify plateau alert displayed
- ✅ Verify alert message shown with guidance
- ✅ Verify alert cannot be permanently dismissed

**Safety Alert Triggering Flow**:
- ✅ Set up 3 days of elevated heart rate (> 100 BPM)
- ✅ Verify elevated heart rate alert triggered
- ✅ Verify alert displayed prominently
- ✅ Verify alert requires acknowledgment
- ✅ Verify alert reappears if condition persists

### Nutrition Integration Tests

**Complete Meal Logging Flow**:
- ✅ Navigate to nutrition screen
- ✅ Tap "Log Meal" button
- ✅ Select meal type (Breakfast)
- ✅ Enter meal name ("Omelet")
- ✅ Enter protein (30g)
- ✅ Enter fats (25g)
- ✅ Enter net carbs (5g)
- ✅ Verify calories calculated correctly (30*4 + 25*9 + 5*4 = 305)
- ✅ Tap "Save Meal" button
- ✅ Verify meal saved to database
- ✅ Verify daily macro totals updated
- ✅ Verify macro percentages calculated correctly
- ✅ Verify macro chart updated
- ✅ Verify progress bars updated

**Test Data**:
- Previous meals for the day (to test daily totals)
- Various macro combinations
- Edge cases (very high/low macros)

**Daily Macro Summary Calculation Flow**:
- ✅ Log multiple meals for a day
- ✅ Verify daily protein total calculated correctly
- ✅ Verify daily fats total calculated correctly
- ✅ Verify daily net carbs total calculated correctly
- ✅ Verify daily calories total calculated correctly
- ✅ Verify macro percentages calculated by calories
- ✅ Verify percentages sum to approximately 100% (±5% tolerance)
- ✅ Verify color coding based on targets (green/yellow/red)

**Recipe-Based Meal Logging Flow**:
- ✅ Navigate to recipe library
- ✅ Search for recipe ("Keto Omelet")
- ✅ Tap recipe to view details
- ✅ Tap "Log as Meal" button
- ✅ Select meal type
- ✅ Adjust servings (if needed)
- ✅ Tap "Save" button
- ✅ Verify meal logged with recipe macros
- ✅ Verify recipe linked to meal
- ✅ Verify daily totals updated

**Net Carbs Validation Flow**:
- ✅ Attempt to log meal with net carbs > 40g
- ✅ Verify validation error displayed
- ✅ Verify meal not saved
- ✅ Log meal with net carbs = 40g
- ✅ Verify meal saved successfully
- ✅ Verify warning displayed if daily total exceeds 40g

### Exercise Integration Tests

**Complete Workout Logging Flow**:
- ✅ Navigate to exercise screen
- ✅ Tap "Log Workout" button
- ✅ Select exercise type (Strength)
- ✅ Enter exercise name ("Bench Press")
- ✅ Enter sets (3)
- ✅ Enter reps (10)
- ✅ Enter weight (80 kg)
- ✅ Select date
- ✅ Add optional notes
- ✅ Tap "Save" button
- ✅ Verify exercise saved to database
- ✅ Verify exercise appears in workout history
- ✅ Verify progress tracked correctly

**Workout Plan Creation Flow**:
- ✅ Navigate to workout planning
- ✅ Tap "Create Plan" button
- ✅ Enter plan name ("Upper Body")
- ✅ Add exercises to plan
- ✅ Set workout schedule
- ✅ Tap "Save Plan" button
- ✅ Verify plan saved to database
- ✅ Verify plan appears in plans list
- ✅ Verify exercises linked to plan

### Medication Integration Tests

**Complete Medication Entry Flow**:
- ✅ Navigate to medications screen
- ✅ Tap "Add Medication" button
- ✅ Enter medication name ("Wellbutrin")
- ✅ Enter dosage ("150mg")
- ✅ Select frequency ("Once Daily")
- ✅ Set time (08:00)
- ✅ Set start date
- ✅ Enable reminders
- ✅ Tap "Save" button
- ✅ Verify medication saved to database
- ✅ Verify reminders scheduled
- ✅ Verify medication appears in active medications list

**Medication Logging Flow**:
- ✅ Navigate to medication detail screen
- ✅ Tap "Log Dose" button
- ✅ Verify current time displayed (default)
- ✅ Optionally select different time
- ✅ Add optional notes
- ✅ Tap "Save" button
- ✅ Verify medication log saved
- ✅ Verify log appears in medication history
- ✅ Verify adherence statistics updated

**Side Effect Tracking Flow**:
- ✅ Navigate to medication detail screen
- ✅ Tap "Track Side Effect" button
- ✅ Enter side effect name ("Nausea")
- ✅ Select severity ("Moderate")
- ✅ Set start date
- ✅ Add optional notes
- ✅ Tap "Save" button
- ✅ Verify side effect saved to database
- ✅ Verify side effect appears in list
- ✅ Verify safety alert checked (if severe)

### Behavioral Support Integration Tests

**Complete Habit Creation Flow**:
- ✅ Navigate to habits screen
- ✅ Tap "Add Habit" button
- ✅ Enter habit name ("Log meals daily")
- ✅ Select category ("Nutrition")
- ✅ Enter optional description
- ✅ Set start date
- ✅ Tap "Save" button
- ✅ Verify habit saved to database
- ✅ Verify habit appears in habits list
- ✅ Verify streak initialized to 0

**Habit Completion Flow**:
- ✅ Navigate to habit detail screen
- ✅ Tap "Mark Complete" button
- ✅ Verify habit marked as completed for today
- ✅ Verify streak calculated correctly
- ✅ Verify longest streak updated (if applicable)
- ✅ Verify calendar updated
- ✅ Verify completion rate updated

**Goal Creation Flow**:
- ✅ Navigate to goals screen
- ✅ Tap "Add Goal" button
- ✅ Select goal type ("Behavior")
- ✅ Enter description ("Exercise 3 times per week")
- ✅ Set target value (3)
- ✅ Set optional deadline
- ✅ Tap "Save" button
- ✅ Verify goal saved to database
- ✅ Verify goal appears in goals list
- ✅ Verify progress initialized to 0%

**Goal Progress Update Flow**:
- ✅ Navigate to goal detail screen
- ✅ Update current value to 2
- ✅ Verify progress percentage calculated (2/3 = 66.67%)
- ✅ Verify progress bar updated
- ✅ Update current value to 3
- ✅ Verify goal status changed to "Completed"
- ✅ Verify completion date set

### Cross-Module Integration Tests

**Health Metric and Medication Correlation**:
- ✅ Log medication taken at 08:00
- ✅ Log heart rate at 10:00 (showing elevated rate)
- ✅ Verify medication context shown in health metrics
- ✅ Verify side effect correlation displayed

**Nutrition and Exercise Integration**:
- ✅ Log workout in morning
- ✅ Log meals throughout day
- ✅ Verify exercise calories considered in daily totals
- ✅ Verify nutrition recommendations based on exercise

**Habit and Health Tracking Integration**:
- ✅ Create "Track weight daily" habit
- ✅ Complete weight entry
- ✅ Verify habit automatically marked complete
- ✅ Verify streak updated

**Goal and Health Metrics Integration**:
- ✅ Create outcome goal: "Lose 5 kg"
- ✅ Link goal to weight metric
- ✅ Enter weight entries over time
- ✅ Verify goal progress automatically updated
- ✅ Verify goal status changes when target reached

### Data Persistence Integration Tests

**Database Save and Retrieve Flow**:
- ✅ Save health metric to database
- ✅ Close app
- ✅ Reopen app
- ✅ Verify health metric persisted
- ✅ Verify data displayed correctly

**Data Export and Import Flow**:
- ✅ Export all data to JSON file
- ✅ Verify export file created
- ✅ Verify export file contains all data
- ✅ Clear app data
- ✅ Import from JSON file
- ✅ Verify all data restored
- ✅ Verify relationships maintained (medications, logs, etc.)

### Error Handling Integration Tests

**Validation Error Flow**:
- ✅ Attempt to save invalid weight (< 20 kg)
- ✅ Verify validation error displayed
- ✅ Verify data not saved
- ✅ Correct validation error
- ✅ Verify save successful

**Database Error Flow**:
- ✅ Simulate database error (disk full, etc.)
- ✅ Verify error handled gracefully
- ✅ Verify user-friendly error message displayed
- ✅ Verify app does not crash

**Network Error Flow** (Post-MVP):
- ✅ Attempt to sync with no network
- ✅ Verify error handled gracefully
- ✅ Verify data queued for sync
- ✅ Verify sync retries when network available

### Google Fit Integration Tests

**GoogleFitDataSource Tests**:
- ✅ Request activity recognition permission
- ✅ Handle permission grant
- ✅ Fetch step count for today
- ✅ Verify step count retrieved correctly
- ✅ Fetch active minutes for today
- ✅ Verify active minutes retrieved correctly
- ✅ Fetch calories burned for today
- ✅ Verify calories retrieved correctly
- ✅ Handle permission denial gracefully
- ✅ Verify app continues to function without permission
- ✅ Handle API errors gracefully
- ✅ Verify error messages displayed to user

**Test Data Requirements**:
- Mock Google Fit API responses
- Various permission states (granted, denied, not requested)
- Network error scenarios

### Health Connect Integration Tests

**HealthConnectDataSource Tests**:
- ✅ Check Android version (API 34+)
- ✅ Verify Health Connect availability check
- ✅ Request Health Connect permissions
- ✅ Handle permission grant for specific data types
- ✅ Fetch steps data from Health Connect
- ✅ Verify data retrieved correctly
- ✅ Handle unavailable platform (Android < 14) gracefully
- ✅ Verify fallback to Google Fit
- ✅ Handle partial permission grants
- ✅ Verify app handles missing permissions gracefully

**Test Data Requirements**:
- Android version simulation (various API levels)
- Health Connect permission states
- Mock Health Connect API responses

## End-to-End Tests

### Critical User Flows

**Complete Health Tracking Flow**:
1. Launch app
2. Navigate to health tracking
3. Enter weight
4. Enter sleep/energy
5. View trends
6. Verify data persisted

**Complete Nutrition Flow**:
1. Navigate to nutrition
2. Log breakfast
3. Log lunch
4. View daily macros
5. Verify calculations

**Complete Exercise Flow**:
1. Navigate to exercise
2. Create workout plan
3. Log workout
4. View progress
5. Verify data persisted

## Test Data Requirements

### Fixtures Needed

- Health metrics (various dates, weights, sleep, energy)
- Meals (various meal types, macros)
- Exercises (various types, sets, reps, weights)
- Workout plans (various templates)
- Recipes (various categories, difficulties)
- User profiles (various configurations)

### Mock Data

- Mock LLM responses
- Mock Google Fit responses
- Mock network responses
- Mock database responses

## Coverage Targets

### Module Coverage

**Health Tracking**:
- Unit: 80% minimum (domain layer)
- Widget: 60% minimum (presentation layer)

**Nutrition**:
- Unit: 80% minimum (domain layer)
- Widget: 60% minimum (presentation layer)

**Exercise**:
- Unit: 80% minimum (domain layer)
- Widget: 60% minimum (presentation layer)

**Core**:
- Unit: 90%+ (utilities, calculations)

## Test Execution Order

1. Unit tests (fastest, run first)
2. Widget tests (medium speed)
3. Integration tests (slower, run before merge)
4. E2E tests (slowest, run on schedule)

## Continuous Integration

### Pre-commit Hooks

- Run unit tests
- Run widget tests
- Check coverage thresholds

### Pull Request Checks

- All tests must pass
- Coverage must meet thresholds
- No new untested code

### Release Checks

- All tests pass
- Integration tests pass
- E2E tests pass
- Performance benchmarks met

## References

- **Testing Strategy**: `artifacts/phase-4-testing/testing-strategy.md`
- **Feature Specs**: `artifacts/phase-2-features/`
- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Test Specifications Complete


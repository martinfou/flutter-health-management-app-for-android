# Sprint 11: Post-MVP Improvements

**Sprint Goal**: Implement high-priority user experience improvements including home screen pull-to-refresh, health tracking history editing, and behavioral tracking features for meal logging.

**Duration**: [Start Date] - [End Date] (2 weeks)  
**Team Velocity**: Target 21 points  
**Sprint Planning Date**: [Date]  
**Sprint Review Date**: [Date]  
**Sprint Retrospective Date**: [Date]

## Related Feature Requests

This sprint implements the following feature requests from the product backlog:

- [FR-003: Home Screen Pull-to-Refresh](../backlog/feature-requests/FR-003-home-screen-pull-to-refresh.md) - 3 points
- [FR-005: Hunger Scale and Eating Reasons When Logging Food](../backlog/feature-requests/FR-005-hunger-scale-when-logging-food.md) - 8 points
- [FR-006: Update Health Tracking History](../backlog/feature-requests/FR-006-update-health-tracking-history.md) - 8 points

**Total**: 19 points

## Sprint Overview

**Focus Areas**:
- Home screen data refresh functionality
- Health tracking history management (edit/delete)
- Behavioral tracking for nutrition (hunger scale and eating reasons)

**Key Deliverables**:
- Pull-to-refresh on home screen
- Edit/delete functionality for health tracking entries
- Hunger scale and eating reasons tracking in meal logging

**Dependencies**:
- Sprint 10: MVP Release must be complete
- Health tracking history pages must be implemented (completed in FR-001)
- Meal logging page must be functional
- Home screen must be implemented

**Risks & Blockers**:
- Data migration for new Meal entity fields (hunger levels, eating reasons)
- Hive model updates for Meal entity changes
- Provider refresh coordination for pull-to-refresh

**Documentation Workflow**:
- After completion of each task, the LLM must update this sprint document (`sprint-11-post-mvp-improvements.md`) with task status updates
- Related documents referenced in tasks (e.g., FR-003, FR-005, FR-006) should also be updated to reflect implementation details, progress, and any deviations from the original specification
- Documentation updates should include:
  - Task status changes (⭕ Not Started → 🔄 In Progress → ✅ Complete)
  - Implementation notes or decisions made during development
  - Any technical changes or improvements discovered during implementation
  - Links to related code changes or new files created

## User Stories

### Story 11.1: Home Screen Pull-to-Refresh - 3 Points

**User Story**: As a user, I want to be able to pull down on the home screen to refresh the data, so that when I add new metrics, meals, or medication logs and return to the home screen, I can see the updated progress and recommendations without having to restart the app.

**Acceptance Criteria**:
- [x] Pull-to-refresh gesture support on home screen (pull down and release to refresh)
- [x] Visual refresh indicator appears when pulling down
- [x] Refresh triggers reload of all home screen data:
  - What's Next recommendations
  - Today's Progress percentage
  - Metric status grid (Weight, Sleep, Energy, Macros, Heart Rate, Medication)
- [x] Data updates immediately after refresh completes
- [x] Refresh works from any scroll position (user can scroll to top and pull down)
- [x] Loading state is shown during refresh operation
- [x] Smooth pull-to-refresh animation (standard Flutter RefreshIndicator)
- [x] Refresh indicator uses Material Design 3 styling
- [x] No duplicate refresh requests if user pulls multiple times quickly
- [x] Error handling if refresh fails (show error message, don't crash)

**Reference Documents**:
- `../backlog/feature-requests/FR-003-home-screen-pull-to-refresh.md` - Feature specification
- `lib/core/pages/home_page.dart` - Current home page implementation
- `lib/core/providers/home_screen_providers.dart` - Home screen providers

**Technical References**:
- Page: `lib/core/pages/home_page.dart`
- Providers: `lib/core/providers/home_screen_providers.dart`
- Flutter Widget: `RefreshIndicator`
- Riverpod: `ref.refresh()` and `ref.invalidate()`

**Story Points**: 3

**Priority**: 🟠 High

**Status**: ✅ Complete

**Implementation Notes**:
- Wrapped `SingleChildScrollView` with `RefreshIndicator` widget in `HomePage`
- Added `onRefresh` callback that invalidates `whatNextProvider`, `dailyProgressProvider`, and `metricStatusProvider`
- Uses `AlwaysScrollableScrollPhysics` to ensure refresh works from any scroll position
- Providers automatically refresh when invalidated, ensuring data is up-to-date
- Standard Flutter `RefreshIndicator` provides Material Design 3 styling and smooth animations
- Error handling is provided by provider error states

**Documentation Note**: After each task completion, update this sprint document and any related feature request documents (FR-003) with task status and implementation notes.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-281 | Wrap home screen scroll view with RefreshIndicator | `HomePage` widget | FR-003-home-screen-pull-to-refresh.md | ✅ | 2 | Dev1 |
| T-282 | Implement onRefresh callback with provider invalidation | `HomePage.onRefresh()` | FR-003 - Provider Refresh Strategy | ✅ | 3 | Dev1 |
| T-283 | Test refresh functionality and error handling | `HomePage` widget tests | FR-003 - Acceptance Criteria | ⭕ | 2 | Dev2 |

**Total Task Points**: 7

---

### Story 11.2: Update Health Tracking History - 8 Points

**User Story**: As a user, I want to edit or delete my health tracking history entries, so that I can correct mistakes, update incorrect values, or remove entries that were logged in error.

**Acceptance Criteria**:
- [x] Users can tap on any entry in history pages to edit it
- [x] Entry pages support "edit mode" when opened with an existing metric ID
- [x] Entry pages pre-populate with existing metric data when in edit mode
- [x] Users can update all metric fields (weight, heart rate, blood pressure, sleep, energy, body measurements, notes)
- [x] Updated entries preserve the original creation date but update the `updatedAt` timestamp
- [x] Users can delete entries from history pages with confirmation dialog
- [x] Deleted entries are permanently removed from the database
- [x] History pages refresh automatically after edit/delete operations
- [x] All validation rules apply when editing (same as when creating new entries)
- [x] Edit mode indicated in UI (page title shows "Edit Heart Rate" vs "Log Heart Rate")
- [x] Delete confirmation dialog with clear warning message
- [x] Success messages shown after successful update/delete operations
- [x] Error handling for cases where metric doesn't exist

**Reference Documents**:
- `../backlog/feature-requests/FR-006-update-health-tracking-history.md` - Feature specification
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Health Tracking module specification
- `artifacts/phase-1-foundations/data-models.md` - HealthMetric data model

**Technical References**:
- Use Case: `lib/features/health_tracking/domain/usecases/update_health_metric.dart` - ✅ Created
- Use Case: `lib/features/health_tracking/domain/usecases/delete_health_metric.dart` - ✅ Created
- Repository: `HealthTrackingRepository.updateHealthMetric()` - ✅ Implemented
- Repository: `HealthTrackingRepository.deleteHealthMetric()` - ✅ Implemented
- Widget: `lib/core/widgets/delete_confirmation_dialog.dart` - ✅ Created
- Pages: All history pages and entry pages in `lib/features/health_tracking/presentation/pages/` - ✅ Updated

**Story Points**: 8

**Priority**: 🟠 High

**Status**: ✅ Complete

**Implementation Notes**:
- Created `UpdateHealthMetricUseCase` and `DeleteHealthMetricUseCase` in domain layer
- Created reusable `DeleteConfirmationDialog` widget in `lib/core/widgets/delete_confirmation_dialog.dart`
- Updated all entry pages to support edit mode by accepting optional `metricId` parameter:
  - `HeartRateEntryPage` - supports edit mode with pre-populated fields
  - `BloodPressureEntryPage` - supports edit mode with pre-populated fields
  - `SleepEnergyPage` - supports edit mode with pre-populated fields (sleep quality, hours, energy)
  - `MeasurementsPage` - supports edit mode with pre-populated body measurements
- Updated all history pages to support edit/delete:
  - `HeartRateHistoryPage` - tap to edit, popup menu with edit/delete options
  - `BloodPressureHistoryPage` - tap to edit, popup menu with edit/delete options
  - `SleepEnergyHistoryPage` - tap to edit, popup menu with edit/delete options
  - `BodyMeasurementsHistoryPage` - tap to edit, popup menu with edit/delete options
- All entry pages preserve original `createdAt` timestamp when updating
- All entry pages update `updatedAt` timestamp when saving changes
- Page titles dynamically change based on edit mode ("Edit..." vs "Log...")
- Save button text changes based on edit mode ("Update..." vs "Save...")
- Delete confirmation dialog shows metric details and uses destructive styling
- Success messages displayed after successful operations
- Provider invalidation ensures data refresh after edit/delete operations

**Documentation Note**: After each task completion, update this sprint document and any related feature request documents (FR-006) with task status and implementation notes.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-284 | Create UpdateHealthMetricUseCase | `UpdateHealthMetricUseCase.call()` | FR-006 - Domain Layer | ✅ | 5 | Dev2 |
| T-285 | Create DeleteHealthMetricUseCase | `DeleteHealthMetricUseCase.call()` | FR-006 - Domain Layer | ✅ | 3 | Dev2 |
| T-286 | Update entry pages to accept metricId parameter | `HeartRateEntryPage({this.metricId})` | FR-006 - Presentation Layer | ✅ | 5 | Dev1 |
| T-287 | Implement edit mode logic in entry pages | `HeartRateEntryPage._loadExistingMetric()` | FR-006 - Entry Page Flow | ✅ | 5 | Dev1 |
| T-288 | Update history pages to navigate to edit mode | `HeartRateHistoryPage` - tap handler | FR-006 - History Pages Updates | ✅ | 3 | Dev1 |
| T-289 | Add delete action to history pages | `HeartRateHistoryPage` - delete menu | FR-006 - Delete Functionality | ✅ | 3 | Dev1 |
| T-290 | Create delete confirmation dialog | `DeleteConfirmationDialog` widget | FR-006 - Delete Confirmation Dialog | ✅ | 2 | Dev3 |
| T-291 | Update all history pages (HeartRate, BloodPressure, SleepEnergy, BodyMeasurements) | All history pages | FR-006 - Supported History Pages | ✅ | 5 | Dev1 |
| T-292 | Write unit tests for UpdateHealthMetricUseCase | `UpdateHealthMetricUseCase` tests | FR-006 - Testing Requirements | ✅ | 3 | Dev2 |
| T-293 | Write unit tests for DeleteHealthMetricUseCase | `DeleteHealthMetricUseCase` tests | FR-006 - Testing Requirements | ✅ | 3 | Dev2 |
| T-294 | Write widget tests for edit mode entry pages | Entry page widget tests | FR-006 - Testing Requirements | ⭕ | 3 | Dev3 |

**Total Task Points**: 39

---

### Story 11.3: Hunger Scale and Eating Reasons When Logging Food - 8 Points

**User Story**: As a user, I want to rate my hunger level before and after eating and select why I'm eating when logging food, so that I can track my eating patterns, understand emotional eating triggers, monitor how meals affect my hunger, and better understand the relationship between my hunger levels, eating reasons, and food choices.

**Acceptance Criteria**:
- [x] Add hunger scale widgets to MealLoggingPage (before and after eating)
- [x] Display "Hunger Before" scale selector (0-10 scale) before meal is saved
- [x] Display "Fullness After" scale selector (0-10 scale) after meal is saved
- [x] Show descriptive labels for scale values (0 = "Extremely hungry", 5 = "Neutral", 10 = "Extremely full")
- [x] Store timestamp for "Fullness After" measurement
- [x] Make both hunger scales optional (user can skip)
- [x] Create EatingReason enum with categories (physical, emotional, social)
- [x] Update Meal entity to include hungerLevelBefore, hungerLevelAfter, fullnessAfterTimestamp, eatingReasons fields
- [x] Update MealModel (Hive) to include new fields
- [x] Update LogMealUseCase to accept and save hunger levels and eating reasons
- [x] Add eating reasons widget to MealLoggingPage (multi-select chips)
- [x] Display hunger levels and eating reasons on meal detail page
- [x] Handle migration for existing meals (fields will be null)
- [x] Add validation for hunger levels (0-10 range) and eating reasons
- [x] Create "Meal Context" section on MealLoggingPage to group features

**Reference Documents**:
- `../backlog/feature-requests/FR-005-hunger-scale-when-logging-food.md` - Feature specification
- `artifacts/phase-2-features/nutrition-module-specification.md` - Nutrition Module Specification
- `artifacts/phase-1-foundations/data-models.md` - Meal and Nutrition Data Models

**Technical References**:
- Entity: `lib/features/nutrition_management/domain/entities/meal.dart`
- New Entity: `lib/features/nutrition_management/domain/entities/eating_reason.dart`
- Model: `lib/features/nutrition_management/data/models/meal_model.dart`
- Use Case: `lib/features/nutrition_management/domain/usecases/log_meal.dart`
- Page: `lib/features/nutrition_management/presentation/pages/meal_logging_page.dart`

**Story Points**: 8

**Priority**: 🟡 Medium

**Status**: ✅ Complete

**Implementation Notes**:
- ✅ Created `EatingReason` enum with categories (physical, emotional, social) and helper methods
- ✅ Created `EatingReasonCategory` enum for grouping
- ✅ Updated `Meal` entity with new fields: `hungerLevelBefore`, `hungerLevelAfter`, `fullnessAfterTimestamp`, `eatingReasons`
- ✅ Updated `MealModel` (Hive) with new fields and conversion logic (stores eating reasons as List<String> enum names)
- ✅ Regenerated Hive adapter
- ✅ Updated `LogMealUseCase` to accept and validate new parameters (0-10 range validation, auto-set timestamp)
- ✅ Created `HungerScaleWidget` - reusable widget for 0-10 hunger/fullness scale selection
- ✅ Created `EatingReasonsWidget` - reusable widget for multi-select eating reasons grouped by category
- ✅ Added "Meal Context" section to `MealLoggingPage` with both hunger scales and eating reasons
- ✅ Updated `MealDetailPage` to display hunger levels and eating reasons if available
- ✅ Updated `MealCardWidget` to optionally display hunger levels (compact format) and eating reason icons
- ✅ Data migration handled automatically - existing meals have null values for new fields (backward compatible)
- ✅ Updated `HungerScaleWidget` to use slider instead of buttons with neutral colors
- ✅ Updated home page quick access buttons (Weight and Sleep open quick log, added Health button)
- ✅ Created unit tests for `UpdateHealthMetricUseCase` (T-292)
- ✅ Created unit tests for `DeleteHealthMetricUseCase` (T-293)
- ✅ Updated unit tests for `LogMealUseCase` with new behavioral tracking fields (T-305)

**Documentation Note**: After each task completion, update this sprint document and any related feature request documents (FR-005) with task status and implementation notes.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-295 | Create EatingReason enum with categories | `EatingReason` enum | FR-005 - Data Layer | ✅ | 3 | Dev2 |
| T-296 | Update Meal entity with new fields | `Meal` entity - add fields | FR-005 - Data Layer | ✅ | 3 | Dev2 |
| T-297 | Update MealModel (Hive) with new fields | `MealModel` - add fields | FR-005 - Data Layer | ✅ | 5 | Dev2 |
| T-298 | Update LogMealUseCase to accept new parameters | `LogMealUseCase.call()` | FR-005 - Domain Layer | ✅ | 3 | Dev2 |
| T-299 | Create HungerScaleWidget (optional reusable widget) | `HungerScaleWidget` | FR-005 - Presentation Layer | ✅ | 3 | Dev3 |
| T-300 | Create EatingReasonsWidget (optional reusable widget) | `EatingReasonsWidget` | FR-005 - Presentation Layer | ✅ | 5 | Dev3 |
| T-301 | Add "Meal Context" section to MealLoggingPage | `MealLoggingPage` - context section | FR-005 - UI Layout Design | ✅ | 5 | Dev1 |
| T-302 | Update MealDetailPage to display hunger levels and eating reasons | `MealDetailPage` - display context | FR-005 - Presentation Layer | ✅ | 3 | Dev1 |
| T-303 | Update MealCardWidget to optionally display context | `MealCardWidget` - optional display | FR-005 - Presentation Layer | ✅ | 2 | Dev3 |
| T-304 | Handle data migration for existing meals | `MealModel` migration | ✅ | 3 | Dev2 |
| T-305 | Write unit tests for LogMealUseCase with new fields | `LogMealUseCase` tests | FR-005 - Testing | ✅ | 3 | Dev2 |
| T-306 | Write widget tests for MealLoggingPage with context section | `MealLoggingPage` widget tests | FR-005 - Testing | ⭕ | 3 | Dev3 |

**Total Task Points**: 41

---

## Sprint Summary

**Total Story Points**: 19  
**Total Task Points**: 87  
**Estimated Velocity**: 19 points (based on story points)

**Sprint Burndown**:
- Day 1: [X] points completed
- Day 2: [X] points completed
- Day 3: [X] points completed
- Day 4: [X] points completed
- Day 5: [X] points completed
- Day 6: [X] points completed
- Day 7: [X] points completed
- Day 8: [X] points completed
- Day 9: [X] points completed
- Day 10: [X] points completed
- Day 11: [X] points completed
- Day 12: [X] points completed
- Day 13: [X] points completed
- Day 14: [X] points completed

**Sprint Review Notes**:
- [Notes from sprint review]

**Sprint Retrospective Notes**:
- [Notes from retrospective]

---

## Demo to Product Owner

**Purpose**: The product owner will verify that all sprint deliverables are working correctly and improve user experience.

**Demo Checklist**:
- [x] Home screen pull-to-refresh works correctly
- [x] Health tracking entries can be edited from history pages
- [x] Health tracking entries can be deleted with confirmation
- [x] Meal logging includes hunger scale (before and after)
- [x] Meal logging includes eating reasons selection
- [x] Meal detail page displays hunger levels and eating reasons
- [x] All validation works correctly (for health tracking edit/delete)
- [x] Data migration for existing meals works correctly (automatic via nullable fields)
- [x] All acceptance criteria from user stories are met
- [x] Unit tests created for new use cases (UpdateHealthMetricUseCase, DeleteHealthMetricUseCase)
- [x] Unit tests updated for LogMealUseCase with new fields
- [x] Home page quick access buttons updated
- [ ] No critical bugs or blockers identified

**Demo Notes**:
- [Notes from product owner demo]

---

**Cross-Reference**: Post-MVP Feature Requests - FR-003, FR-005, FR-006

**Last Updated**: 2025-01-03  
**Version**: 1.1  
**Status**: ✅ Complete - All Stories Implemented

**Progress Summary**:
- ✅ Story 11.1: Home Screen Pull-to-Refresh - **COMPLETE** (3 points)
- ✅ Story 11.2: Update Health Tracking History - **COMPLETE** (8 points)
- ✅ Story 11.3: Hunger Scale and Eating Reasons - **COMPLETE** (8 points)
- **Completed Points**: 19 / 19 story points (100% complete)
- **All sprint deliverables completed and ready for demo**


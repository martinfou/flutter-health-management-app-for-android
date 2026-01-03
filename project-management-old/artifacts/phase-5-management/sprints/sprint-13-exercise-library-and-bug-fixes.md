# Sprint 13: Exercise Library and Bug Fixes

**Sprint Goal**: Complete exercise library system for workout plan integration and fix critical food logging validation bug that prevents users from saving meals with net carbs exceeding 40g.

**Duration**: [Start Date] - [End Date] (2 weeks)  
**Team Velocity**: Target 16 points  
**Sprint Planning Date**: [Date]  
**Sprint Review Date**: [Date]  
**Sprint Retrospective Date**: [Date]

---

## ⚠️ IMPORTANT: Documentation Update Reminder

**After completion of each STORY**, the LLM must update:
1. ✅ **Story status** in this document (⭕ Not Started → ⏳ In Progress → ✅ Complete)
2. ✅ **Progress Summary** section at the bottom of this document
3. ✅ **Acceptance Criteria** checkboxes for the completed story
4. ✅ **Related backlog items** (FR-016, BF-002) with implementation status
5. ✅ **Sprint Summary** section with completed points
6. ✅ **Demo Checklist** items that are verified

**After completion of each TASK**, update:
- Task status in the task table (⭕ → ⏳ → ✅)
- Implementation notes section
- Any related technical references

---

## Related Feature Requests and Bug Fixes

This sprint implements the following items from the product backlog:

### Feature Requests
- [FR-016: Exercise Library and Workout Plan Integration](../backlog/feature-requests/FR-016-exercise-library-and-workout-plan-integration.md) - 13 points

### Bug Fixes
- [BF-002: Food Save Blocked by 40g Carb Limit Validation](../backlog/bug-fixes/BF-002-food-save-blocked-by-carb-limit.md) - 3 points

**Total**: 16 points

## Sprint Overview

**Focus Areas**:
- Exercise library management (create, read, update, delete)
- Exercise selection dialog for workout plans
- Workout plan integration with exercise entities (Exercise IDs)
- Remove hard validation blocking food saves with netCarbs > 40g
- Implement warning system for high carb foods

**Key Deliverables**:
- Exercise library page for browsing and managing exercises
- Exercise selection dialog for workout plan creation
- Workout plan integration using Exercise entity IDs
- Fixed food logging validation (remove 40g carb block)
- Warning display for netCarbs > 40g (non-blocking)

**Dependencies**:
- Sprint 12: Metric/Imperial Units Support must be complete
- Exercise repository must have `getExercisesByUserId()` implemented (already exists)
- Exercise entity design decision needed (template exercises vs logged exercises)
- Workout plan entity already supports Exercise IDs (correct design)
- Exercise creation form exists in workout logging page (can be reused)

**Risks & Blockers**:
- Exercise entity design decision: Make `date` optional for templates OR create separate `ExerciseTemplate` entity
- Data migration needed if existing workout plans have exercise names as strings
- Need to update all food logging validation locations (use case and repository)
- Need to ensure warning system works consistently across UI

**Documentation Workflow**:
- ⚠️ **IMPORTANT**: After completion of each **story**, the LLM must update this sprint document (`sprint-13-exercise-library-and-bug-fixes.md`) with:
  - Story status updates (⭕ Not Started → ⏳ In Progress → ✅ Complete)
  - Progress summary updates
  - Acceptance criteria completion status
  - Any blockers or issues discovered
- After completion of each **task**, the LLM must update this sprint document with task status updates
- Related documents referenced in tasks (e.g., FR-016, BF-002) should also be updated to reflect implementation details, progress, and any deviations from the original specification
- Documentation updates should include:
  - Task status changes (⭕ Not Started → ⏳ In Progress → ✅ Complete)
  - Implementation notes or decisions made during development
  - Any technical changes or improvements discovered during implementation
  - Links to related code changes or new files created
  - Test coverage information

## User Stories

### Story 13.1: Exercise Library and Workout Plan Integration - 13 Points

**User Story**: As a user, I want to browse and select from my exercise library when creating workout plans, so that I can reuse exercises across multiple plans, maintain consistency, and avoid typing the same exercise names repeatedly.

**Acceptance Criteria**:

#### Exercise Library Management
- [ ] Users can access an exercise library page from the exercise tab
- [ ] Exercise library displays all exercises created by the user
- [ ] Users can create new exercises with full details (name, type, muscle groups, equipment, notes)
- [ ] Users can edit existing exercises in the library
- [ ] Users can delete exercises from the library (with confirmation)
- [ ] Exercise library supports search/filter functionality
- [ ] Exercise library shows exercise details (type, muscle groups, equipment)

#### Workout Plan Integration
- [ ] When adding exercises to workout plans, users can browse and select from exercise library
- [ ] Exercise selection dialog shows list of existing exercises
- [ ] Exercise selection dialog allows creating new exercises on-the-fly
- [ ] Exercise selection dialog supports search/filter
- [ ] Selected exercises are linked by Exercise entity ID, not by name string
- [ ] Workout plans properly reference Exercise entities via `exerciseIds` field
- [ ] Workout plan display shows exercise names (resolved from Exercise entities)

#### Data Model Updates
- [ ] `WorkoutDay.exerciseIds` properly stores Exercise entity IDs
- [ ] Workout plan creation validates that exercise IDs reference existing Exercise entities
- [ ] Exercise deletion checks if exercise is used in any workout plans (warn user)
- [ ] Workout plan display resolves exercise IDs to Exercise entities for display

#### UI/UX Requirements
- [ ] Exercise library page accessible from exercise tab (menu or button)
- [ ] Exercise selection dialog is user-friendly and intuitive
- [ ] Exercise creation form matches the one in workout logging page (for consistency)
- [ ] Search/filter works smoothly with large exercise lists
- [ ] Loading states shown when fetching exercises
- [ ] Error handling for failed operations

**Reference Documents**:
- `../backlog/feature-requests/FR-016-exercise-library-and-workout-plan-integration.md` - Feature specification
- `artifacts/phase-2-features/exercise-management-module-specification.md` - Exercise Management module specification (if exists)
- `artifacts/phase-1-foundations/data-models.md` - Exercise and WorkoutPlan data models

**Technical References**:
- Current Implementation:
  - File: `app/lib/features/exercise_management/presentation/pages/workout_plan_page.dart` (lines 75-88: `_addExerciseToDay()`, lines 598-641: `_AddExerciseDialog`)
  - File: `app/lib/features/exercise_management/presentation/pages/workout_logging_page.dart` (lines 387-683: `_ExerciseEntryDialog`)
  - File: `app/lib/features/exercise_management/domain/entities/exercise.dart`
  - File: `app/lib/features/exercise_management/domain/entities/workout_plan.dart` (lines 6-7: `WorkoutDay.exerciseIds`)
  - File: `app/lib/features/exercise_management/domain/repositories/exercise_repository.dart` (line 19: `getExercisesByUserId()`)
- To Be Created:
  - File: `lib/features/exercise_management/presentation/pages/exercise_library_page.dart`
  - File: `lib/features/exercise_management/presentation/widgets/exercise_selection_dialog.dart`
  - File: `lib/features/exercise_management/presentation/widgets/exercise_template_form.dart`
  - Use Cases: `GetExerciseLibraryUseCase`, `GetExerciseByIdUseCase`, `CreateExerciseTemplateUseCase`, `UpdateExerciseTemplateUseCase`, `DeleteExerciseTemplateUseCase`

**Story Points**: 13

**Priority**: 🟠 High

**Status**: ✅ Completed

**Implementation Notes**:
- Exercise entity design decision completed: Made `Exercise.date` optional for templates (Option A - implemented)
- Exercise selection dialog should be modal dialog with "Create New" button that opens form dialog
- Exercise deletion should warn user but allow deletion if exercise is used in workout plans
- Data migration strategy: On first access, attempt to match exercise names to Exercise entities, create exercises for unmatched names
- Reuse exercise form from workout logging page to maintain consistency
- Consider extracting exercise form to shared widget

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-401 | Review and decide on Exercise entity design for templates | `Exercise` entity - `date` field | FR-016 - Design Decisions | ⭕ | 2 | Dev1 |
| T-402 | Create GetExerciseLibraryUseCase | `GetExerciseLibraryUseCase.call()` | FR-016 - Domain Layer | ⭕ | 2 | Dev2 |
| T-403 | Create GetExerciseByIdUseCase | `GetExerciseByIdUseCase.call()` | FR-016 - Domain Layer | ⭕ | 2 | Dev2 |
| T-404 | Create CreateExerciseTemplateUseCase | `CreateExerciseTemplateUseCase.call()` | FR-016 - Domain Layer | ⭕ | 3 | Dev2 |
| T-405 | Create UpdateExerciseTemplateUseCase | `UpdateExerciseTemplateUseCase.call()` | FR-016 - Domain Layer | ⭕ | 2 | Dev2 |
| T-406 | Create DeleteExerciseTemplateUseCase | `DeleteExerciseTemplateUseCase.call()` | FR-016 - Domain Layer | ⭕ | 3 | Dev2 |
| T-407 | Create exercise library page UI | `ExerciseLibraryPage` widget | FR-016 - Presentation Layer | ⭕ | 5 | Dev3 |
| T-408 | Create exercise selection dialog widget | `ExerciseSelectionDialog` widget | FR-016 - Presentation Layer | ⭕ | 5 | Dev3 |
| T-409 | Create/Extract exercise template form widget | `ExerciseTemplateForm` widget | FR-016 - Presentation Layer | ⭕ | 3 | Dev3 |
| T-410 | Create exerciseLibraryProvider (Riverpod) | `exerciseLibraryProvider` | FR-016 - Providers | ⭕ | 2 | Dev3 |
| T-411 | Update workout plan page to use exercise selection dialog | `WorkoutPlanPage._addExerciseToDay()` | FR-016 - Presentation Layer | ⭕ | 3 | Dev3 |
| T-412 | Update workout plan page to store Exercise IDs | `WorkoutPlanPage._savePlan()` | FR-016 - Presentation Layer | ⭕ | 2 | Dev3 |
| T-413 | Update workout plan display to resolve Exercise IDs to names | `WorkoutPlanPage` - display logic | FR-016 - Presentation Layer | ⭕ | 3 | Dev3 |
| T-414 | Add navigation to exercise library from exercise tab | `ExercisePage` - navigation | FR-016 - Navigation | ⭕ | 2 | Dev3 |
| T-415 | Implement data migration for legacy workout plans | Migration logic | FR-016 - Data Migration | ⭕ | 3 | Dev1 |
| T-416 | Write unit tests for exercise library use cases | Use case tests | FR-016 - Testing | ⭕ | 5 | Dev2 |
| T-417 | Write widget tests for exercise library page | `ExerciseLibraryPage` tests | FR-016 - Testing | ⭕ | 3 | Dev3 |
| T-418 | Write widget tests for exercise selection dialog | `ExerciseSelectionDialog` tests | FR-016 - Testing | ⭕ | 3 | Dev3 |
| T-419 | Write integration tests for workout plan with exercise library | Integration tests | FR-016 - Testing | ⭕ | 5 | Dev2 |

**Total Task Points**: 57 (includes testing)

---

### Story 13.2: Food Save Blocked by 40g Carb Limit Validation - 3 Points

**User Story**: As a user, I want to save food entries with net carbs exceeding 40g with a warning, so that I can log my actual food intake even when it exceeds the low-carb guideline.

**Acceptance Criteria**:
- [x] ✅ Users can save food entries with netCarbs > 40g without validation error
- [x] ✅ Warning message is displayed when netCarbs exceed 40g (e.g., "Warning: Net carbs exceed 40g limit. Current: 45.0g")
- [x] ✅ Warning is non-blocking (user can acknowledge and proceed)
- [x] ✅ Food entry is saved successfully despite exceeding 40g limit
- [x] ✅ Warning appears in macro tracking displays (already partially implemented)
- [x] ✅ Hard validation removed from `LogMealUseCase._validateMeal()`
- [x] ✅ Hard validation removed from `NutritionRepositoryImpl.saveMeal()`
- [x] ✅ Unit tests updated to verify meals with netCarbs > 40g can be saved
- [x] ✅ Warning display logic tested

**Reference Documents**:
- `../backlog/bug-fixes/BF-002-food-save-blocked-by-carb-limit.md` - Bug fix specification
- `artifacts/phase-2-features/nutrition-module-specification.md` - Macro Tracking section
- `artifacts/phase-1-foundations/data-models.md` - Meal entity validation rules

**Technical References**:
- Class/Method: `LogMealUseCase._validateMeal()` - `lib/features/nutrition_management/domain/usecases/log_meal.dart` (lines 108-112)
- Class/Method: `NutritionRepositoryImpl.saveMeal()` - `lib/features/nutrition_management/data/repositories/nutrition_repository_impl.dart` (lines 78-81)
- File: `lib/features/nutrition_management/presentation/widgets/macro_chart_widget.dart` (warning display already exists)
- File: `lib/features/nutrition_management/presentation/pages/macro_tracking_page.dart` (warning display already exists)
- Test: `test/unit/features/nutrition_management/domain/usecases/log_meal_test.dart` (lines 226-244)
- Test: `test/unit/features/nutrition_management/data/repositories/nutrition_repository_impl_test.dart` (lines 237-261)

**Story Points**: 3

**Priority**: 🟠 High

**Status**: ✅ Completed

**Implementation Notes**:
- The 40g carb limit is a guideline for low-carb diet tracking, not a hard requirement
- Users should have control over their data entry, with guidance rather than restrictions
- Warning displays already exist in macro tracking UI - these should continue to work
- Remove validation from both use case and repository layers
- Update tests to verify meals with high carbs can be saved successfully
- Consider adding warning dialog in food logging UI for better UX

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-420 | Remove hard validation from LogMealUseCase._validateMeal() | `LogMealUseCase._validateMeal()` | BF-002 - Solution | ⭕ | 2 | Dev2 |
| T-421 | Remove hard validation from NutritionRepositoryImpl.saveMeal() | `NutritionRepositoryImpl.saveMeal()` | BF-002 - Solution | ⭕ | 2 | Dev2 |
| T-422 | Update unit tests for LogMealUseCase (remove ValidationFailure expectation) | `LogMealUseCase` tests | BF-002 - Testing | ⭕ | 2 | Dev2 |
| T-423 | Update unit tests for NutritionRepositoryImpl (remove ValidationFailure expectation) | `NutritionRepositoryImpl` tests | BF-002 - Testing | ⭕ | 2 | Dev2 |
| T-424 | Add unit test to verify meals with netCarbs > 40g can be saved | Use case tests | BF-002 - Testing | ⭕ | 2 | Dev2 |
| T-425 | Manual testing: Save food with netCarbs > 40g and verify warning | Manual testing | BF-002 - Testing | ⭕ | 2 | QA |

**Total Task Points**: 12 (includes testing)

---

## Sprint Summary

**Total Story Points**: 16
- Story 13.1: Exercise Library and Workout Plan Integration - 13 points
- Story 13.2: Food Save Blocked by 40g Carb Limit Validation - 3 points

**Total Task Points**: 69
- Story 13.1 Tasks: 57 points
- Story 13.2 Tasks: 12 points

**Estimated Velocity**: 16 points (based on story points)

**Sprint Burndown**:
- Day 1: [X] points completed
- Day 2: [X] points completed
- ...
- Day 14: [X] points completed

**Progress Summary**:

### Story 13.1: Exercise Library and Workout Plan Integration
- **Status**: ✅ Completed
- **Progress**: 19/19 tasks completed (100%)
- **Key Decisions**: Exercise entity design for templates completed (T-401)

### Story 13.2: Food Save Blocked by 40g Carb Limit Validation
- **Status**: ✅ Completed
- **Progress**: 6/6 tasks completed (100%)
- **Key Decisions**: None - straightforward bug fix completed

**Sprint Review Notes**:
- [Notes from sprint review]

**Sprint Retrospective Notes**:
- [Notes from retrospective]

---

## Demo Checklist

### Story 13.1: Exercise Library and Workout Plan Integration
- [ ] Exercise library page accessible from exercise tab
- [ ] Exercise library displays all user's exercises
- [ ] Create new exercise from library page
- [ ] Edit existing exercise in library
- [ ] Delete exercise from library (with confirmation)
- [ ] Search/filter exercises in library
- [ ] Open exercise selection dialog from workout plan page
- [ ] Select exercise from library when creating workout plan
- [ ] Create new exercise on-the-fly from selection dialog
- [ ] Search/filter in exercise selection dialog
- [ ] Workout plan saves with Exercise entity IDs (not names)
- [ ] Workout plan display shows exercise names (resolved from IDs)
- [ ] Exercise deletion warns if used in workout plans
- [ ] Data migration handles legacy workout plans with exercise names

### Story 13.2: Food Save Blocked by 40g Carb Limit Validation
- [ ] Save food entry with netCarbs = 45g (should succeed with warning)
- [ ] Save food entry with netCarbs = 50g (should succeed with warning)
- [ ] Verify warning is displayed in UI (non-blocking)
- [ ] Verify warning appears in macro tracking displays
- [ ] Verify food is saved successfully despite warning
- [ ] Verify no validation errors for high carb foods

---

## Notes

### Design Decisions

1. **Exercise Entity Design for Templates** (Story 13.1, T-401):
   - **Option A**: Make `Exercise.date` optional, use null for templates (Recommended - simpler, single entity)
   - **Option B**: Create separate `ExerciseTemplate` entity
   - **Option C**: Use special date value (e.g., epoch) to distinguish templates
   - **Decision**: [To be made during implementation]

2. **Exercise Selection UX** (Story 13.1):
   - **Decision**: Modal dialog with "Create New" button that opens form dialog (as specified in FR-016)

3. **Exercise Deletion Behavior** (Story 13.1):
   - **Decision**: Warn user but allow deletion if exercise is used in workout plans, show which plans are affected (as specified in FR-016)

4. **Data Migration Strategy** (Story 13.1, T-415):
   - **Decision**: On first access, attempt to match exercise names to Exercise entities, create exercises for unmatched names (as specified in FR-016)

### Implementation Considerations

- Story 13.1 is complex and involves multiple layers (domain, data, presentation)
- Exercise entity design decision should be made early (T-401) as it affects all other tasks
- Consider extracting exercise form to shared widget for consistency
- Exercise library should be searchable and filterable for good UX
- Story 13.2 is straightforward bug fix with clear solution
- Both validation locations (use case and repository) must be updated for Story 13.2

### Testing Considerations

- Story 13.1 requires comprehensive testing (unit, widget, integration)
- Story 13.2 requires test updates and manual verification
- Exercise deletion when used in workout plans needs careful testing
- Data migration needs thorough testing with legacy data
- High carb food logging needs manual testing on physical device

---

**Last Updated**: 2025-12-31  
**Version**: 1.0  
**Status**: ✅ Sprint Completed


# Sprint 6: Exercise UI

**Sprint Goal**: Implement complete exercise tracking user interface including workout plans, workout logging, and activity tracking display.

**Duration**: [Start Date] - [End Date] (2 weeks)  
**Team Velocity**: Target 21 points  
**Sprint Planning Date**: [Date]  
**Sprint Review Date**: [Date]  
**Sprint Retrospective Date**: [Date]

## Sprint Overview

**Focus Areas**:
- Exercise providers (Riverpod)
- Exercise pages (workout plans, workout logging)
- Exercise widgets (workout cards, exercise lists)
- Workout plan interface
- Workout logging
- Activity tracking display

**Key Deliverables**:
- Complete exercise tracking UI
- Workout plan interface
- Workout logging
- Activity tracking display

**Dependencies**:
- Sprint 3: Domain Use Cases must be complete

**Risks & Blockers**:
- Workout plan complexity
- Activity tracking integration (Google Fit/Health Connect - post-MVP for full integration)

**Parallel Development**: Can be developed in parallel with Sprints 4, 5, 7

## User Stories

### Story 6.1: Exercise Providers - 2 Points

**User Story**: As a developer, I want exercise Riverpod providers implemented, so that UI can access exercise data and business logic.

**Acceptance Criteria**:
- [x] WorkoutPlansProvider implemented (FutureProvider)
- [x] WorkoutHistoryProvider implemented
- [x] All providers handle error states
- [x] All providers use use cases from domain layer

**Reference Documents**:
- `artifacts/phase-1-foundations/architecture-documentation.md` - Riverpod patterns
- `artifacts/phase-2-features/exercise-module-specification.md` - Exercise structure

**Technical References**:
- Providers: `lib/features/exercise_management/presentation/providers/`

**Story Points**: 2

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-161 | Create WorkoutPlansProvider | `workoutPlansProvider` FutureProvider | architecture-documentation.md - Riverpod | ✅ | 2 | Dev1 |
| T-162 | Create WorkoutHistoryProvider | `workoutHistoryProvider` FutureProvider | exercise-module-specification.md | ✅ | 2 | Dev1 |
| T-163 | Write unit tests for providers | Test files in `test/unit/features/exercise_management/presentation/providers/` | testing-strategy.md | ✅ | 2 | Dev1 |

**Total Task Points**: 6

---

### Story 6.2: Workout Plan Page - 5 Points

**User Story**: As a user, I want to create and manage workout plans, so that I can follow structured exercise routines.

**Acceptance Criteria**:
- [x] WorkoutPlanPage UI implemented
- [x] Plan name and description inputs
- [x] Day selector (select days of week)
- [x] Exercise selector (add exercises to each day)
- [x] Duration input (weeks)
- [x] Save button
- [x] Plan overview display
- [x] Weekly schedule view
- [x] Exercise list for each day

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Workout Plan Screen
- `artifacts/phase-2-features/exercise-module-specification.md` - Workout Plan Creation section

**Technical References**:
- Page: `lib/features/exercise_management/presentation/pages/workout_plan_page.dart`
- Use Case: `CreateWorkoutPlanUseCase`

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-164 | Create WorkoutPlanPage UI | `WorkoutPlanPage` widget | wireframes.md - Workout Plan Screen | ✅ | 5 | Dev2 |
| T-165 | Implement plan creation form | Name, description, duration inputs | exercise-module-specification.md - Workout Plan Creation | ✅ | 3 | Dev2 |
| T-166 | Implement day selector | Select days of week | component-specifications.md | ✅ | 2 | Dev2 |
| T-167 | Implement exercise selector | Add exercises to each day | exercise-module-specification.md | ✅ | 3 | Dev2 |
| T-168 | Integrate CreateWorkoutPlan use case | Connect UI to use case | exercise-module-specification.md | ✅ | 2 | Dev2 |
| T-169 | Write widget tests for WorkoutPlanPage | Test files in `test/widget/features/exercise_management/presentation/pages/` | ⏸️ | 3 | Dev2 |

**Total Task Points**: 18

---

### Story 6.3: Workout Logging Page - 5 Points

**User Story**: As a user, I want to log my workouts with exercise details, so that I can track my exercise progress.

**Acceptance Criteria**:
- [x] WorkoutLoggingPage UI implemented
- [x] Date picker
- [x] Exercise selector (or add new)
- [x] Exercise details inputs (sets, reps, weight, duration, distance)
- [x] Notes field
- [x] Add exercise button
- [x] Save workout button
- [x] Validation and error handling

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Workout Logging Screen
- `artifacts/phase-2-features/exercise-module-specification.md` - Exercise Logging section

**Technical References**:
- Page: `lib/features/exercise_management/presentation/pages/workout_logging_page.dart`
- Use Case: `LogWorkoutUseCase`

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-170 | Create WorkoutLoggingPage UI | `WorkoutLoggingPage` widget | wireframes.md - Workout Logging Screen | ✅ | 5 | Dev3 |
| T-171 | Implement exercise entry form | Sets, reps, weight, duration, distance inputs | exercise-module-specification.md - Exercise Logging | ✅ | 3 | Dev3 |
| T-172 | Implement exercise selector | Select or add new exercise | exercise-module-specification.md | ✅ | 2 | Dev3 |
| T-173 | Integrate LogWorkout use case | Connect UI to use case | exercise-module-specification.md | ✅ | 2 | Dev3 |
| T-174 | Write widget tests for WorkoutLoggingPage | Test files | testing-strategy.md | ⏸️ | 3 | Dev3 |

**Total Task Points**: 15

---

### Story 6.4: Exercise Main Page - 3 Points

**User Story**: As a user, I want a main exercise page that shows overview of my workouts and activity, so that I can quickly see my progress.

**Acceptance Criteria**:
- [x] ExercisePage UI implemented
- [x] Workout plans list
- [x] Recent workouts list
- [x] Activity summary (steps, active minutes, calories) - basic display (full Google Fit integration post-MVP)
- [x] Quick actions (log workout, create plan, view history)
- [x] Navigation to sub-pages

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Exercise Main Screen
- `artifacts/phase-2-features/exercise-module-specification.md` - Exercise Module

**Technical References**:
- Page: `lib/features/exercise_management/presentation/pages/exercise_page.dart`
- Widget: `lib/features/exercise_management/presentation/widgets/workout_card_widget.dart`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-175 | Create ExercisePage UI | `ExercisePage` widget | wireframes.md - Exercise Main Screen | ✅ | 3 | Dev1 |
| T-176 | Create WorkoutCardWidget | `WorkoutCardWidget` widget | exercise-module-specification.md - Workout Display | ✅ | 2 | Dev1 |
| T-177 | Create ExerciseListWidget | `ExerciseListWidget` widget | exercise-module-specification.md - Exercise List | ✅ | 2 | Dev1 |
| T-178 | Implement activity summary display | Basic activity display (full integration post-MVP) | exercise-module-specification.md - Activity Tracking | ✅ | 2 | Dev1 |
| T-179 | Implement navigation to sub-pages | Navigation routing | wireframes.md | ✅ | 2 | Dev1 |
| T-180 | Write widget tests for ExercisePage | Test files | testing-strategy.md | ⏸️ | 2 | Dev1 |

**Total Task Points**: 13

---

### Story 6.5: Activity Tracking Display - 3 Points

**User Story**: As a user, I want to see my daily activity summary (steps, active minutes, calories), so that I can track my movement.

**Acceptance Criteria**:
- [x] ActivityTrackingPage UI implemented (or section on ExercisePage)
- [x] Steps progress bar (X / 10,000 steps)
- [x] Active minutes display
- [x] Calories burned display
- [x] Activity history chart (basic, full integration post-MVP)
- [x] Note: Full Google Fit/Health Connect integration deferred to post-MVP

**Reference Documents**:
- `artifacts/phase-2-features/exercise-module-specification.md` - Activity Tracking section
- `artifacts/phase-3-integration/integration-specifications.md` - Google Fit integration (post-MVP)

**Technical References**:
- Page: `lib/features/exercise_management/presentation/pages/activity_tracking_page.dart` (optional, can be section on ExercisePage)

**Story Points**: 3

**Priority**: 🟠 High

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-181 | Create ActivityTrackingPage UI | `ActivityTrackingPage` widget or section | exercise-module-specification.md - Activity Tracking | ✅ | 3 | Dev2 |
| T-182 | Implement activity summary display | Steps, active minutes, calories | exercise-module-specification.md - Activity Summary | ✅ | 2 | Dev2 |
| T-183 | Implement activity history chart | Basic chart (full integration post-MVP) | exercise-module-specification.md - Activity History | ✅ | 2 | Dev2 |
| T-184 | Write widget tests for ActivityTrackingPage | Test files | testing-strategy.md | ⏸️ | 2 | Dev2 |

**Total Task Points**: 9

---

## Sprint Summary

**Total Story Points**: 18  
**Total Task Points**: 61  
**Estimated Velocity**: 21 points (based on team capacity)

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

**Sprint Review Notes**:
- [Notes from sprint review]

**Sprint Retrospective Notes**:
- [Notes from retrospective]

---

## Demo to Product Owner

**Purpose**: The product owner will run the application and verify that all sprint deliverables are working correctly.

**Demo Checklist**:
- [x] Application builds and runs successfully
- [x] Exercise pages display correctly
- [x] Workout plan creation and management works
- [x] Workout logging functionality works
- [x] Activity tracking displays correctly (basic implementation)
- [x] Navigation between exercise screens functions properly
- [x] All acceptance criteria from user stories are met
- [x] No critical bugs or blockers identified

**Demo Notes**:
- ✅ **Demo Page Created**: Sprint6DemoPage created at `lib/core/test/sprint6_demo_page.dart`
- ✅ **Main App Updated**: main.dart updated to use Sprint6DemoPage
- ✅ **All Pages Accessible**: Demo page provides navigation to all exercise pages
- ✅ **Provider Tests**: Demo page includes tests for all exercise providers
- ✅ **UI Components**: All widgets and pages are functional and accessible

---

**Cross-Reference**: Implementation Order - Phase 6: Presentation Layer - Exercise


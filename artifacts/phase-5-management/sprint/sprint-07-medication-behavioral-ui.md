# Sprint 7: Medication & Behavioral UI

**Sprint Goal**: Implement medication management and behavioral support user interfaces including medication tracking, habit tracking, and goal tracking.

**Duration**: [Start Date] - [End Date] (2 weeks)  
**Team Velocity**: Target 21 points  
**Sprint Planning Date**: [Date]  
**Sprint Review Date**: [Date]  
**Sprint Retrospective Date**: [Date]

## Sprint Overview

**Focus Areas**:
- Medication providers and pages
- Behavioral support providers and pages
- Medication widgets
- Habit tracking interface
- Goal tracking interface

**Key Deliverables**:
- Complete medication management UI
- Complete behavioral support UI
- Habit tracking interface
- Goal tracking interface

**Dependencies**:
- Sprint 3: Domain Use Cases must be complete

**Risks & Blockers**:
- Medication reminder integration (notifications - Sprint 8)
- Habit streak calculation complexity

**Parallel Development**: Can be developed in parallel with Sprints 4, 5, 6

## User Stories

### Story 7.1: Medication Providers - 2 Points

**User Story**: As a developer, I want medication Riverpod providers implemented, so that UI can access medication data and business logic.

**Acceptance Criteria**:
- [ ] MedicationsProvider implemented (FutureProvider)
- [ ] Provider handles error states
- [ ] Provider uses use cases from domain layer

**Reference Documents**:
- `artifacts/phase-1-foundations/architecture-documentation.md` - Riverpod patterns

**Technical References**:
- Providers: `lib/features/medication_management/presentation/providers/`

**Story Points**: 2

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-185 | Create MedicationsProvider | `medicationsProvider` FutureProvider | architecture-documentation.md - Riverpod | ⭕ | 2 | Dev1 |
| T-186 | Write unit tests for providers | Test files in `test/unit/features/medication_management/presentation/providers/` | testing-strategy.md | ⭕ | 2 | Dev1 |

**Total Task Points**: 4

---

### Story 7.2: Medication Management Page - 5 Points

**User Story**: As a user, I want to manage my medications and log doses, so that I can track my medication adherence.

**Acceptance Criteria**:
- [ ] MedicationPage UI implemented
- [ ] Medications list with active/inactive status
- [ ] Add medication button
- [ ] Medication details (name, dosage, frequency, times)
- [ ] Medication logging functionality
- [ ] Reminder settings (UI only, notifications in Sprint 8)
- [ ] Navigation to medication logging page

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Medication Screen (if exists)
- `artifacts/phase-1-foundations/data-models.md` - Medication entity

**Technical References**:
- Page: `lib/features/medication_management/presentation/pages/medication_page.dart`
- Widget: `lib/features/medication_management/presentation/widgets/medication_card_widget.dart`
- Use Cases: `AddMedicationUseCase`, `LogMedicationDoseUseCase`

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-187 | Create MedicationPage UI | `MedicationPage` widget | data-models.md - Medication | ⭕ | 3 | Dev1 |
| T-188 | Create MedicationCardWidget | `MedicationCardWidget` widget | project-structure-specification.md | ⭕ | 2 | Dev1 |
| T-189 | Implement add medication form | Name, dosage, frequency, times inputs | data-models.md - Medication | ⭕ | 3 | Dev1 |
| T-190 | Integrate AddMedication use case | Connect UI to use case | data-models.md | ⭕ | 2 | Dev1 |
| T-191 | Write widget tests for MedicationPage | Test files in `test/widget/features/medication_management/presentation/pages/` | testing-strategy.md | ⭕ | 3 | Dev1 |

**Total Task Points**: 13

---

### Story 7.3: Medication Logging Page - 3 Points

**User Story**: As a user, I want to log when I take my medications, so that I can track adherence.

**Acceptance Criteria**:
- [ ] MedicationLoggingPage UI implemented
- [ ] Medication selector
- [ ] Date/time picker
- [ ] Dosage input
- [ ] Notes field (optional)
- [ ] Save button
- [ ] Recent logs list

**Reference Documents**:
- `artifacts/phase-1-foundations/data-models.md` - MedicationLog entity

**Technical References**:
- Page: `lib/features/medication_management/presentation/pages/medication_logging_page.dart`
- Use Case: `LogMedicationDoseUseCase`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-192 | Create MedicationLoggingPage UI | `MedicationLoggingPage` widget | data-models.md - MedicationLog | ⭕ | 3 | Dev2 |
| T-193 | Implement medication log form | Date/time, dosage, notes inputs | data-models.md - MedicationLog | ⭕ | 2 | Dev2 |
| T-194 | Integrate LogMedicationDose use case | Connect UI to use case | data-models.md | ⭕ | 2 | Dev2 |
| T-195 | Write widget tests for MedicationLoggingPage | Test files | testing-strategy.md | ⭕ | 2 | Dev2 |

**Total Task Points**: 9

---

### Story 7.4: Behavioral Support Providers - 2 Points

**User Story**: As a developer, I want behavioral support Riverpod providers implemented, so that UI can access habit and goal data.

**Acceptance Criteria**:
- [ ] HabitsProvider implemented (FutureProvider)
- [ ] WeeklyReviewProvider implemented (basic, LLM integration post-MVP)
- [ ] All providers handle error states
- [ ] All providers use use cases from domain layer

**Reference Documents**:
- `artifacts/phase-1-foundations/architecture-documentation.md` - Riverpod patterns

**Technical References**:
- Providers: `lib/features/behavioral_support/presentation/providers/`

**Story Points**: 2

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-196 | Create HabitsProvider | `habitsProvider` FutureProvider | architecture-documentation.md - Riverpod | ⭕ | 2 | Dev3 |
| T-197 | Create WeeklyReviewProvider | `weeklyReviewProvider` Provider (basic, LLM post-MVP) | project-structure-specification.md | ⭕ | 2 | Dev3 |
| T-198 | Write unit tests for providers | Test files in `test/unit/features/behavioral_support/presentation/providers/` | testing-strategy.md | ⭕ | 2 | Dev3 |

**Total Task Points**: 6

---

### Story 7.5: Habit Tracking Page - 3 Points

**User Story**: As a user, I want to track my habits and see my streaks, so that I can build healthy routines.

**Acceptance Criteria**:
- [ ] HabitTrackingPage UI implemented
- [ ] Habits list with current streak and longest streak
- [ ] Add habit button
- [ ] Mark habit as completed for today
- [ ] Habit details (name, category, description)
- [ ] Streak visualization

**Reference Documents**:
- `artifacts/phase-1-foundations/data-models.md` - Habit entity
- `artifacts/phase-1-foundations/wireframes.md` - Habit Tracking Screen (if exists)

**Technical References**:
- Page: `lib/features/behavioral_support/presentation/pages/habit_tracking_page.dart`
- Widget: `lib/features/behavioral_support/presentation/widgets/habit_card_widget.dart`
- Use Case: `TrackHabitUseCase`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-199 | Create HabitTrackingPage UI | `HabitTrackingPage` widget | data-models.md - Habit | ⭕ | 3 | Dev3 |
| T-200 | Create HabitCardWidget | `HabitCardWidget` widget | project-structure-specification.md | ⭕ | 2 | Dev3 |
| T-201 | Implement add habit form | Name, category, description inputs | data-models.md - Habit | ⭕ | 2 | Dev3 |
| T-202 | Implement habit completion | Mark habit as completed for today | data-models.md - Habit | ⭕ | 2 | Dev3 |
| T-203 | Implement streak calculation | Current streak and longest streak | data-models.md - Habit | ⭕ | 2 | Dev3 |
| T-204 | Integrate TrackHabit use case | Connect UI to use case | data-models.md | ⭕ | 2 | Dev3 |
| T-205 | Write widget tests for HabitTrackingPage | Test files | testing-strategy.md | ⭕ | 2 | Dev3 |

**Total Task Points**: 15

---

### Story 7.6: Behavioral Support Main Page - 2 Points

**User Story**: As a user, I want a main behavioral support page that shows overview of my habits and goals, so that I can track my behavioral progress.

**Acceptance Criteria**:
- [ ] BehavioralSupportPage UI implemented
- [ ] Habits overview
- [ ] Goals overview
- [ ] Quick actions (add habit, create goal, view weekly review)
- [ ] Navigation to sub-pages

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Behavioral Support Screen (if exists)

**Technical References**:
- Page: `lib/features/behavioral_support/presentation/pages/behavioral_support_page.dart`

**Story Points**: 2

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-206 | Create BehavioralSupportPage UI | `BehavioralSupportPage` widget | project-structure-specification.md | ⭕ | 3 | Dev1 |
| T-207 | Implement habits and goals overview | Display summary cards | data-models.md - Habit and Goal | ⭕ | 2 | Dev1 |
| T-208 | Implement navigation to sub-pages | Navigation routing | project-structure-specification.md | ⭕ | 2 | Dev1 |
| T-209 | Write widget tests for BehavioralSupportPage | Test files | testing-strategy.md | ⭕ | 2 | Dev1 |

**Total Task Points**: 9

---

### Story 7.7: Goal Tracking - 1 Point

**User Story**: As a user, I want to create and track goals, so that I can work towards health objectives.

**Acceptance Criteria**:
- [ ] Goal creation form (description, type, target, deadline)
- [ ] Goals list with progress indicators
- [ ] Goal progress widget showing percentage
- [ ] Goal status tracking (inProgress, completed, etc.)

**Reference Documents**:
- `artifacts/phase-1-foundations/data-models.md` - Goal entity

**Technical References**:
- Widget: `lib/features/behavioral_support/presentation/widgets/goal_progress_widget.dart`
- Use Case: `CreateGoalUseCase`

**Story Points**: 1

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-210 | Create GoalProgressWidget | `GoalProgressWidget` widget | data-models.md - Goal | ⭕ | 2 | Dev2 |
| T-211 | Implement goal creation form | Description, type, target, deadline inputs | data-models.md - Goal | ⭕ | 3 | Dev2 |
| T-212 | Implement goal progress calculation | Progress percentage calculation | data-models.md - Goal | ⭕ | 2 | Dev2 |
| T-213 | Integrate CreateGoal use case | Connect UI to use case | data-models.md | ⭕ | 2 | Dev2 |
| T-214 | Write widget tests for goal tracking | Test files | testing-strategy.md | ⭕ | 2 | Dev2 |

**Total Task Points**: 11

---

## Sprint Summary

**Total Story Points**: 18  
**Total Task Points**: 68  
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
- [ ] Application builds and runs successfully
- [ ] Medication management pages display correctly
- [ ] Medication logging functionality works
- [ ] Habit tracking pages display correctly
- [ ] Habit completion and streak tracking works
- [ ] Goal tracking functionality works
- [ ] Navigation between medication and behavioral screens functions properly
- [ ] All acceptance criteria from user stories are met
- [ ] No critical bugs or blockers identified

**Demo Notes**:
- [Notes from product owner demo]

---

**Cross-Reference**: Implementation Order - Phase 7: Presentation Layer - Medication & Behavioral


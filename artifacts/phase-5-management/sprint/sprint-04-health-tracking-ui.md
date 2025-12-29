# Sprint 4: Health Tracking UI

**Sprint Goal**: Implement complete health tracking user interface including weight entry, body measurements, sleep/energy tracking, and data visualization.

**Duration**: [Start Date] - [End Date] (2 weeks)  
**Team Velocity**: Target 21 points  
**Sprint Planning Date**: [Date]  
**Sprint Review Date**: [Date]  
**Sprint Retrospective Date**: [Date]

## Sprint Overview

**Focus Areas**:
- Health tracking providers (Riverpod)
- Health tracking pages (weight entry, measurements, sleep/energy)
- Health tracking widgets (charts, cards, forms)
- Weight trend visualization
- Body measurements tracking
- Sleep and energy tracking

**Key Deliverables**:
- Complete health tracking UI
- Weight entry and visualization
- Body measurements tracking
- Sleep and energy tracking

**Dependencies**:
- Sprint 3: Domain Use Cases must be complete

**Risks & Blockers**:
- Chart library integration
- Data visualization complexity
- UI/UX consistency

**Parallel Development**: Can be developed in parallel with Sprints 5, 6, 7

## User Stories

### Story 4.1: Health Tracking Providers - 3 Points

**User Story**: As a developer, I want health tracking Riverpod providers implemented, so that UI can access health data and business logic.

**Acceptance Criteria**:
- [ ] HealthMetricsProvider implemented (FutureProvider)
- [ ] WeightTrendProvider implemented
- [ ] MovingAverageProvider implemented
- [ ] All providers handle error states
- [ ] All providers use use cases from domain layer

**Reference Documents**:
- `artifacts/phase-1-foundations/architecture-documentation.md` - Riverpod patterns
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Health tracking structure

**Technical References**:
- Providers: `lib/features/health_tracking/presentation/providers/`
- Pattern: Riverpod FutureProvider and Provider

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-105 | Create HealthMetricsProvider | `healthMetricsProvider` FutureProvider | architecture-documentation.md - Riverpod | ⭕ | 2 | Dev1 |
| T-106 | Create WeightTrendProvider | `weightTrendProvider` Provider | health-tracking-module-specification.md | ⭕ | 2 | Dev1 |
| T-107 | Create MovingAverageProvider | `movingAverageProvider` Provider | health-domain-specifications.md - Moving Average | ⭕ | 2 | Dev1 |
| T-108 | Write unit tests for providers | Test files in `test/unit/features/health_tracking/presentation/providers/` | testing-strategy.md | ⭕ | 2 | Dev1 |

**Total Task Points**: 8

---

### Story 4.2: Weight Entry Page - 5 Points

**User Story**: As a user, I want to enter my daily weight, so that I can track my weight loss progress.

**Acceptance Criteria**:
- [ ] WeightEntryPage UI implemented
- [ ] Large numeric input field (24sp font, centered)
- [ ] Unit display (kg/lbs based on user preference)
- [ ] Date picker button (defaults to today, can select past dates)
- [ ] Information card showing 7-day moving average
- [ ] Trend indicator (↑ increasing, ↓ decreasing, → stable)
- [ ] Recent weights list (last 5 entries)
- [ ] Primary action button: "Save Weight"
- [ ] Validation errors displayed inline
- [ ] Success confirmation shown after save

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Weight Entry Screen
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Weight Tracking section
- `artifacts/phase-1-foundations/component-specifications.md` - Input components

**Technical References**:
- Page: `lib/features/health_tracking/presentation/pages/weight_entry_page.dart`
- Use Case: `SaveHealthMetricUseCase`

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-109 | Create WeightEntryPage UI | `WeightEntryPage` widget | wireframes.md - Weight Entry Screen | ⭕ | 5 | Dev2 |
| T-110 | Implement weight input field | Numeric input with validation | component-specifications.md - Number Input | ⭕ | 2 | Dev2 |
| T-111 | Implement date picker | Date selection functionality | component-specifications.md - Date Picker | ⭕ | 2 | Dev2 |
| T-112 | Integrate SaveHealthMetric use case | Connect UI to use case | health-tracking-module-specification.md | ⭕ | 2 | Dev2 |
| T-113 | Display 7-day moving average | Information card with average | health-domain-specifications.md - Moving Average | ⭕ | 2 | Dev2 |
| T-114 | Display recent weights list | List of last 5 entries | wireframes.md | ⭕ | 2 | Dev2 |
| T-115 | Write widget tests for WeightEntryPage | Test files in `test/widget/features/health_tracking/presentation/pages/` | testing-strategy.md | ⭕ | 3 | Dev2 |

**Total Task Points**: 18

---

### Story 4.3: Weight Trend Chart Widget - 5 Points

**User Story**: As a user, I want to see my weight trend over time in a chart, so that I can visualize my progress.

**Acceptance Criteria**:
- [ ] WeightChartWidget implemented
- [ ] Line chart showing weight over time (last 30 days default)
- [ ] 7-day moving average line overlay (different color)
- [ ] Interactive: Tap point to see exact value and date
- [ ] Empty state when no data
- [ ] Chart library integrated (fl_chart or similar)

**Reference Documents**:
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Data Visualization Components
- `artifacts/phase-1-foundations/component-specifications.md` - Chart Components

**Technical References**:
- Widget: `lib/features/health_tracking/presentation/widgets/weight_chart_widget.dart`
- Chart Library: fl_chart or similar

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-116 | Create WeightChartWidget | `WeightChartWidget` widget | health-tracking-module-specification.md - Weight Trend Chart | ⭕ | 5 | Dev3 |
| T-117 | Integrate chart library | fl_chart or similar | component-specifications.md - Charts | ⭕ | 3 | Dev3 |
| T-118 | Implement 7-day moving average overlay | Overlay line on chart | health-domain-specifications.md - Moving Average | ⭕ | 3 | Dev3 |
| T-119 | Implement empty state | Empty state widget when no data | component-specifications.md - Empty State | ⭕ | 2 | Dev3 |
| T-120 | Write widget tests for WeightChartWidget | Test files in `test/widget/features/health_tracking/presentation/widgets/` | testing-strategy.md | ⭕ | 3 | Dev3 |

**Total Task Points**: 16

---

### Story 4.4: Body Measurements Page - 3 Points

**User Story**: As a user, I want to enter my body measurements (waist, hips, neck, chest, thigh), so that I can track non-scale victories.

**Acceptance Criteria**:
- [ ] MeasurementsPage UI implemented
- [ ] Date picker (defaults to today)
- [ ] Input fields for each measurement (waist, hips, neck, chest, thigh)
- [ ] Last measurements card showing previous measurements
- [ ] Change indicators (↑, ↓, →) with change amounts
- [ ] Primary action button: "Save Measurements"
- [ ] Validation errors displayed inline

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Measurements Screen
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Body Measurements Tracking

**Technical References**:
- Page: `lib/features/health_tracking/presentation/pages/measurements_page.dart`
- Widget: `lib/features/health_tracking/presentation/widgets/measurement_form_widget.dart`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-121 | Create MeasurementsPage UI | `MeasurementsPage` widget | wireframes.md - Measurements Screen | ⭕ | 3 | Dev2 |
| T-122 | Create MeasurementFormWidget | `MeasurementFormWidget` widget | health-tracking-module-specification.md - Measurements Entry | ⭕ | 3 | Dev2 |
| T-123 | Implement change calculation | Compare to last measurement | health-tracking-module-specification.md - Change Calculation | ⭕ | 2 | Dev2 |
| T-124 | Write widget tests for MeasurementsPage | Test files | testing-strategy.md | ⭕ | 2 | Dev2 |

**Total Task Points**: 10

---

### Story 4.5: Sleep and Energy Tracking Page - 3 Points

**User Story**: As a user, I want to log my daily sleep quality and energy level, so that I can track patterns and identify issues.

**Acceptance Criteria**:
- [ ] SleepEnergyPage UI implemented
- [ ] Sleep Quality slider (1-10 scale) with visual labels
- [ ] Energy Level slider (1-10 scale) with visual labels
- [ ] Interpretation text (Excellent 8-10, Good 6-7, Fair 4-5, Poor 1-3)
- [ ] Notes field (optional, multiline text)
- [ ] Primary action button: "Save Entry"
- [ ] Validation and error handling

**Reference Documents**:
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Sleep and Energy Tracking
- `artifacts/phase-1-foundations/wireframes.md` - Sleep/Energy Screen

**Technical References**:
- Page: `lib/features/health_tracking/presentation/pages/sleep_energy_page.dart`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-125 | Create SleepEnergyPage UI | `SleepEnergyPage` widget | wireframes.md - Sleep/Energy Screen | ⭕ | 3 | Dev3 |
| T-126 | Implement sleep quality slider | Slider widget with labels | component-specifications.md - Slider | ⭕ | 2 | Dev3 |
| T-127 | Implement energy level slider | Slider widget with labels | component-specifications.md - Slider | ⭕ | 2 | Dev3 |
| T-128 | Write widget tests for SleepEnergyPage | Test files | testing-strategy.md | ⭕ | 2 | Dev3 |

**Total Task Points**: 9

---

### Story 4.6: Health Tracking Main Page - 2 Points

**User Story**: As a user, I want a main health tracking page that shows overview of all my health metrics, so that I can quickly see my progress.

**Acceptance Criteria**:
- [ ] HealthTrackingPage UI implemented
- [ ] Overview cards for weight, measurements, sleep, energy
- [ ] Navigation to sub-pages (weight entry, measurements, sleep/energy)
- [ ] Recent metrics summary
- [ ] Quick actions (add weight, add measurement, etc.)

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Health Tracking Main Screen
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Health Tracking Module

**Technical References**:
- Page: `lib/features/health_tracking/presentation/pages/health_tracking_page.dart`
- Widget: `lib/features/health_tracking/presentation/widgets/metric_card_widget.dart`

**Story Points**: 2

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-129 | Create HealthTrackingPage UI | `HealthTrackingPage` widget | wireframes.md - Health Tracking Main Screen | ⭕ | 3 | Dev1 |
| T-130 | Create MetricCardWidget | `MetricCardWidget` widget | health-tracking-module-specification.md - Metric Display | ⭕ | 2 | Dev1 |
| T-131 | Implement navigation to sub-pages | Navigation routing | wireframes.md | ⭕ | 2 | Dev1 |
| T-132 | Write widget tests for HealthTrackingPage | Test files | testing-strategy.md | ⭕ | 2 | Dev1 |

**Total Task Points**: 9

---

## Sprint Summary

**Total Story Points**: 21  
**Total Task Points**: 70  
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
- [ ] Health tracking pages display correctly
- [ ] Weight entry functionality works
- [ ] Weight trend chart displays data accurately
- [ ] Body measurements can be entered and saved
- [ ] Sleep and energy tracking works
- [ ] Navigation between health tracking screens functions properly
- [ ] All acceptance criteria from user stories are met
- [ ] No critical bugs or blockers identified

**Demo Notes**:
- [Notes from product owner demo]

---

**Cross-Reference**: Implementation Order - Phase 4: Presentation Layer - Health Tracking


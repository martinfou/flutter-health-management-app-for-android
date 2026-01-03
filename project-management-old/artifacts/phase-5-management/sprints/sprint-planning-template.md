# Sprint Planning Template

## Overview

This document provides a template for sprint planning documents using the CRISPE Framework. Each sprint planning document should follow this structure to ensure consistency and completeness.

**Reference**: Based on CRISPE Framework standards in `artifacts/requirements.md`.

## Sprint Planning Document Structure

### Sprint Header

```markdown
# Sprint [Number]: [Sprint Name]

**Sprint Goal**: [Clear, measurable goal for this sprint]
**Duration**: [Start Date] - [End Date] ([X] weeks)
**Team Velocity**: [Previous sprint velocity or target velocity]
**Sprint Planning Date**: [Date]
**Sprint Review Date**: [Date]
**Sprint Retrospective Date**: [Date]
```

### Sprint Overview

```markdown
## Sprint Overview

**Focus Areas**:
- [Primary focus area 1]
- [Primary focus area 2]
- [Primary focus area 3]

**Key Deliverables**:
- [Deliverable 1]
- [Deliverable 2]
- [Deliverable 3]

**Dependencies**:
- [Dependency 1]
- [Dependency 2]

**Risks & Blockers**:
- [Risk/Blocker 1]
- [Risk/Blocker 2]
```

## User Stories

### User Story Format

```markdown
### Story [Number]: [Story Title] - [X] Points

**User Story**: As a [user type], I want [functionality], so that [benefit].

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Reference Documents**:
- [Document Name 1] - [Section/Page]
- [Document Name 2] - [Section/Page]

**Technical References**:
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Feature Spec: `artifacts/phase-2-features/[feature]-module-specification.md`
- Data Models: `artifacts/phase-1-foundations/data-models.md`

**Story Points**: [X] (Fibonacci: 1, 2, 3, 5, 8, 13)

**Priority**: 🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low

**Status**: ⭕ Not Started / ⏳ In Progress / ✅ Completed
```

### Tasks Table

```markdown
**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-001 | [Task description] | `ClassName.methodName()` | [Document Name] - [Section] | ⭕ | [X] | [Name] |
| T-002 | [Task description] | `ClassName.methodName()` | [Document Name] - [Section] | ⭕ | [X] | [Name] |
```

**Task Status**:
- ⭕ **Not Started**: Task not yet begun
- ⏳ **In Progress**: Task currently being worked on
- ✅ **Completed**: Task finished and verified

**Task Points**: Use Fibonacci sequence (1, 2, 3, 5, 8, 13) for task estimation

## Example Sprint Planning Document

```markdown
# Sprint 1: Health Tracking Foundation

**Sprint Goal**: Implement core health tracking features including weight entry, 7-day moving average calculation, and basic data visualization.

**Duration**: 2024-01-15 - 2024-01-29 (2 weeks)
**Team Velocity**: Target 21 points
**Sprint Planning Date**: 2024-01-15
**Sprint Review Date**: 2024-01-29
**Sprint Retrospective Date**: 2024-01-30

## Sprint Overview

**Focus Areas**:
- Health tracking module foundation
- Weight entry and storage
- 7-day moving average calculation
- Basic data visualization

**Key Deliverables**:
- Weight entry screen
- 7-day moving average calculation
- Weight trend chart
- Health metrics storage

## User Stories

### Story 1: Weight Entry - 5 Points

**User Story**: As a user, I want to enter my daily weight, so that I can track my weight loss progress.

**Acceptance Criteria**:
- [ ] User can enter weight (20-500 kg range)
- [ ] User can select date for weight entry
- [ ] Weight is saved to local database
- [ ] Validation errors are displayed for invalid weights
- [ ] Success confirmation is shown after save

**Reference Documents**:
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Weight Tracking section
- `artifacts/phase-1-foundations/wireframes.md` - Weight Entry Screen
- `artifacts/phase-1-foundations/data-models.md` - HealthMetric entity

**Technical References**:
- Architecture: Feature-First Clean Architecture
- Data Layer: `lib/features/health_tracking/data/`
- Domain Layer: `lib/features/health_tracking/domain/`
- Presentation Layer: `lib/features/health_tracking/presentation/`

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-001 | Create HealthMetric entity | `HealthMetric` class | data-models.md - HealthMetric | ⭕ | 2 | Dev1 |
| T-002 | Create HealthMetricModel (Hive) | `HealthMetricModel` class | database-schema.md - Health Metrics Box | ⭕ | 3 | Dev1 |
| T-003 | Implement SaveHealthMetric use case | `SaveHealthMetricUseCase.call()` | health-tracking-module-spec.md | ⭕ | 3 | Dev2 |
| T-004 | Create WeightEntryPage UI | `WeightEntryPage` widget | wireframes.md - Weight Entry Screen | ⭕ | 5 | Dev3 |
| T-005 | Implement weight validation | `HealthMetricValidator.validate()` | data-models.md - Validation Rules | ⭕ | 2 | Dev2 |
| T-006 | Create repository implementation | `HealthTrackingRepositoryImpl` | architecture-documentation.md | ⭕ | 3 | Dev1 |
| T-007 | Write unit tests for use case | `SaveHealthMetricUseCase` tests | test-specifications.md | ⭕ | 3 | Dev2 |
| T-008 | Write widget tests for page | `WeightEntryPage` tests | test-specifications.md | ⭕ | 2 | Dev3 |

**Total Task Points**: 23

### Story 2: 7-Day Moving Average - 8 Points

**User Story**: As a user, I want to see my 7-day moving average weight, so that I can see meaningful trends despite daily fluctuations.

**Acceptance Criteria**:
- [ ] 7-day moving average is calculated correctly
- [ ] Average is displayed on weight entry screen
- [ ] "Insufficient data" shown when less than 7 days
- [ ] Average updates automatically when new weight added
- [ ] Trend indicator shows if increasing/decreasing/stable

**Reference Documents**:
- `artifacts/phase-1-foundations/health-domain-specifications.md` - 7-Day Moving Average Calculation
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Weight Tracking

**Technical References**:
- Use Case: `CalculateMovingAverageUseCase`
- Algorithm: MovingAverageCalculator.calculate7DayAverage()

**Story Points**: 8

**Priority**: 🔴 Critical

**Status**: ⭕ Not Started

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-009 | Implement MovingAverageCalculator | `MovingAverageCalculator.calculate7DayAverage()` | health-domain-specifications.md | ⭕ | 5 | Dev2 |
| T-010 | Create CalculateMovingAverage use case | `CalculateMovingAverageUseCase.call()` | health-tracking-module-spec.md | ⭕ | 3 | Dev2 |
| T-011 | Create MovingAverageProvider | `MovingAverageProvider` | architecture-documentation.md - Riverpod | ⭕ | 3 | Dev3 |
| T-012 | Display average on WeightEntryPage | `WeightEntryPage` - average display | wireframes.md | ⭕ | 3 | Dev3 |
| T-013 | Implement trend calculation | `WeightTrendCalculator.calculate()` | health-domain-specifications.md | ⭕ | 3 | Dev2 |
| T-014 | Write unit tests for calculator | `MovingAverageCalculator` tests | test-specifications.md | ⭕ | 5 | Dev2 |

**Total Task Points**: 22

## Sprint Summary

**Total Story Points**: 13
**Total Task Points**: 45
**Estimated Velocity**: 13 points (based on story points)

**Sprint Burndown**:
- Day 1: [X] points completed
- Day 2: [X] points completed
- ...
- Day 14: [X] points completed

**Sprint Review Notes**:
- [Notes from sprint review]

**Sprint Retrospective Notes**:
- [Notes from retrospective]
```

## Story Point Estimation Guide

### Fibonacci Sequence

Use Fibonacci sequence for story point estimation:
- **1 Point**: Trivial task, < 1 hour
- **2 Points**: Simple task, 1-4 hours
- **3 Points**: Small task, 4-8 hours
- **5 Points**: Medium task, 1-2 days
- **8 Points**: Large task, 2-3 days
- **13 Points**: Very large task, 3-5 days (should be broken down)

### Estimation Factors

Consider:
- **Complexity**: How complex is the task?
- **Uncertainty**: How much is unknown?
- **Effort**: How much work is required?
- **Risk**: What are the risks?

## Task Breakdown Guidelines

### Good Task Characteristics

- **Specific**: Clear what needs to be done
- **Actionable**: Can be started immediately
- **Testable**: Has clear completion criteria
- **Referenced**: Links to technical documents
- **Estimated**: Has story points assigned

### Technical References

Each task should reference:
- **Class/Method**: Specific code location
- **Document**: Relevant specification document
- **Section**: Specific section in document

## Sprint Tracking

### Daily Standup Format

- What did I complete yesterday?
- What will I work on today?
- Are there any blockers?

### Sprint Burndown

Track daily progress:
- Story points completed
- Tasks completed
- Remaining work

### Sprint Review

- Demo completed features
- Review acceptance criteria
- Gather feedback

### Sprint Retrospective

- What went well?
- What could be improved?
- Action items for next sprint

## References

- **Requirements**: `artifacts/requirements.md` - Sprint Planning Standards
- **CRISPE Framework**: `artifacts/requirements.md` - CRISPE Framework sections
- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Sprint Planning Template Complete


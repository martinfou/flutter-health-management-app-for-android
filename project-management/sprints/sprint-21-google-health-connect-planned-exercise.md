# Sprint 21: Google Health Connect Planned Exercise Integration

**Sprint Goal:** Integrate Google Health Connect's planned exercise feature (FEATURE_PLANNED_EXERCISE) for robust, bidirectional workout plan sync across the Health Connect ecosystem.

**Duration:** [TBD] (2 weeks)
**Team Velocity:** Target 13 points
**Sprint Planning Date:** [TBD]
**Sprint Review Date:** [TBD]
**Sprint Retrospective Date:** [TBD]

---

## Related Feature Requests
- [FR-018: Google Health Connect Planned Exercise Integration](../backlog/features/FR-018-google-health-connect-planned-exercise.md) - 13 points

---

## Sprint Overview
**Focus Areas:**
- Health Connect API/Flutter integration and permissions
- Data model mapping between WorkoutPlan and Health Connect PlannedExercise
- Sync logic for new/updated plans, imports from Health Connect
- UI and status/error handling (enable/disable, conflict, last sync, feature availability)

**Key Deliverables:**
- Settings UI for enabling Health Connect & permissions
- Sync & Import from Health Connect workflow
- Data model/entity conversion
- UI status for sync state/conflict/last sync
- Manual/automatic sync trigger logic
- Automated/manual tests

**Dependencies:**
- Exercise Library and Workout Plan (FR-016, must be fully complete)
- API-level and Health Connect feature available on device

**Risks & Blockers:**
- Feature not available on some devices (graceful fallback required)
- Permission UX/denials
- Mapping/conversion issues between native and Health Connect models
- Sync conflict and edge cases

---
## User Story
**User Story:** As a fitness enthusiast, I want my planned workouts and training schedules to be visible and synced via Google Health Connect, so I have a unified training view and interoperability with other health/fitness apps.
#### Acceptance Criteria
- Can enable Health Connect sync in app
- Proper permission request and fallback for denied/missing
- Automatically sync on plan create/update (manual trigger also available)
- Import from Health Connect (list, select, map to plan)
- Plan/exercise data mapped fully to and from Health Connect
- Error and eligibility/feature unavailability handled in UI
- Sync status, last sync and error state shown per-plan

---
## Tasks
| Task ID | Task Description                          | Owner | Status | Points |
|---------|-------------------------------------------|-------|--------|--------|
| T-2101  | Integrate Health Connect SDK/Flutter pkg  |       | ⭕     | 2      |
| T-2102  | Permissions/feature availability checks   |       | ⭕     | 2      |
| T-2103  | Write planned exercise to Health Connect  |       | ⭕     | 2      |
| T-2104  | Import/convert exercises from Health Con. |       | ⭕     | 2      |
| T-2105  | Sync status/conflict resolution logic     |       | ⭕     | 2      |
| T-2106  | UI/UX settings & sync/enable/disable      |       | ⭕     | 2      |
| T-2107  | Automated/manual tests                    |       | ⭕     | 1      |

---
## Demo Checklist
- [ ] Syncs plan to Health Connect as planned
- [ ] Imports plans from Health Connect as well
- [ ] Handles feature missing/denied gracefully
- [ ] UI clear for status, sync, and error
- [ ] Automated/manual verified for all flows

---
**Last Updated:** 2026-01-03
**Status:** ⭕ Not Started

## Implementation Status (2026-01-03)
- Google Health Connect integration NOT implemented
- No health platform integration (Apple HealthKit, Google Fit) exists
- All health data managed locally in Hive database only
- No sync with external health platforms


# Sprint 16-17: Cloud Sync & Multi-Device Support

**Sprint Goal:** Implement opt-in, robust cloud sync allowing users to access and edit their health data seamlessly on multiple devices, via DreamHost/PHP/MySQL backend with JWT authentication. Maintain full offline-first functionality and transparency for the user.

**Duration:** [TBD, 4 weeks]
**Team Velocity:** Target 21 points per sprint (42 total)
**Sprint Planning Date:** [TBD]
**Sprint Review Date:** [TBD]
**Sprint Retrospective Date:** [TBD]

---

## Related Feature Requests
- [FR-008: Cloud Sync & Multi-Device Support](../backlog/features/FR-008-cloud-sync-multi-device-support.md) - 21 points
- [FR-009: User Authentication](../backlog/features/FR-009-user-authentication.md) (dependency)

---

## Sprint Overview
**Focus Areas:**
- DreamHost PHP/MySQL backend: sync endpoints, authentication
- OPT-IN UI for cloud sync (enable/disable any time)
- Network-layer sync client
- Offline-first data integrity and error handling
- Bidirectional, incremental sync (background on network available)
- Conflict resolution and safe UI communication
- Security, privacy (encryption, opt-in), clear sync status

**Key Deliverables:**
- Sync API/DB backend (PHP/Slim/MySQL)
- Secure login/token refresh with backend
- Sync service, status tracking, and UI indicators in Flutter
- Full offline queue and background task management
- Graceful error/retry and transparent user controls
- Automated and manual regression tests

**Dependencies:**
- Backend auth, schema, SSL (FR-009/User Authentication must be completed)
- DreamHost hosting & certs

**Risks & Blockers:**
- Backend readiness and stability
- Data conflict/merge edge cases
- User privacy and data plan usage (opt-in design)

---

## User Stories
### Story 16.1: Multi-Device Cloud Sync (21 pts)
**User Story:** As a user, I want to opt-in to cloud sync, so my health data is always up to date and portable across all my devices, but never lost if offline or disconnected.

#### Acceptance Criteria
- Users can opt-in/out at any time (toggle in settings)
- Data encrypted in transit (HTTPS/SSL)
- DreamHost backend with PHP/Slim/MySQL
- JWT auth/refresh integrated in all sync flows
- All core data (metrics, meals, workouts, etc.) sync bi-directionally
- Conflict resolution: timestamp/merge, UI explains overwrites
- UI indicators: sync status, date/time last sync, retry needed
- Device and offline status handling is fool-proof (works offline 100%)
- All error and privacy edge cases handled/tested

#### Reference Documents
- FR-008, sync-architecture-design.md, API docs, User auth (FR-009)

---

## Tasks
| Task ID | Task Description                             | Owner | Status | Points |
|---------|----------------------------------------------|-------|--------|--------|
| T-1611  | Backend sync endpoints/API                   |       | ⭕     | 5      |
| T-1612  | Sync DB schema                              |       | ⭕     | 2      |
| T-1613  | JWT/token refresh in sync API               |       | ⭕     | 3      |
| T-1614  | Client sync API client/abstraction           |       | ⭕     | 3      |
| T-1615  | UI: cloud sync opt-in/opt-out toggle         |       | ⭕     | 2      |
| T-1616  | Sync status UI/UX                           |       | ⭕     | 2      |
| T-1617  | Bidirectional, incremental sync (algorithms) |       | ⭕     | 6      |
| T-1618  | Offline queue and retries                    |       | ⭕     | 3      |
| T-1619  | Data conflict resolution/merge+UI            |       | ⭕     | 5      |
| T-1620  | SSL/cert management on DreamHost             |       | ⭕     | 1      |
| T-1621  | Automated tests                              |       | ⭕     | 2      |
| T-1622  | Manual QA/regression                         |       | ⭕     | 2      |

---

## Demo Checklist
- [ ] Cloud sync opt-in/out works & persists
- [ ] Data syncs bidirectionally with no loss/corruption
- [ ] Sync status and errors clear to user
- [ ] Works full offline (no regression)
- [ ] Merges handle all edge cases & show UI to resolve if needed
- [ ] No unencrypted data in transit

---
**Last Updated:** 2026-01-03
**Status:** ⭕ Not Started

## Implementation Status (2026-01-03)
- Cloud sync NOT implemented
- All data stored locally in Hive database only
- No sync service or remote data storage exists
- Requires FR-020 (Backend Infrastructure) to be completed first
- Requires FR-009 (User Authentication) to be completed first


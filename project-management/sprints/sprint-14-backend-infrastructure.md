# Sprint 14: Backend Infrastructure

**Sprint Goal:** Deploy robust backend infrastructure (PHP/Slim/MySQL on DreamHost) with full API coverage for user authentication, data sync, and multi-device support—blocker for all post-MVP cloud features.

**Duration:** [TBD] (2 weeks)
**Team Velocity:** Target 21 points
**Sprint Planning Date:** [TBD]
**Sprint Review Date:** [TBD]
**Sprint Retrospective Date:** [TBD]

---

## Related Feature Requests
- [FR-020: Backend Infrastructure](../backlog/features/FR-020-backend-infrastructure.md) - 21 points
- [FR-009: User Authentication](../backlog/features/FR-009-user-authentication.md) (blocked/depends)
- [FR-008: Cloud Sync & Multi-Device Support](../backlog/features/FR-008-cloud-sync-multi-device-support.md) (blocked/depends)

---

## Sprint Overview
**Focus Areas:**
- DreamHost/PHP/Slim/MySQL backend setup and configuration
- All REST API endpoints for health data, Meals, Metrics, Plans, etc.
- JWT authentication and endpoint-level security (Google OAuth validation included)
- Sync endpoints, conflict resolution, and testing
- Database schema, migrations, CI/CD deployment scripts
- Robust error, rate-limiting, CORS, and privacy/GDPR compliance

**Key Deliverables:**
- Fully documented working REST API (health metrics, meals, medication, exercise, sync, etc.)
- JWT+OAuth-supported authentication
- Initial sync/conflict resolution implementation
- API and DB deployment docs/scripts
- Postman collection and basic automated tests

**Dependencies:**
- DreamHost account, SSL, domain setup
- Google OAuth credentials
- FR-009 & FR-008—work cannot proceed until backend API is ready

**Risks & Blockers:**
- DreamHost deployment stability
- SSL/HTTP config and DB setup
- Data model correctness and sync edge cases
- Performance with real user data and high velocity
- OAuth/Google API integrations (for verification)

---
## User Story
**User Story:** As a developer, I want a reliable and secure backend API with all critical endpoints documented, so that the mobile app can offer cloud sync, user auth, and multi-device functionality post-MVP with confidence.

#### Acceptance Criteria
- All endpoints (metrics/meals/exercises/plans/sync) tested and working
- Authentication end-to-end tested and verified (JWT, OAuth)
- SQL/db migration & rollback tested
- All config files/CORS/docs complete
- Postman/API docs published
- CI/CD pipeline for DreamHost deployed and tested

---
## Tasks
| Task ID | Task Description                          | Owner | Status | Points |
|---------|-------------------------------------------|-------|--------|--------|
| T-1401  | DreamHost env setup/config                |       | ⭕     | 2      |
| T-1402  | Database schema & migrations              |       | ⭕     | 3      |
| T-1403  | REST API endpoints implementation         |       | ⭕     | 5      |
| T-1404  | JWT & Google OAuth integration            |       | ⭕     | 3      |
| T-1405  | Sync/conflict endpoints                   |       | ⭕     | 3      |
| T-1406  | API/DB/Postman documentation              |       | ⭕     | 2      |
| T-1407  | CI/CD & DreamHost scripts                 |       | ⭕     | 2      |
| T-1408  | Testing & bugfix cycle                    |       | ⭕     | 1      |

---
## Demo Checklist
- [ ] All API endpoints working and documented
- [ ] JWT & OAuth work with sample user
- [ ] Sync endpoint, last-write-wins tested
- [ ] Deployment flow (commit→prod) is reproducible
- [ ] Sample app user logs in, syncs, and logs meals
- [ ] GDPR/account deletion/cascade funcs verified

---
**Last Updated:** 2026-01-03
**Status:** ⭕ Not Started

## Implementation Status (2026-01-03)
- Backend infrastructure NOT implemented
- No PHP/Slim code exists
- No database schema deployed
- No API endpoints available
- Flutter app has AuthenticationService designed for backend but server not deployed
- This sprint is blocking FR-009 (Auth) and FR-008 (Cloud Sync)


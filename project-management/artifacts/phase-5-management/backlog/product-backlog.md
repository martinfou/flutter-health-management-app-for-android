# Product Backlog

This is the main product backlog tracking all feature requests and bug fixes.

**Last Updated**: 2025-01-27  
**Implementation Order**: See [Implementation Order Recommendation](./implementation-order-recommendation.md)

## Feature Requests

| ID | Title | Priority | Points | Status | Sprint | Created | Updated |
|----|-------|----------|--------|--------|--------|---------|---------|
| [FR-001](../backlog/feature-requests/FR-001-health-tracking-ui-redesign.md) | Health Tracking UI Redesign (Card-Based Dashboard) | 🟠 High | 13 | ✅ | Current | 2024-12-20 | 2024-12-20 |
| [FR-002](../backlog/feature-requests/FR-002-home-screen-priority-stack-layout.md) | Home Screen UI Redesign (Priority-Based Stack Layout) | 🟠 High | 13 | ✅ | Current | 2025-12-30 | 2025-12-30 |
| [FR-003](../backlog/feature-requests/FR-003-home-screen-pull-to-refresh.md) | Home Screen Pull-to-Refresh | 🟠 High | 3 | ✅ | [Sprint 11](../sprints/sprint-11-post-mvp-improvements.md) | 2025-12-30 | 2025-01-03 |
| [FR-004](../backlog/feature-requests/FR-004-food-suggestion-based-on-remaining-macros.md) | Food Suggestion Based on Remaining Macros | 🟠 High | 8 | ⭕ | Sprint 18 | 2025-01-02 | 2025-01-03 |
| [FR-005](../backlog/feature-requests/FR-005-hunger-scale-when-logging-food.md) | Hunger Scale and Eating Reasons When Logging Food | 🟡 Medium | 8 | ✅ | [Sprint 11](../sprints/sprint-11-post-mvp-improvements.md) | 2025-01-02 | 2025-01-03 |
| [FR-006](../backlog/feature-requests/FR-006-update-health-tracking-history.md) | Update Health Tracking History | 🟠 High | 8 | ✅ | [Sprint 11](../sprints/sprint-11-post-mvp-improvements.md) | 2025-01-02 | 2025-01-03 |
| [FR-007](../backlog/feature-requests/FR-007-metric-imperial-units.md) | Metric/Imperial Units Support | 🟠 High | 13 | ✅ | [Sprint 12](../sprints/sprint-12-metric-imperial-units.md) | 2025-01-02 | 2025-01-27 |
| [FR-008](../backlog/feature-requests/FR-008-cloud-sync-multi-device-support.md) | Cloud Sync & Multi-Device Support | 🟠 High | 21 | ⭕ | Sprint 16-17 | 2025-01-03 | 2025-01-03 |
| [FR-009](../backlog/feature-requests/FR-009-user-authentication.md) | User Authentication | 🟠 High | 13 | ⭕ | Sprint 14-15 | 2025-01-03 | 2025-01-03 |
| [FR-010](../backlog/feature-requests/FR-010-llm-integration.md) | LLM Integration | 🟠 High | 21 | ⭕ | Sprint 14-15 | 2025-01-03 | 2025-01-03 |
| [FR-011](../backlog/feature-requests/FR-011-advanced-analytics-module.md) | Advanced Analytics Module | 🟠 High | 21 | ⭕ | Sprint 18-20 | 2025-01-03 | 2025-01-03 |
| [FR-012](../backlog/feature-requests/FR-012-grocery-store-api-integration.md) | Grocery Store API Integration | 🟡 Medium | 13 | ⭕ | Sprint 21+ (Post-MVP Phase 2) | 2025-01-03 | 2025-01-03 |
| [FR-013](../backlog/feature-requests/FR-013-ios-support.md) | iOS Support | 🟡 Medium | 13 | ⭕ | Sprint 21+ (Post-MVP Phase 2) | 2025-01-03 | 2025-01-03 |
| [FR-014](../backlog/feature-requests/FR-014-social-features.md) | Social Features | 🟢 Low | 21 | ⭕ | Sprint 21+ (Post-MVP Phase 2) | 2025-01-03 | 2025-01-03 |
| [FR-015](../backlog/feature-requests/FR-015-enhanced-content-management.md) | Enhanced Content Management | 🟡 Medium | 13 | ⭕ | Sprint 21+ (Post-MVP Phase 2) | 2025-01-03 | 2025-01-03 |
| [FR-016](../backlog/feature-requests/FR-016-exercise-library-and-workout-plan-integration.md) | Exercise Library and Workout Plan Integration | 🟠 High | 13 | ⭕ | Sprint 13 | 2025-01-03 | 2025-01-03 |
| [FR-017](../backlog/feature-requests/FR-017-comprehensive-exercise-tracking.md) | Comprehensive Exercise Tracking | 🟠 High | 21 | ⭕ | Backlog | 2025-01-27 | 2025-01-27 |

## Bug Fixes

| ID | Title | Priority | Points | Status | Sprint | Created | Updated |
|----|-------|----------|--------|--------|--------|---------|---------|
| [BF-001](../backlog/bug-fixes/BF-001-export-import-not-working.md) | Export/Import Functionality Not Working Properly | 🔴 Critical | 5 | ✅ | [Sprint 12](../sprints/sprint-12-metric-imperial-units.md) | 2025-12-30 | 2025-01-27 |
| [BF-002](../backlog/bug-fixes/BF-002-food-save-blocked-by-carb-limit.md) | Food Save Blocked by 40g Carb Limit Validation | 🟠 High | 3 | ⭕ | [Sprint 13](../sprints/sprint-13-exercise-library-and-bug-fixes.md) | 2025-01-03 | 2025-01-27 |

---

### Status Values
- ⭕ **Not Started**: Item not yet started
- ⏳ **In Progress**: Item currently being worked on
- ✅ **Completed**: Item finished and verified

### Priority Levels
- 🔴 **Critical**: Blocks core functionality, must be fixed immediately
- 🟠 **High**: Important feature, should be addressed soon
- 🟡 **Medium**: Nice to have, can wait
- 🟢 **Low**: Future consideration, low priority

### Notes
- Feature request details: See `feature-requests/FR-XXX-*.md` files
- Bug fix details: See `bug-fixes/BF-XXX-*.md` files
- Sprint assignments: See `../sprints/sprint-XX-*.md` files
- **Implementation Order**: Sprint assignments are based on the [Implementation Order Recommendation](./implementation-order-recommendation.md)
- **Sprint 14-15**: FR-009 (Authentication) and FR-010 (LLM Integration) can be done in parallel
- **Sprint 18**: FR-004 (Food Suggestions) can start after FR-010 (LLM Integration) is complete
- **Sprint 21+**: Post-MVP Phase 2 features - prioritize based on user feedback and business needs


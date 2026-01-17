# Sprint Roadmap 2026 - Reorganized by Priority

**Updated**: 2026-01-17 (After Backend Infrastructure Completion)

This roadmap shows the next sprints organized by dependency order and priority to unblock maximum value.

---

## Current Status Summary

| Item | Status | Notes |
|------|--------|-------|
| FR-020: Backend Infrastructure | ✅ COMPLETE | Sprint 23 - API deployed to DreamHost |
| BF-008: Sync Schema Fix | ✅ COMPLETE | Health metrics sync working |
| Health Metrics Sync | ✅ WORKING | All fields syncing correctly |

---

## Upcoming Sprints (Priority Order)

### 🔴 CRITICAL PATH - Unblocks All Cloud Features

#### **Sprint 24: User Authentication & Bug Fixes** (13 + 3 = 16 points)
**Status**: ✅ COMPLETED
**Duration**: 2 weeks
**Dependencies**: ✅ All complete (backend deployed)

**What's Included**:
- **FR-009**: User Authentication (13 pts)
  - Google OAuth integration
  - JWT token system
  - User profiles & password reset
  - Protected routes
  - GDPR account deletion

- **BF-002**: Food Save Bug Fix (3 pts)
  - Fix carb limit validation blocking saves

**Unblocks**: Sprint 25-26 (Cloud Sync), FR-008

---

#### **BF-003: Health Metrics Multiple Entries** (8 points) - Production Fix
**Status**: ✅ COMPLETED
**Duration**: 1 day (production deployment)
**Issue**: Backend only stored one health metric per day
**Solution**: Changed database schema from DATE to TIMESTAMP
**Testing**: Verified in production - multiple daily entries now work
**Impact**: Users can track health metrics throughout the day with full precision
**Blockers**: None - Ready to go!

**Link**: [Sprint 24: User Authentication](./sprint-24-user-authentication.md)

---

### **Sprint 25-26: Cloud Sync & Multi-Device** (21 points)
**Status**: ✅ COMPLETED
**Duration**: 4 weeks
**Dependencies**: ✅ Backend deployed, ✅ Sprint 24 (FR-009) completed

**What's Included**:
- **FR-008**: Cloud Sync & Multi-Device Support (21 pts)
  - Meals synchronization
  - Exercises synchronization
  - Medications synchronization
  - Multi-device coordination
  - Conflict resolution
  - Sync UI improvements
  - Offline-first support

**Unblocks**: Sprint 27 (Advanced Analytics), Post-MVP Phase 2
**Blockers**: Requires FR-009 (Sprint 24) complete

**Link**: [Sprint 25-26: Cloud Sync](./sprint-25-26-cloud-sync-multi-device-support.md)

---

### **Sprint 26: Open Food Facts Integration** (13 points)
**Status**: ⭕ Planned
**Duration**: 2 weeks
**Dependencies**: None - Can run in parallel with Sprint 25-26

**What's Included**:
- **FR-019**: Open Food Facts Integration (13 pts)
  - Food search with autocomplete
  - Barcode scanning
  - Nutritional data auto-fill
  - Offline caching
  - Recent foods & favorites

**Scheduling Options**:
- **Parallel Option**: Run during Sprint 25-26 week 2 if resources available
- **Sequential Option**: Start after Sprint 25-26 if team capacity limited

**Blockers**: None - Independent feature

**Link**: [Sprint 26: Open Food Facts](./sprint-26-open-food-facts-integration.md)

---

### **Sprint 27: Advanced Analytics Module** (21 points)
**Status**: ⭕ Planned (After Sprint 25-26)
**Duration**: 4 weeks
**Dependencies**: ✅ LLM (FR-010), ✅ Food Suggestions (FR-004), ⭕ Sprint 25-26 (Sync)

**What's Included**:
- **FR-011**: Advanced Analytics (21 pts)
  - Weekly summaries & trends
  - Goal setting & tracking
  - AI-powered insights
  - Nutrition & exercise analytics
  - Health score calculation
  - Insights notifications

**Unblocks**: Post-MVP Phase 2 features
**Blockers**: Recommended to complete Sprint 25-26 first for multi-device analytics

**Link**: [Sprint 27: Advanced Analytics](./sprint-27-advanced-analytics-module.md)

---

## Timeline Summary

```
2026-01
Week 1: Sprint 23 (Complete) ✅
Week 2-3: Sprint 24 (User Auth & BF-002) ⭕
         Sprint 26 (Food Facts) - Optional parallel start

2026-02
Week 1-2: Sprint 25-26 (Cloud Sync & Multi-Device) ⭕
Week 3-4: Sprint 25-26 (continued)

2026-03
Week 1-4: Sprint 27 (Advanced Analytics) ⭕
```

---

## Critical Path Analysis

**Dependency Chain**:
```
Sprint 23 (Backend) ✅
    ↓
Sprint 24 (Auth) ⭕ REQUIRED
    ↓
Sprint 25-26 (Cloud Sync) ⭕
    ↓
Sprint 27 (Analytics) ⭕
```

**Parallel Opportunities**:
- Sprint 26 (Food Facts) can run during Sprint 25-26 week 2
- Sprint 26 doesn't block any other features
- FR-019 is independent of sync

---

## Points Summary

| Sprint | Feature | Points | Status | Dependencies |
|--------|---------|--------|--------|--------------|
| 23 | FR-020 Backend | 21 | ✅ Complete | None |
| 24 | FR-009 Auth | 13 | ⭕ Next | Backend ✅ |
| 24 | BF-002 Bug | 3 | ⭕ Next | None |
| 25-26 | FR-008 Sync | 21 | ⭕ After 24 | Backend ✅, Auth ⭕ |
| 26 | FR-019 Food | 13 | ⭕ Parallel | None |
| 27 | FR-011 Analytics | 21 | ⭕ After 25-26 | LLM ✅, Sync ⭕ |
| **TOTAL** | | **92** | | |

---

## High-Priority Unfinished Items

These are still in the backlog but lower priority (post-MVP Phase 2):

| Feature | Points | Priority | Sprint | Notes |
|---------|--------|----------|--------|-------|
| FR-012 | Grocery Store API | 13 | 🟡 Medium | Phase 2 |
| FR-013 | iOS Support | 13 | 🟡 Medium | Phase 2 |
| FR-016 | Exercise Library | 13 | 🟠 High | Phase 2 |
| FR-017 | Comprehensive Exercise | 21 | 🟠 High | Backlog |
| FR-018 | Google Health Connect | 13 | 🟡 Medium | Phase 2 |
| FR-024 | Garmin Watch Sync | 13 | 🟠 High | Backlog |

---

## Key Decisions

1. **Sprint 24 is CRITICAL**: User authentication unblocks all cloud features
2. **Sprint 25-26 ordering**: 4-week sprint needed for full multi-device sync
3. **Sprint 26 (Food Facts) positioning**:
   - Independent feature
   - Can run in parallel to maximize velocity
   - Recommended: Start week 2 of Sprint 25-26
4. **Analytics (Sprint 27)**: Deferred until sync complete for multi-device analytics
5. **Phase 2 features**: Defer to post-March planning

---

## Success Metrics

**Sprint 24 Success**:
- User can register and login with Google
- Tokens stored securely
- Protected routes working
- Food save bug fixed

**Sprint 25-26 Success**:
- All data types sync (metrics ✅, meals, exercises, meds)
- Multi-device coordination working
- Offline changes sync when reconnected
- No critical sync bugs

**Sprint 26 Success**:
- Food search with autocomplete working
- Barcode scanning functional
- 80%+ data coverage for target foods

**Sprint 27 Success**:
- Weekly summaries generated
- Trends displayed accurately
- AI insights relevant and actionable
- Goals tracking working

---

## Risk Management

**High Risk Areas**:
1. **Sprint 24**: JWT implementation complexity → Mitigate with comprehensive testing
2. **Sprint 25-26**: Multi-device sync conflicts → Implement robust conflict resolution
3. **Sprint 26**: Food database coverage → Verify common foods work before release
4. **Sprint 27**: LLM insight quality → Gather user feedback during testing

**Mitigation Strategies**:
- Comprehensive unit and integration testing
- Regular demo and feedback loops
- Manual testing on physical devices
- Performance testing with realistic data volumes

---

## Next Action

**Immediate** (This week):
1. ✅ Complete Sprint 23 (Backend) - DONE
2. ✅ Fix sync schema (BF-008) - DONE
3. ⭕ **Start Sprint 24** (User Authentication)

**Next 2 weeks**:
- Sprint 24: User authentication implementation
- Prepare Sprint 25-26 detailed planning
- Optionally: Start Sprint 26 prep (Food Facts)

---

**Last Updated**: 2026-01-17
**Status**: Roadmap Complete
**Next Review**: Weekly during sprint planning

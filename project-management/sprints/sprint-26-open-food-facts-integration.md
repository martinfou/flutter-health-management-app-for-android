# Sprint 26: Open Food Facts Integration

**Sprint Goal**: Integrate Open Food Facts API for food autocomplete and barcode scanning, enabling users to quickly log meals with accurate nutritional data from a comprehensive food database.

**Duration**: 2 weeks (Sprint 26)
**Team Velocity**: Target 13 points
**Sprint Planning Date**: TBD (can run parallel with Sprint 25-26 or start during)
**Sprint Review Date**: TBD
**Sprint Retrospective Date**: TBD

---

## ⚠️ SCHEDULING NOTE

This sprint can run:
- **In parallel with Sprint 25-26** if sufficient resources
- **After Sprint 25 completes** if team capacity limited
- Recommended: Start during Sprint 25-26 week 2 if possible

---

## Related Feature Requests

- [FR-019: Open Food Facts Integration](../backlog/features/FR-019-open-food-facts-integration.md) - 13 points

**Total**: 13 points

---

## Sprint Overview

**Focus Areas**:
- Open Food Facts API integration
- Autocomplete search for food names
- Barcode scanning with automatic food lookup
- Nutritional data population from database
- Fallback for foods not in database
- Offline barcode caching
- User-friendly food selection UI

**Key Deliverables**:
- Food search with autocomplete (debounced, efficient)
- Barcode scanner integration
- Auto-fill nutritional data from Open Food Facts
- Manual override for missing/incorrect data
- Recent foods cache for quick access
- Favorite foods for power users
- Performance optimized for poor connectivity

**Dependencies**:
- Open Food Facts API access (free, no key required)
- Barcode scanning library (already available in app)
- Camera permission handling
- Network connectivity

**Risks & Blockers**:
- Open Food Facts data coverage for user's region
- Barcode format variations
- API rate limiting
- Offline barcode database size

---

## User Stories

### Story 26.1: Food Autocomplete Search - 5 Points

**User Story**: As a user logging a meal, I want to type a food name and see autocomplete suggestions from Open Food Facts, so I can quickly find foods without typing the entire name.

**Acceptance Criteria**:
- [x] Typing food name shows suggestions as-you-type
- [x] Search is debounced for performance
- [x] Results show food name, brand, calories
- [x] Selecting suggestion pre-fills nutritional data
- [ ] Recent foods appear at top
- [ ] Favorites easily accessible
- [x] Works offline with cached results
- [x] Clear distinction between open facts vs manual entries

**Story Points**: 5

**Status**: ⏳ In Progress

---

### Story 26.2: Barcode Scanning - 5 Points

**User Story**: As a user, I want to scan a product barcode to automatically populate food name and nutrition info, so I can log packaged foods quickly.

**Acceptance Criteria**:
- [x] Barcode scanner opens from add food button
- [x] Camera permission requested if needed
- [x] Barcode formats supported: UPC, EAN, Code128
- [x] Scanned barcode looked up in Open Food Facts
- [x] Nutritional data auto-populated if found
- [x] User can accept or manually edit data
- [x] Fallback if barcode not found (manual entry)
- [x] Scanned barcodes cached for offline

**Story Points**: 5

**Status**: ⏳ In Progress

---

### Story 26.3: Smart Data Population & Fallback - 3 Points

**User Story**: As a user, I want the app to intelligently handle missing nutrition data and let me easily fill in gaps, so accurate logging isn't blocked by incomplete databases.

**Acceptance Criteria**:
- [ ] Missing fields clearly marked
- [ ] User can manually enter missing nutrition
- [ ] App remembers custom entries for future
- [ ] Estimates provided for typical serving sizes
- [ ] Options to flag data errors to Open Food Facts
- [ ] Clear indication of data source reliability

**Story Points**: 3

**Status**: ⭕ Not Started

---

## Tasks

| Task ID | Task Description | Status | Points |
|---------|------------------|--------|--------|
| T-2601 | Integrate Open Food Facts API client | ✅ | 2 |
| T-2602 | Implement food search with autocomplete | ✅ | 3 |
| T-2603 | Add debouncing to search | ✅ | 2 |
| T-2604 | Create food search UI component | ✅ | 3 |
| T-2605 | Implement barcode scanner integration | ✅ | 3 |
| T-2606 | Create barcode scan UI | ✅ | 2 |
| T-2607 | Implement nutritional data auto-fill | ✅ | 3 |
| T-2608 | Add recent foods cache | ⭕ | 2 |
| T-2609 | Add favorites food management | ⭕ | 2 |
| T-2610 | Implement missing data fallback | ⭕ | 2 |
| T-2611 | Add offline barcode caching | ⭕ | 2 |
| T-2612 | Integration tests: Food search | ⭕ | 3 |
| T-2613 | Integration tests: Barcode scanning | ⭕ | 3 |
| T-2614 | Manual testing: End-to-end food logging | ⭕ | 2 |

**Total Task Points**: 30

---

## Demo Checklist

- [ ] User types "apple" and sees autocomplete suggestions
- [ ] Selecting suggestion pre-fills nutritional data
- [ ] Barcode scan works for packaged foods
- [ ] Nutritional data auto-populates from scan
- [ ] Missing data fields marked clearly
- [ ] User can manually fill missing nutrition
- [ ] Recent foods list shows previous entries
- [ ] Favorites can be added and accessed
- [ ] Offline search still works
- [ ] Data accuracy for common foods verified
- [ ] Performance acceptable with 100+ searches

---

## Success Criteria

**Sprint Completion Criteria**:
- [ ] Food search with autocomplete working
- [ ] Barcode scanning functional
- [ ] Nutritional data auto-populated correctly
- [ ] Fallback handling for missing data
- [ ] All demo items checked
- [ ] Performance acceptable
- [ ] Data accuracy verified for target foods

---

## Implementation Notes

**Open Food Facts Integration**:
- API: https://world.openfoodfacts.org/api/v0/product/{barcode}
- Search: GET /cgi/search.pl?search_terms={query}&json=1
- No authentication required (public API)
- Rate limit: ~5-10 requests/second
- Data licensed under ODbL (attribution required)

**Offline Caching**:
- Cache recent searches locally
- Cache barcode lookups for 30 days
- Cache favorites indefinitely

**Architecture**:
- Use existing barcode_scanner plugin
- New FoodService for Open Food Facts integration
- Search debouncing using Dart Timer
- Riverpod provider for food suggestions
- Local database cache for offline

**Testing**:
- Mock Open Food Facts API for unit tests
- Physical device testing with real barcodes
- Network error handling tests
- Offline mode tests

---

## Next Steps After Sprint 26

1. Evaluate data coverage for target regions
2. Gather user feedback on food search accuracy
3. Plan barcode database expansion if needed
4. Consider adding nutritional label scanning (OCR)
5. Start Sprint 27: Advanced Analytics (if resources available)

---

**Last Updated**: 2026-01-17
**Status**: Sprint Planning Complete
**Blocked By**: None - Can start anytime
**Unblocks**: None - Independent feature
**Parallel With**: Sprint 25-26 (Cloud Sync)

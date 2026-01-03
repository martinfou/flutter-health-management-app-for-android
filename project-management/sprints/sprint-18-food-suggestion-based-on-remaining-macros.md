# Sprint 18: Food Suggestion Based on Remaining Macros

**Sprint Goal:** Deliver an intelligent, LLM-empowered food suggestion system that personalizes recommendations according to each user's remaining daily macro targets—fully integrated into the nutrition tracking workflow.

**Duration:** [TBD] (2 weeks)
**Team Velocity:** Target 8 points
**Sprint Planning Date:** [TBD]
**Sprint Review Date:** [TBD]
**Sprint Retrospective Date:** [TBD]

---

## Related Feature Requests

- [FR-004: Food Suggestion Based on Remaining Macros](../backlog/features/FR-004-food-suggestion-based-on-remaining-macros.md) - 8 points

---

## Sprint Overview

**Focus Areas:**
- Accurate remaining macro calculation and clear display in UI
- LLM-powered suggestion system: personalized, macro-matching food recommendations
- Macro tracking and nutrition integration
- Robust error states and fallback UX

**Key Deliverables:**
- UI: Macro summary, "Get Suggestions" button, Food Suggestion page/cards
- Logic: LLM invocation and error handling, fallback logic, caching
- Integration: Logging food suggestions directly
- Automated and manual tests

**Dependencies:**
- LLM integration system (Sprint 15, FR-010)
- Food logging and macro summary use cases fully working
- NutritionRepository/meal log querying for history

**Risks & Blockers:**
- LLM API / cost limits
- Sparse or missing user history (must fallback to generic suggestions)
- Precise macro calculation logic in all edge cases
- UX clarity and speed for suggestions during busy meal times

---

## User Stories

### Story 18.1: Smart Food Suggestions - 8 Points
**User Story:** As a user, I want to receive intelligent food suggestions, based on my personal eating history and current macro needs—so that I can hit my nutrition targets each day with less mental effort.

#### Acceptance Criteria
- Remaining macros for the day are accurately displayed
- "Get Food Suggestions" button appears when macros remain
- System analyzes past meal log (last 30 days) and current needs
- LLM generates suggestions with:
   - Food name
   - Portion size
   - Macro breakdown
   - Relevance/fit score (if feasible)
   - Inspo from user's own meals when possible
- Suggestions shown as user-friendly list/cards (with Log button)
- Loading and error states clearly displayed
- Handles: full macros met, no history, network/API errors, tiny remainder values
- Test automation for all happy/edge cases

#### Reference Documents
- FR-004 spec | Nutrition Module | LLM prompt template | Macro calculation use cases

---

## Tasks

| Task ID | Task Description                     | Owner | Status | Points |
|---------|--------------------------------------|-------|--------|--------|
| T-1801  | Integrate macro calculation & summary|       | ⭕     | 2      |
| T-1802  | Implement "Get Suggestions" UI flow |       | ⭕     | 1      |
| T-1803  | Implement `GetFoodSuggestionsUseCase`|       | ⭕     | 2      |
| T-1804  | LLM prompt engineering & invocation  |       | ⭕     | 1      |
| T-1805  | Food suggestion result UI/cards      |       | ⭕     | 1      |
| T-1806  | Handle all fallback/error/loading    |       | ⭕     | 1      |
| T-1807  | Automated & manual tests             |       | ⭕     | 1      |

---

## Demo Checklist
- [ ] Macro summary and food suggestion button show correctly
- [ ] Suggestions are relevant, clear, macro-matched
- [ ] No history = fallback still works
- [ ] All error/loading/edge cases covered
- [ ] Users can log a suggested food in one tap
- [ ] Suggestions use user's own food log if present

---

## Notes
- Coordinate LLM calls with cost and UX best practices (cache for session/hour)
- Prioritize good user experience: speed, clarity, and fallback
- Fill any gaps in acceptance/test coverage before sprint closure

---
**Last Updated:** 2026-01-03
**Status:** ✅ Sprint Complete

## Completion Notes (2026-01-03)
- SuggestMealsUseCase implemented and working
- LLM-powered meal suggestions based on remaining macros functional
- User preferences (dietary approach, allergies, dislikes) integrated
- Quick log functionality deferred to FR-021 (Sprint 19)


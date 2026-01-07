# Feature Request: FR-027 - Weekly Review Data Requirement Info

**Status**: ✅ Completed  
**Priority**: 🟡 Medium  
**Story Points**: 2 (Fibonacci: 1, 2, 3, 5, 8, 13)  
**Created**: 2026-01-06  
**Updated**: 2026-01-06  
**Assigned Sprint**: Backlog

## Description

Ensure the "Generate Review" button is always visible on the Analytics page, regardless of whether the user has tracked any data yet. Additionally, add explanatory text or a tooltip to the Weekly Health Review widget to inform users about the data requirements (at least 1 day required, 4-7 days recommended for best quality).

## User Story

As a health app user, 
I want the "Generate Review" button to be always visible, 
so that I am aware of this feature even before I have logged enough data, and I want to know exactly how much data is needed.

## Acceptance Criteria

- [ ] The Weekly Health Review card and "Generate Review" button are always visible on the Analytics page.
- [ ] A text label or "info" icon with tooltip is added to the AI Weekly Health Review card.
- [ ] The text clearly states that at least 1 day of data is required to generate a review.
- [ ] The text/tooltip suggests that 4-7 days of tracking (weight, sleep, energy) provide the best quality insights.
- [ ] If the user clicks "Generate Review" with zero data, a helpful error message is shown (provided by the existing validation) but the button remains visible.

## Business Value

- Improves transparency and user education regarding AI features.
- Reduces user confusion when they see "no data" errors or limited reviews.
- Encourages more consistent tracking behavior by explaining the value of daily logging.

## Technical Requirements

- Flutter implementation using `WeeklyReviewInsightsWidget`.
- Use `Tooltip` or a simple `Text` widget with a subtle style (e.g., `theme.textTheme.bodySmall`).
- No backend changes required.

## Reference Documents

- [Weekly Review Widget](file:///Volumes/T7/src/ai-recipes/flutter-health-management-app-for-android/app/lib/features/analytics/presentation/widgets/weekly_review_insights_widget.dart)
- [Weekly Review Use Case](file:///Volumes/T7/src/ai-recipes/flutter-health-management-app-for-android/app/lib/features/analytics/domain/usecases/generate_weekly_review_use_case.dart)

## Technical References

- File: `app/lib/features/analytics/presentation/widgets/weekly_review_insights_widget.dart`
- Class: `WeeklyReviewInsightsWidget`

## Dependencies

- None

## History

- 2026-01-06 - Created
- 2026-01-06 - Status changed to ✅ Completed

---

## Status Values

- ⭕ **Not Started**: Item not yet started
- ⏳ **In Progress**: Item currently being worked on
- ✅ **Completed**: Item finished and verified

## Priority Levels

- 🔴 **Critical**: Blocks core functionality, must be fixed immediately
- 🟠 **High**: Important feature, should be addressed soon
- 🟡 **Medium**: Nice to have, can wait
- 🟢 **Low**: Future consideration, low priority

## Story Points Guide (Fibonacci)

- **1 Point**: Trivial task, < 1 hour
- **2 Points**: Simple task, 1-4 hours
- **3 Points**: Small task, 4-8 hours
- **5 Points**: Medium task, 1-2 days
- **8 Points**: Large task, 2-3 days
- **13 Points**: Very large task, 3-5 days (consider breaking down)

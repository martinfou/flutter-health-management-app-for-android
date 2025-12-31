# Feature Request: FR-003 - Home Screen Pull-to-Refresh

**Status**: ⭕ Not Started  
**Priority**: 🟠 High  
**Story Points**: 3  
**Created**: 2025-12-30  
**Updated**: 2025-12-30  
**Assigned Sprint**: Backlog

## Description

Add pull-to-refresh functionality to the home screen to allow users to manually refresh data when returning from other screens. Currently, when data is added in other screens and the user returns to the home page, the "Today's Progress" widget and other data widgets do not automatically update, showing stale data (e.g., 0% progress) until the app is restarted or the page is navigated away from and back.

## User Story

As a user, I want to be able to pull down on the home screen to refresh the data, so that when I add new metrics, meals, or medication logs and return to the home screen, I can see the updated progress and recommendations without having to restart the app.

## Acceptance Criteria

### Core Requirements
- [ ] Pull-to-refresh gesture support on home screen (pull down and release to refresh)
- [ ] Visual refresh indicator appears when pulling down
- [ ] Refresh triggers reload of all home screen data:
  - What's Next recommendations
  - Today's Progress percentage
  - Metric status grid (Weight, Sleep, Energy, Macros, Heart Rate, Medication)
- [ ] Data updates immediately after refresh completes
- [ ] Refresh works from any scroll position (user can scroll to top and pull down)
- [ ] Loading state is shown during refresh operation

### Quality & Polish
- [ ] Smooth pull-to-refresh animation (standard Flutter RefreshIndicator)
- [ ] Refresh indicator uses Material Design 3 styling
- [ ] No duplicate refresh requests if user pulls multiple times quickly
- [ ] Error handling if refresh fails (show error message, don't crash)

## Business Value

This feature improves user experience by:
- **Data freshness** - Users see up-to-date information immediately after adding data
- **Reduced confusion** - Prevents situations where progress shows 0% even after logging data
- **Better workflow** - Users can verify their progress without restarting the app
- **Standard UX pattern** - Follows common mobile app interaction pattern users expect

## Technical Requirements

### Updated Components
- Update `lib/core/pages/home_page.dart`:
  - Wrap `SingleChildScrollView` with `RefreshIndicator`
  - Implement `onRefresh` callback that invalidates providers:
    - `whatNextProvider`
    - `dailyProgressProvider`
    - `metricStatusProvider`
    - `healthMetricsProvider` (underlying data)
    - `macroSummaryProvider` (for date)
    - Any other dependent providers

### Provider Refresh Strategy
- Use `ref.refresh()` or `ref.invalidate()` to trigger provider re-fetch
- Ensure all dependent providers are refreshed in correct order
- Handle async refresh properly (wait for all providers to refresh)

### Implementation Approach
```dart
RefreshIndicator(
  onRefresh: () async {
    // Invalidate all home screen providers to force refresh
    ref.invalidate(whatNextProvider);
    ref.invalidate(dailyProgressProvider);
    ref.invalidate(metricStatusProvider);
    // Wait for refresh to complete
    await Future.wait([
      ref.read(whatNextProvider.future),
      ref.read(dailyProgressProvider.future),
      ref.read(metricStatusProvider.future),
    ]);
  },
  child: SingleChildScrollView(...),
)
```

## Reference Documents

- `lib/core/pages/home_page.dart` - Current home page implementation
- `lib/core/providers/home_screen_providers.dart` - Home screen providers
- Flutter RefreshIndicator documentation - Standard pull-to-refresh widget

## Technical References

- Page: `lib/core/pages/home_page.dart`
- Providers: `lib/core/providers/home_screen_providers.dart`
- Riverpod refresh documentation: `ref.refresh()` and `ref.invalidate()`

## Dependencies

- Existing home screen providers (whatNextProvider, dailyProgressProvider, metricStatusProvider)
- Underlying data providers (healthMetricsProvider, macroSummaryProvider, etc.)

## Notes

- This addresses a data synchronization issue where providers don't automatically refresh when data changes in other screens
- Pull-to-refresh is a standard mobile UX pattern that users expect
- Consider also implementing automatic refresh on page focus (when returning from other screens) as a future enhancement
- The refresh should be comprehensive - all home screen data should be refreshed, not just individual widgets

## Design Decisions

- **Use RefreshIndicator** - Standard Flutter widget for pull-to-refresh functionality
- **Provider invalidation** - Use `ref.invalidate()` to force providers to re-fetch data
- **Comprehensive refresh** - Refresh all home screen providers to ensure data consistency
- **Async handling** - Wait for all refresh operations to complete before showing updated data

## History

- 2025-12-30 - Created based on user feedback about stale data on home screen after adding metrics


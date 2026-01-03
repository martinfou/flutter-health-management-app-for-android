# Feature Request: FR-002 - Home Screen UI Redesign (Priority-Based Stack Layout)

**Status**: ✅ Completed  
**Priority**: 🟠 High  
**Story Points**: 13  
**Created**: 2025-12-30  
**Updated**: 2025-12-30  
**Assigned Sprint**: Current

## Description

Redesign the home screen using a priority-based stack layout that organizes content by user workflow and priority. This design focuses on action-oriented organization with a "What's Next?" section that dynamically suggests next actions, a progress tracking section, and streamlined quick access to all features. This approach reduces decision fatigue by guiding users through their daily health tracking routine.

## User Story

As a user, I want a home screen that shows me what I need to do next and tracks my daily progress, so that I can efficiently complete my health tracking tasks without feeling overwhelmed by too much information at once.

## Acceptance Criteria

### Core Requirements
- [ ] "What's Next?" section displays recommended actions based on:
  - Time of day (morning = weight, sleep; evening = energy, meals)
  - Medication schedules
  - Missing critical metrics
  - User patterns and preferences
- [ ] Priority ordering (urgent items first, such as medication due)
- [ ] One-tap logging for suggested actions
- [ ] Today's Progress section shows:
  - Visual progress bar with overall completion percentage
  - Checkmark grid of all key metrics (Weight, Sleep, Energy, Macros, Heart Rate, Medication)
  - Status indicators (✓ = logged, ⚠ = partial, ⚪ = not logged)
  - Expandable to view full summary details
- [ ] Quick Access section provides navigation to all features (Weight, Sleep, Meals, Workout, Medication, Habits, Analytics)
- [ ] Welcome message card with personalized greeting and motivational text
- [ ] Safety alerts displayed at top when present
- [ ] Time-aware recommendation logic that adapts to user's routine

### Enhanced Features
- [ ] Dismissible items in "What's Next?" section (user can snooze/dismiss)
- [ ] Medication schedule integration for priority alerts
- [ ] User preference storage for customizing recommendations
- [ ] Analytics tracking to improve recommendation accuracy
- [ ] Expandable progress section showing detailed breakdown
- [ ] Visual indicators (color coding: green = good, yellow = needs attention, gray = not logged)

### Quality & Polish
- [ ] Smooth animations for expanding/collapsing sections
- [ ] Responsive layout for different screen sizes
- [ ] Empty state handling when no recommendations available
- [ ] Loading states for async data fetching
- [ ] Consistent UI patterns with rest of app

## Business Value

This redesign significantly improves user experience by:
- **Reducing decision fatigue** - Users see what they need to do next without having to think
- **Improving completion rates** - Priority-based suggestions help users complete more tracking tasks
- **Time-aware intelligence** - Adapts to user's routine (morning vs evening needs)
- **Better workflow efficiency** - Logical flow from action to summary to navigation
- **Motivational progress tracking** - Visual progress percentage encourages completion
- **Streamlined experience** - Less overwhelming than showing all metrics at once
- **Personalized recommendations** - Learns from user patterns over time

## Technical Requirements

### New Components
- Create `RecommendationEngine` use case to determine next actions
- Create `HomeScreenProgressProvider` to calculate completion percentage
- Create `WhatNextCardWidget` for recommended action items
- Create `ProgressBarWidget` for visual progress display
- Create `MetricCheckGridWidget` for checkmark grid of metrics
- Create `QuickAccessGridWidget` for feature navigation
- Create `WelcomeCardWidget` for personalized greeting

### Updated Components
- Redesign `lib/core/pages/home_page.dart` with priority-based stack layout:
  - Safety alerts at top (if any)
  - Welcome message card
  - "What's Next?" section with dynamic recommendations
  - "Today's Progress" section with progress bar and metric grid
  - "Quick Access" section for feature navigation
- Update navigation routing as needed

### Recommendation Logic
- Time-of-day based logic for action suggestions:
  - Morning (6 AM - 12 PM): Weight, Sleep Quality, Morning Medication
  - Afternoon (12 PM - 6 PM): Lunch Meals, Afternoon Medication
  - Evening (6 PM - 12 AM): Energy Level, Dinner Meals, Evening Medication
- Medication schedule integration for priority alerts
- Missing critical metrics detection (weight, medication adherence)
- User pattern analysis (frequently used features, completion times)

### Progress Calculation
- Calculate overall completion percentage based on:
  - Weight logged: 1 metric
  - Sleep logged: 1 metric
  - Energy logged: 1 metric
  - Macros completed: Percentage of daily macro goals
  - Heart rate logged: 1 metric
  - Medication adherence: Percentage of scheduled doses taken
- Total: Weighted average or simple count of completed metrics

### State Management
- Create `whatNextProvider` (FutureProvider) for recommended actions
- Create `dailyProgressProvider` (FutureProvider) for progress calculation
- Create `metricStatusProvider` (FutureProvider) for metric completion status
- Use Riverpod providers for state management

### Data Models
- May need to extend existing entities/models if preference storage needed
- Medication schedule integration requires medication module data

## Reference Documents

- `artifacts/phase-1-foundations/home-screen-ui-design-options.md` - Design Option 2 (Priority-Based Stack Layout)
- `artifacts/phase-1-foundations/wireframes.md` - Original Home Screen Wireframes
- `artifacts/phase-1-foundations/design-system-options.md` - Design System Guidelines
- `artifacts/phase-2-features/medication-management-module-specification.md` - Medication Schedule Integration
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Health Metrics Reference

## Technical References

- Page: `lib/core/pages/home_page.dart`
- Repository: Feature-specific repositories for metric data
- Providers: Feature-specific providers for data fetching
- Use Case: `lib/core/use_cases/` (for recommendation engine)

## Dependencies

- Existing HealthTrackingRepository for weight, sleep, energy data
- Existing NutritionRepository for macro completion data
- Existing MedicationRepository for medication schedules (if available)
- Existing feature modules and navigation structure
- Time-based utilities for recommendation logic

## Notes

- This feature implements Design Option 2 from the home-screen-ui-design-options.md document
- Recommendation engine can start simple and be enhanced over time
- Progress calculation logic should be flexible to accommodate future metrics
- Consider A/B testing different recommendation algorithms
- User preferences for recommendations can be stored in Hive
- Analytics tracking will help improve recommendation accuracy over time

## Design Decisions

- **Selected Design**: Option 2 (Priority-Based Stack Layout) - best balance of usability and implementation complexity
- **Recommendation Priority**: Medication schedules first (highest priority), then time-based suggestions, then missing critical metrics
- **Progress Display**: Visual progress bar with percentage, plus detailed checkmark grid
- **Expandability**: Progress section expandable to show full summary details
- **Navigation Pattern**: Quick Access provides secondary navigation to all features
- **Time Awareness**: Recommendation engine adapts suggestions based on time of day

## History

- 2025-12-30 - Created based on home-screen-ui-design-options.md Option 2 selection
- 2025-12-30 - Status changed to ⏳ In Progress - Implementation started
- 2025-12-30 - Implementation completed:
  - Created WelcomeCardWidget
  - Created recommendation system with GetRecommendedActions use case
  - Created progress tracking with CalculateDailyProgress and GetDailyMetricStatus use cases
  - Created all required widgets (WhatNextCardWidget, ProgressBarWidget, MetricCheckGridWidget, QuickAccessGridWidget)
  - Created providers (whatNextProvider, dailyProgressProvider, metricStatusProvider)
  - Redesigned home_page.dart with priority-based stack layout
- 2025-12-30 - Status changed to ✅ Completed - Tested and verified working as expected


# Feature Request: FR-025 - Weight History Display on Weight Entry Screen

**Status**: ✅ Completed  
**Priority**: 🟡 Medium  
**Story Points**: 5 (Fibonacci: 1, 2, 3, 5, 8, 13)  
**Created**: 2026-01-06  
**Updated**: 2026-01-06  
**Assigned Sprint**: Backlog

## Description

Add a weight history display component to the Weight Entry screen that shows the last 10 weight entries. This component should be positioned below the "Save Weight" button and provide users with quick access to their recent weight tracking history without needing to navigate to a separate screen.

## User Story

As a mobile app user, 
I want to see my last 10 weight entries on the Weight Entry screen below the Save Weight button, 
so that I can quickly review my recent weight tracking history and trends while logging new weight data.

## Acceptance Criteria

- [ ] A weight history section is displayed below the "Save Weight" button on the Weight Entry screen
- [ ] The history displays the last 10 weight entries in reverse chronological order (most recent first)
- [ ] Each entry shows the weight value, unit (kg/lbs based on user preference), and the date/time of the entry
- [ ] The history list is scrollable if needed to accommodate all 10 entries
- [ ] The history updates automatically after a new weight entry is saved
- [ ] If there are fewer than 10 entries, only the available entries are displayed
- [ ] If there are no previous entries, a friendly message is displayed (e.g., "No weight history yet")
- [ ] The UI is responsive and works well on different screen sizes
- [ ] The weight history respects the user's unit preference (metric/imperial)

## Business Value

This feature improves user experience by:
- Reducing navigation steps - users don't need to leave the Weight Entry screen to view recent history
- Providing immediate context for weight tracking decisions
- Enabling users to spot trends and patterns more easily
- Increasing user engagement with the weight tracking feature by making historical data more accessible
- Reducing the number of screens users need to navigate, improving app efficiency

## Technical Requirements

- Query the last 10 weight entries from the local database (or Health Connect if applicable)
- Sort entries by timestamp in descending order (newest first)
- Display weight values according to user's unit preference setting
- Implement efficient data fetching to avoid performance issues
- Use Flutter's ListView or similar widget for scrollable history display
- Ensure proper state management so the list updates when a new weight is saved
- Handle edge cases: no data, partial data (< 10 entries)
- Format dates in a user-friendly format (e.g., "Jan 6, 2026 8:30 PM" or relative time like "2 hours ago")

## Reference Documents

- Weight Entry Screen - UI/UX design
- Health Tracking Data Model - Database schema
- User Preferences - Unit settings (metric/imperial)

## Technical References

- File: `app/lib/features/health_tracking/presentation/pages/weight_entry_page.dart`
- File: `app/lib/features/health_tracking/data/repositories/health_data_repository.dart`
- Database/Health Connect: Weight data storage and retrieval
- Widget: ListView or Column for displaying history entries
- State Management: Provider/Bloc/Riverpod for updating UI after save

## Dependencies

- Weight Entry screen must exist (already implemented)
- Database or Health Connect integration for weight data must be functional
- User preference system for units (metric/imperial) should be implemented

## Notes

- Consider adding visual indicators for weight trends (up/down arrows or color coding) in a future enhancement
- This is a quality-of-life improvement that enhances the user experience without being critical for MVP
- The 10-entry limit keeps the UI clean and prevents performance issues with large datasets
- Future enhancement could include a "View All History" button to navigate to a full history screen
- Consider caching the last 10 entries to improve performance on subsequent screen loads

## History

- 2026-01-06 - Created

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

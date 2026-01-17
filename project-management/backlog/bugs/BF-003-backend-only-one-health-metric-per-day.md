# Bug Fix: BF-003 - Backend Only Stores One Health Metric Per Day

**Status**: ✅ Completed
**Priority**: 🟠 High
**Story Points**: 8
**Created**: 2026-01-17
**Updated**: 2026-01-17
**Assigned Sprint**: Backlog

## Description

The backend currently only stores one health metric entry per day per user, preventing users from logging multiple health measurements throughout the day (e.g., morning and evening blood pressure readings, weight checks at different times, etc.). The system should use timestamps instead of just dates to allow multiple entries per day.

## Steps to Reproduce

1. Log in to the app and navigate to health tracking (blood pressure, weight, etc.)
2. Add a health metric entry at 9:00 AM (e.g., morning blood pressure: 120/80)
3. Wait a few hours, then try to add another entry for the same day at 6:00 PM (e.g., evening blood pressure: 118/75)
4. Attempt to save the second entry
5. Observe that the second entry overwrites the first one instead of being saved as a separate entry

## Expected Behavior

- Multiple health metric entries should be allowed per day with different timestamps
- Each entry should be stored separately with full timestamp information
- Users should be able to view all entries for a day in chronological order
- Historical data should show all measurements taken throughout the day

## Actual Behavior

- Only one health metric entry is stored per day per metric type
- New entries overwrite previous entries from the same day
- Users lose historical data from multiple measurements per day
- No way to track changes throughout the day (morning vs evening readings)

## Environment

- **Device**: Any Android device
- **OS**: Android 8.0+
- **App Version**: Current development version
- **Backend**: Laravel API deployed at healthapp.compica.com
- **Database**: MySQL with health_metrics table

## Screenshots/Logs

Backend database shows only one record per user per metric_type per date.

## Technical Details

The backend database schema and API logic currently use DATE fields instead of TIMESTAMP/DATETIME fields, causing entries to be deduplicated by date rather than allowing multiple entries with different times.

## Root Cause

1. **Database Schema**: The health_metrics table uses a DATE column for the measurement date instead of a TIMESTAMP column
2. **Unique Constraints**: Database may have unique constraints on (user_id, metric_type, date) instead of (user_id, metric_type, timestamp)
3. **API Logic**: Backend logic may be designed to update existing records by date rather than insert new records with timestamps
4. **Frontend**: App may be sending date-only values instead of full timestamps

## Solution

1. **Database Schema Update**:
   - Change date column from DATE to TIMESTAMP/DATETIME
   - Update unique constraints to use timestamp instead of date
   - Add migration script to preserve existing data

2. **Backend API Changes**:
   - Update health metrics endpoints to handle timestamp-based entries
   - Modify sync logic to support multiple entries per day
   - Update data models to use timestamp fields

3. **Frontend Updates**:
   - Ensure app sends full timestamps when logging health metrics
   - Update sync logic to handle multiple entries per day
   - Modify UI to display multiple entries chronologically

4. **Data Migration**:
   - Migrate existing date-based records to include timestamps
   - Preserve all existing data during schema changes

## Reference Documents

- API Documentation - Health Metrics endpoints
- Database schema documentation
- Health tracking feature specification

## Technical References

- Backend: `backend/laravel-app/database/migrations/` - health metrics table migration
- Backend: `backend/laravel-app/app/Models/HealthMetric.php` - HealthMetric model
- Backend: `backend/laravel-app/app/Http/Controllers/HealthMetricController.php` - API controller
- Frontend: `app/lib/features/health_tracking/` - health tracking domain layer
- Database: health_metrics table schema

## Testing

- [x] Database migration created for DATE to TIMESTAMP conversion
- [x] Backend API updated to remove date uniqueness constraint
- [x] Frontend updated to send full timestamps instead of dates
- [x] App builds successfully with all changes
- [x] Backend model updated for datetime casting
- [x] Sync logic updated to allow multiple daily entries per day
- [x] **PRODUCTION TESTING CONFIRMED**: Multiple health metrics per day now work correctly

## Notes

- This is a high-priority bug as it limits core health tracking functionality
- Users need to track multiple measurements per day for accurate health monitoring
- Breaking change requires careful migration planning
- Should be implemented before Sprint 25-26 (Cloud Sync) to avoid sync conflicts

## History

- 2026-01-17 - Created
- 2026-01-17 - Status changed to ✅ Completed - Implemented timestamp support for multiple daily entries</content>
<parameter name="filePath">/Volumes/T7/src/flutter-health-management-app-for-android/project-management/backlog/bugs/BF-003-backend-only-one-health-metric-per-day.md
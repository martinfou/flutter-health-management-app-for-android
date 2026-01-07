# Feature Request: FR-026 - Weight Data Sync with Backend (Multi-User Support)

**Status**: ⭕ Not Started  
**Priority**: 🟠 High  
**Story Points**: 8 (Fibonacci: 1, 2, 3, 5, 8, 13)  
**Created**: 2026-01-06  
**Updated**: 2026-01-06  
**Assigned Sprint**: Backlog

## Description

Implement cloud synchronization for weight data with the backend API, enabling multi-user support and cross-device data access. This feature will allow users to sync their weight entries to the cloud, ensuring data persistence across devices and enabling secure multi-user data isolation. Each user's weight data will be associated with their authenticated account and accessible only to them.

## User Story

As a mobile app user, 
I want my weight entries to sync with the cloud backend, 
so that I can access my weight tracking data across multiple devices and ensure my data is backed up securely while maintaining privacy from other users.

## Acceptance Criteria

### Backend API Endpoints
- [ ] POST /api/health-metrics/weight - Create new weight entry (authenticated)
- [ ] GET /api/health-metrics/weight - Fetch weight entries with pagination (authenticated)
- [ ] PUT /api/health-metrics/weight/:id - Update weight entry (authenticated, user-owned only)
- [ ] DELETE /api/health-metrics/weight/:id - Delete weight entry (authenticated, user-owned only)
- [ ] POST /api/health-metrics/weight/sync - Bulk sync weight entries (authenticated)
- [ ] GET /api/health-metrics/weight/sync - Incremental sync with timestamp filtering (authenticated)

### Multi-User Support
- [ ] All weight data is associated with authenticated user ID (user_id foreign key)
- [ ] Users can only access their own weight data (enforced at API level)
- [ ] Database queries filter by user_id to ensure data isolation
- [ ] JWT authentication required for all weight sync endpoints
- [ ] Proper authorization checks prevent cross-user data access
- [ ] User deletion cascades to delete all associated weight data (GDPR compliance)

### Database Schema
- [ ] Weight entries table created with proper indexes
- [ ] user_id foreign key references users table
- [ ] Columns: id, user_id, weight_value, unit, timestamp, created_at, updated_at, deleted_at (soft delete)
- [ ] Composite index on (user_id, timestamp) for efficient queries
- [ ] Index on user_id for user-specific queries
- [ ] Index on timestamp for chronological sorting

### Flutter App Integration
- [ ] Weight sync service implemented in Flutter app
- [ ] Local weight entries sync to backend after creation
- [ ] Background sync pulls latest weight data from backend
- [ ] Conflict resolution implemented (timestamp-based, last write wins)
- [ ] Offline support: local data persists if sync fails
- [ ] Sync status indicator shows when data is syncing
- [ ] Error handling for network failures and sync conflicts
- [ ] Automatic retry mechanism for failed syncs

### Data Synchronization
- [ ] Incremental sync: only fetch weight entries modified since last sync
- [ ] Bulk upload: send multiple weight entries in single request
- [ ] Timestamp tracking: last_synced_at stored locally
- [ ] Conflict detection: compare local and server timestamps
- [ ] Merge strategy: last write wins (newest timestamp)
- [ ] Sync on app launch (if authenticated)
- [ ] Sync after creating/updating/deleting weight entry
- [ ] Manual sync option in settings

### Security & Privacy
- [ ] All API requests use HTTPS
- [ ] JWT token included in Authorization header
- [ ] Token expiration handled gracefully (refresh token flow)
- [ ] User data isolation enforced at database query level
- [ ] Input validation on all weight data fields
- [ ] SQL injection prevention via prepared statements
- [ ] Rate limiting: 100 requests/minute per user

### Error Handling
- [ ] Network error handling with user-friendly messages
- [ ] Authentication errors trigger re-login flow
- [ ] Sync conflict errors show resolution options
- [ ] Validation errors display specific field issues
- [ ] Server errors logged and reported gracefully
- [ ] Offline mode gracefully degrades (local-only data)

### Testing
- [ ] Unit tests for sync service logic
- [ ] Integration tests for API endpoints
- [ ] Multi-user isolation tests (verify user A cannot access user B's data)
- [ ] Conflict resolution tests
- [ ] Offline/online transition tests
- [ ] Authentication token expiration tests

## Business Value

This feature provides critical value by:
- **Multi-Device Access**: Users can access weight data across all their devices (phone, tablet, web)
- **Data Backup**: Cloud storage ensures data is not lost if device is lost/damaged
- **User Privacy**: Multi-user support enables family members to use the app with isolated data
- **Scalability**: Backend infrastructure supports future growth and additional features
- **Trust & Reliability**: Cloud sync demonstrates app maturity and reliability
- **Competitive Advantage**: Matches feature parity with leading health tracking apps

## Technical Requirements

### Backend Technology Stack
- **Framework**: Slim Framework 4.x (PHP 8.1+)
- **Database**: MySQL with UTF-8 encoding (utf8mb4)
- **Authentication**: JWT tokens (firebase/php-jwt library)
- **API Style**: REST API with JSON
- **Security**: HTTPS/SSL (Let's Encrypt via DreamHost)
- **Hosting**: DreamHost shared hosting

### API Request/Response Format

**POST /api/health-metrics/weight** (Create weight entry):
```json
Request:
{
  "weight_value": 75.5,
  "unit": "kg",
  "timestamp": "2026-01-06T20:30:00Z"
}

Response (201 Created):
{
  "id": "uuid-12345",
  "user_id": "user-uuid",
  "weight_value": 75.5,
  "unit": "kg",
  "timestamp": "2026-01-06T20:30:00Z",
  "created_at": "2026-01-06T20:30:05Z",
  "updated_at": "2026-01-06T20:30:05Z"
}
```

**GET /api/health-metrics/weight** (Fetch weight entries):
```json
Request: GET /api/health-metrics/weight?limit=10&offset=0&since=2026-01-01T00:00:00Z

Response (200 OK):
{
  "data": [
    {
      "id": "uuid-12345",
      "weight_value": 75.5,
      "unit": "kg",
      "timestamp": "2026-01-06T20:30:00Z",
      "created_at": "2026-01-06T20:30:05Z",
      "updated_at": "2026-01-06T20:30:05Z"
    }
  ],
  "pagination": {
    "total": 100,
    "limit": 10,
    "offset": 0
  }
}
```

**POST /api/health-metrics/weight/sync** (Bulk sync):
```json
Request:
{
  "entries": [
    {
      "local_id": "local-123",
      "weight_value": 75.5,
      "unit": "kg",
      "timestamp": "2026-01-06T20:30:00Z"
    }
  ]
}

Response (200 OK):
{
  "synced": [
    {
      "local_id": "local-123",
      "server_id": "uuid-12345",
      "status": "created"
    }
  ],
  "conflicts": []
}
```

### Database Schema

```sql
CREATE TABLE weight_entries (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    weight_value DECIMAL(6,2) NOT NULL,
    unit VARCHAR(10) NOT NULL,
    timestamp DATETIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_timestamp (user_id, timestamp),
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Flutter Implementation

**File**: `app/lib/features/health_tracking/data/services/weight_sync_service.dart`
- Sync weight entries to backend
- Fetch weight entries from backend
- Handle conflicts and merge data
- Manage sync state and timestamps

**File**: `app/lib/features/health_tracking/data/repositories/weight_repository.dart`
- Integrate sync service with local repository
- Coordinate local and remote data sources
- Implement offline-first pattern

**File**: `app/lib/core/sync/sync_manager.dart`
- Manage overall sync orchestration
- Handle authentication state
- Coordinate sync across different data types

### Performance Requirements
- API response time < 500ms for standard operations
- Bulk sync supports up to 100 entries per request
- Pagination default limit: 100 entries
- Database queries optimized with proper indexes
- Incremental sync reduces data transfer (only fetch changes since last sync)

### Conflict Resolution Strategy
- **Timestamp-based**: Last write wins (entry with newest timestamp)
- **Detection**: Compare local and server timestamps
- **Resolution**: Server timestamp > local timestamp → server wins, else local wins
- **User notification**: Optional notification for significant conflicts
- **Merge**: For complex cases, preserve both versions and let user choose

## Reference Documents

- `FR-020-backend-infrastructure.md` - Backend infrastructure requirements
- `FR-009-user-authentication.md` - User authentication with Google OAuth
- `FR-008-cloud-sync-multi-device-support.md` - Cloud sync architecture
- `../../app/docs/api/api-documentation.md` - API endpoint specifications
- `../../project-management-old/artifacts/phase-3-integration/sync-architecture-design.md` - Sync architecture design

## Technical References

### Backend
- **Controller**: `api/src/Controllers/HealthMetricsController.php` (weight endpoints)
- **Service**: `api/src/Services/WeightSyncService.php` (sync logic)
- **Model**: `api/src/Models/WeightEntry.php` (weight data model)
- **Middleware**: `api/src/Middleware/AuthMiddleware.php` (JWT authentication)
- **Database**: `weight_entries` table in MySQL

### Flutter App
- **Service**: `app/lib/features/health_tracking/data/services/weight_sync_service.dart`
- **Repository**: `app/lib/features/health_tracking/data/repositories/weight_repository.dart`
- **Sync Manager**: `app/lib/core/sync/sync_manager.dart`
- **Auth Service**: `app/lib/core/auth/authentication_service.dart`

## Dependencies

### Prerequisites (Must Complete First)
- FR-020 (Backend Infrastructure) - Backend API must be operational
- FR-009 (User Authentication) - Users must be authenticated to sync data
- FR-008 (Cloud Sync Multi-Device Support) - Core sync infrastructure must exist

### Blocks (Cannot Start Until This Is Complete)
- None (this is a specific implementation of the general sync architecture)

### Parallel Work Possible
- Other health metric sync implementations (meals, exercises, medications)
- Frontend UI improvements for sync status display
- Sync conflict resolution UI

## Notes

- **Multi-User Isolation Critical**: User data isolation is paramount for privacy and security
- **GDPR Compliance**: User deletion must cascade to all weight data
- **Offline-First**: App must function fully offline, sync when online
- **Authentication Required**: All sync operations require valid JWT token
- **Incremental Sync**: Use `since` parameter to reduce bandwidth and improve performance
- **Conflict Resolution**: Timestamp-based (last write wins) is simple and effective for weight data
- **Testing Multi-User**: Critical to test that User A cannot access User B's data
- **Rate Limiting**: Prevent abuse while allowing normal usage patterns
- **Error Handling**: Graceful degradation when backend is unavailable
- **Future Enhancement**: Real-time sync with WebSockets for instant updates
- **Future Enhancement**: Sync conflict UI for manual resolution
- **Future Enhancement**: Sync analytics dashboard (sync frequency, data volume, errors)

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

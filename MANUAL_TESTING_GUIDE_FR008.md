# Manual Testing Guide: FR-008 Cloud Sync & Multi-Device Support

## Prerequisites

1. **Backend**: Laravel app running on `http://localhost:8000` (or deployed URL)
2. **Database**: Fresh/seeded with test users
3. **Tools**:
   - Postman or curl for API testing
   - Flutter app running on 2 emulators/devices (for multi-device testing)
   - Browser dev tools for checking sync status

## Quick Start

### 1. Get Authentication Token

```bash
# Create test user via Laravel Tinker
php artisan tinker

# In tinker:
$user = \App\Models\User::factory()->create([
    'name' => 'Test User',
    'email' => 'test@example.com',
    'password' => bcrypt('password123')
]);

$jwtService = app(\App\Services\JwtService::class);
$token = $jwtService->generateAccessToken([
    'user_id' => $user->id,
    'email' => $user->email
]);

echo $token;
```

Save this token for API requests.

---

## Testing Scenarios

### Scenario 1: Basic Meals Sync (Create & Retrieve)

#### Test 1.1: Create Meal via Sync API

```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440001",
        "date": "2026-01-18",
        "meal_type": "breakfast",
        "name": "Scrambled Eggs",
        "calories": 350,
        "protein_g": 25,
        "fats_g": 20,
        "carbs_g": 5,
        "created_at": "2026-01-18T08:00:00Z",
        "updated_at": "2026-01-18T08:00:00Z"
      }
    ]
  }'
```

**Expected Response:**
```json
{
  "data": {
    "processed": {
      "created": 1,
      "updated": 0,
      "deleted": 0
    }
  }
}
```

#### Test 1.2: Verify Meal in Database

```bash
# Check via API
curl http://localhost:8000/api/v1/meals \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected**: Response includes your "Scrambled Eggs" meal

---

### Scenario 2: Conflict Resolution (Timestamp-Based)

#### Test 2.1: Create Initial Meal

```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440002",
        "date": "2026-01-18",
        "meal_type": "lunch",
        "name": "Chicken Salad",
        "calories": 450,
        "protein_g": 35,
        "fats_g": 15,
        "carbs_g": 20,
        "updated_at": "2026-01-18T12:00:00Z"
      }
    ]
  }'
```

#### Test 2.2: Send Update with Newer Timestamp (Should Win)

```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440002",
        "date": "2026-01-18",
        "meal_type": "lunch",
        "name": "Chicken Salad - Updated",
        "calories": 500,
        "protein_g": 40,
        "fats_g": 18,
        "carbs_g": 22,
        "updated_at": "2026-01-18T13:00:00Z"
      }
    ]
  }'
```

**Expected Response:**
```json
{
  "data": {
    "processed": {
      "created": 0,
      "updated": 1,
      "deleted": 0
    }
  }
}
```

#### Test 2.3: Send Update with Older Timestamp (Should Be Rejected)

```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440002",
        "date": "2026-01-18",
        "meal_type": "lunch",
        "name": "Chicken Salad - Old Version",
        "calories": 400,
        "updated_at": "2026-01-18T11:00:00Z"
      }
    ]
  }'
```

**Expected**: No update (older timestamp ignored)

---

### Scenario 3: Delta Sync (Fetch Only Changes)

#### Test 3.1: Perform Initial Sync (Full Pull)

```bash
# First sync with very old last_sync_timestamp
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "last_sync_timestamp": "2020-01-01T00:00:00Z"
  }'
```

**Expected**: Returns all meals

#### Test 3.2: Create New Meal

```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440003",
        "date": "2026-01-18",
        "meal_type": "dinner",
        "name": "Grilled Fish",
        "calories": 380,
        "updated_at": "2026-01-18T18:30:00Z"
      }
    ]
  }'
```

#### Test 3.3: Delta Sync (Recent Timestamp)

```bash
# Use a recent timestamp (within last 5 minutes)
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "last_sync_timestamp": "2026-01-18T18:00:00Z"
  }'
```

**Expected**: Returns only meals changed after 18:00 (should include "Grilled Fish")

---

### Scenario 4: Soft Delete Sync

#### Test 4.1: Create Meal to Delete

```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440004",
        "date": "2026-01-18",
        "meal_type": "snack",
        "name": "Snack to Delete",
        "calories": 150,
        "updated_at": "2026-01-18T15:00:00Z"
      }
    ]
  }'
```

#### Test 4.2: Delete via Sync (Set deleted_at)

```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440004",
        "deleted_at": "2026-01-18T15:30:00Z",
        "updated_at": "2026-01-18T15:30:00Z"
      }
    ]
  }'
```

**Expected Response:**
```json
{
  "data": {
    "processed": {
      "created": 0,
      "updated": 0,
      "deleted": 1
    }
  }
}
```

#### Test 4.3: Verify Soft Deleted in DB

```bash
php artisan tinker

# Check soft deleted:
\App\Models\Meal::onlyTrashed()->where('client_id', '550e8400-e29b-41d4-a716-446655440004')->first();
```

**Expected**: Finds the soft-deleted meal

---

### Scenario 5: Exercises Sync

#### Test 5.1: Create Exercise

```bash
curl -X POST http://localhost:8000/api/v1/exercises/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "exercises": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440010",
        "type": "cardio",
        "name": "Morning Run",
        "date": "2026-01-18",
        "duration_minutes": 30,
        "calories_burned": 350,
        "distance_km": 5,
        "updated_at": "2026-01-18T06:30:00Z"
      }
    ]
  }'
```

**Expected Response:**
```json
{
  "data": {
    "synced_count": 1,
    "updated_count": 0
  }
}
```

#### Test 5.2: Update Exercise (Date Matching)

```bash
curl -X POST http://localhost:8000/api/v1/exercises/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "exercises": [
      {
        "type": "cardio",
        "name": "Morning Run",
        "date": "2026-01-18",
        "duration_minutes": 45,
        "calories_burned": 420,
        "distance_km": 7,
        "updated_at": "2026-01-18T06:45:00Z"
      }
    ]
  }'
```

**Expected Response:**
```json
{
  "data": {
    "synced_count": 0,
    "updated_count": 1
  }
}
```

---

### Scenario 6: Medications Sync

#### Test 6.1: Create Medication

```bash
curl -X POST http://localhost:8000/api/v1/medications/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440020",
        "name": "Aspirin",
        "dosage": 100,
        "unit": "mg",
        "frequency": "Once daily",
        "start_date": "2026-01-18",
        "active": true,
        "updated_at": "2026-01-18T08:00:00Z"
      }
    ]
  }'
```

**Expected**: Medication created successfully

#### Test 6.2: Update Medication Status

```bash
curl -X POST http://localhost:8000/api/v1/medications/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [
      {
        "client_id": "550e8400-e29b-41d4-a716-446655440020",
        "name": "Aspirin",
        "active": false,
        "end_date": "2026-01-20",
        "updated_at": "2026-01-18T12:00:00Z"
      }
    ]
  }'
```

---

### Scenario 7: Multi-Device Sync

#### Test 7.1: Simulate Device A (First Device)

```bash
# Device A creates meal with its client_id
DEVICE_A_ID="device-a-uuid-1234"
CLIENT_ID_A="550e8400-e29b-41d4-a716-446655440050"

curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"changes\": [
      {
        \"client_id\": \"$CLIENT_ID_A\",
        \"date\": \"2026-01-18\",
        \"meal_type\": \"breakfast\",
        \"name\": \"Device A Breakfast\",
        \"calories\": 400,
        \"updated_at\": \"2026-01-18T08:00:00Z\"
      }
    ]
  }"
```

#### Test 7.2: Simulate Device B (Second Device)

```bash
# Device B fetches all meals (pulls Device A's changes)
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "last_sync_timestamp": "2026-01-18T00:00:00Z"
  }'
```

**Expected**: Device B sees "Device A Breakfast" meal in response

#### Test 7.3: Device B Creates Different Meal

```bash
CLIENT_ID_B="550e8400-e29b-41d4-a716-446655440051"

curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"changes\": [
      {
        \"client_id\": \"$CLIENT_ID_B\",
        \"date\": \"2026-01-18\",
        \"meal_type\": \"lunch\",
        \"name\": \"Device B Lunch\",
        \"calories\": 550,
        \"updated_at\": \"2026-01-18T12:30:00Z\"
      }
    ]
  }"
```

#### Test 7.4: Device A Fetches Device B's Changes

```bash
# Device A syncs and should get Device B's meal
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "last_sync_timestamp": "2026-01-18T09:00:00Z"
  }'
```

**Expected**: Returns "Device B Lunch" meal

---

### Scenario 8: Flutter App Testing

#### Test 8.1: Login on First Device

1. Launch Flutter app on emulator/device
2. Click "Login with Google"
3. Authenticate with test account
4. Wait for initial sync to complete
5. Check sync status indicator in UI (should show "Synced")

#### Test 8.2: Create Data on First Device

1. Add a meal/exercise/medication
2. Watch sync status indicator (should briefly show "Syncing")
3. Once synced, verify data persists after app restart

#### Test 8.3: Multi-Device: Launch Second Device

1. Launch Flutter app on second emulator/device
2. Login with same account
3. Perform pull-to-refresh
4. Verify data from first device appears

#### Test 8.4: Create Conflicting Data

1. **Device A**: Create "Lunch - Version 1" at 12:00
2. Close backend sync temporarily (stop receiving data)
3. **Device B**: Create "Lunch - Version 2" for same date/meal_type
4. Re-enable backend sync
5. Check: Device A should have newest timestamp win

#### Test 8.5: Offline Sync Queue

1. **Device A**: Turn off WiFi/Mobile data
2. Add new meal/exercise
3. App should queue it locally (show "Offline" badge)
4. Turn data back on
5. Sync should automatically push queued changes

---

## Complete Demo Checklist

Use this to verify all Sprint 25-26 deliverables:

- [ ] **Meals Sync**
  - [ ] Create meal via sync API
  - [ ] Update existing meal
  - [ ] Delete meal (soft delete)
  - [ ] Pull meals via delta sync
  - [ ] Multi-device meal sync works

- [ ] **Exercises Sync**
  - [ ] Create exercise via sync
  - [ ] Update exercise with date matching
  - [ ] Create/update exercise templates
  - [ ] Multi-device exercise sync

- [ ] **Medications Sync**
  - [ ] Create medication
  - [ ] Update medication status
  - [ ] Multi-device medication sync

- [ ] **Conflict Resolution**
  - [ ] Newer timestamp wins
  - [ ] Older timestamp rejected
  - [ ] Concurrent edits handled correctly

- [ ] **Delta Sync**
  - [ ] Returns only changed records
  - [ ] Reduces bandwidth vs full sync
  - [ ] Works for all data types

- [ ] **Multi-Device Coordination**
  - [ ] Device A creates, Device B sees it
  - [ ] Device B creates, Device A sees it
  - [ ] No conflicts or duplicates
  - [ ] Sync works reliably between devices

- [ ] **Offline Support**
  - [ ] App queues changes when offline
  - [ ] Syncs automatically when online
  - [ ] No data loss

- [ ] **UI/UX**
  - [ ] Sync status shows in UI
  - [ ] Manual sync button works
  - [ ] Clear error messages
  - [ ] Loading states visible

---

## Troubleshooting

### Issue: "Not authenticated" Error

**Solution**: Verify JWT token is valid and not expired. Get new token via Tinker.

### Issue: Conflicts Not Resolving

**Solution**: Check that `updated_at` timestamps are different. Sync uses timestamp comparison.

### Issue: Date Not Matching in Exercises

**Solution**: Ensure date format is `YYYY-MM-DD`. The sync uses `whereDate()` for comparison.

### Issue: Soft Deleted Records Still Appearing

**Solution**: Query should exclude trashed records by default in Eloquent.

### Issue: Multi-Device Sync Not Working

**Solution**:
- Verify both devices logged into same account
- Check `last_sync_timestamp` is being set correctly
- Ensure backend is returning changes with proper `updated_at`

---

## Performance Benchmarks

Target metrics to verify:

- **Initial sync time**: < 2 seconds for 100 records
- **Delta sync time**: < 500ms for 10 new records
- **Network usage**: Delta sync uses 80-90% less bandwidth than full sync
- **Conflict resolution**: < 100ms for update evaluation

---

## Notes

- All client_ids should be UUIDs for consistency
- Timestamps should be ISO 8601 format with timezone
- Always include `updated_at` in sync requests
- Token expires after some time - refresh if needed


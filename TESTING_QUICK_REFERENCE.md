# FR-008 Testing Quick Reference Card

## TL;DR - Get Started in 5 Minutes

### 1. Get Token (2 minutes)
```bash
cd backend/laravel-app && php artisan tinker
# Run these commands:
$u = \App\Models\User::factory()->create(['email' => 'test' . time() . '@example.com']);
$t = app(\App\Services\JwtService::class)->generateAccessToken(['user_id' => $u->id, 'email' => $u->email]);
echo $t;
exit
# Copy the token
```

### 2. Test (3 minutes)
```bash
TOKEN="your_copied_token"

# Create a meal
./scripts/test_sync.sh "$TOKEN" meals-create
# Should return: "created": 1

# List meals
./scripts/test_sync.sh "$TOKEN" meals-list
# Should show your meal

# Test conflict resolution
./scripts/test_sync.sh "$TOKEN" conflict-test
# Should reject old timestamp
```

---

## Testing Matrix

| Component | Endpoint | Status | How to Test |
|-----------|----------|--------|------------|
| **Meals Sync** | POST `/api/v1/meals/sync` | ✅ | `./test_sync.sh $TOKEN meals-create` |
| **Exercises Sync** | POST `/api/v1/exercises/sync` | ✅ | `./test_sync.sh $TOKEN exercises-create` |
| **Medications Sync** | POST `/api/v1/medications/sync` | ✅ | `./test_sync.sh $TOKEN meds-create` |
| **Delta Sync** | POST `/api/v1/{resource}/sync` + `last_sync_timestamp` | ✅ | `./test_sync.sh $TOKEN delta-sync` |
| **Conflict Resolution** | Timestamp-based "newest wins" | ✅ | `./test_sync.sh $TOKEN conflict-test` |
| **Soft Deletes** | `deleted_at` field | ✅ | `./test_sync.sh $TOKEN meals-delete` |
| **Multi-Device** | Same token on 2 devices | ✅ | Manual: Use same account on 2 devices |

---

## One-Liner Test Commands

```bash
# Export token for easy reuse
export TOKEN="your_jwt_token_here"

# Create test data
./scripts/test_sync.sh $TOKEN meals-create
./scripts/test_sync.sh $TOKEN exercises-create
./scripts/test_sync.sh $TOKEN meds-create

# Verify sync
./scripts/test_sync.sh $TOKEN meals-list
./scripts/test_sync.sh $TOKEN delta-sync

# Test features
./scripts/test_sync.sh $TOKEN conflict-test        # Conflict resolution
./scripts/test_sync.sh $TOKEN meals-delete        # Soft delete
```

---

## Manual API Tests (Postman/curl)

### Create Meal
```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [{
      "client_id": "'$(uuidgen)'",
      "date": "2026-01-18",
      "meal_type": "breakfast",
      "name": "Test Meal",
      "calories": 400,
      "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }]
  }' | jq
```

### Delta Sync (Only Recent Changes)
```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "last_sync_timestamp": "2026-01-18T00:00:00Z"
  }' | jq
```

### Test Soft Delete
```bash
curl -X POST http://localhost:8000/api/v1/meals/sync \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": [{
      "client_id": "550e8400-e29b-41d4-a716-446655440001",
      "deleted_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
      "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }]
  }' | jq
```

---

## Flutter App Testing

### Setup
1. Run app on **Device A**: Login → Add meal/exercise → Wait for sync
2. Run app on **Device B**: Login with same account → Pull-to-refresh

### Expected Results
- ✅ Device B sees Device A's data after refresh
- ✅ Sync indicator shows "Syncing..." then "Synced"
- ✅ No duplicates
- ✅ Changes appear within 2 seconds

### Test Offline Queue
1. **Device A**: Turn off WiFi/mobile data
2. Add meal/exercise (should show "Offline" indicator)
3. Turn data back on (should auto-sync)

---

## Expected Responses

### Success Response
```json
{
  "success": true,
  "data": {
    "processed": {
      "created": 1,
      "updated": 0,
      "deleted": 0
    }
  }
}
```

### Delta Sync Response
```json
{
  "success": true,
  "data": {
    "changes": [
      {
        "client_id": "550e8400-...",
        "name": "Recent Meal",
        "calories": 450,
        "updated_at": "2026-01-18T14:30:00Z"
      }
    ]
  }
}
```

### Conflict Test (Old Timestamp Should Be Ignored)
```json
{
  "success": true,
  "data": {
    "processed": {
      "created": 0,
      "updated": 0,  // ← Should be 0 (rejected old update)
      "deleted": 0
    }
  }
}
```

---

## Verification Checklist

- [ ] Can create meals/exercises/medications via sync
- [ ] Delta sync returns only recent changes
- [ ] Older timestamps are rejected (conflict resolution)
- [ ] Soft deletes work (deleted_at is set)
- [ ] Multi-device: Device B sees Device A's changes
- [ ] Offline mode: Queue works, auto-syncs when online
- [ ] No data loss or duplicates
- [ ] Sync completes in < 2 seconds

---

## Emergency Commands

```bash
# Reset test user's data
php artisan tinker
\App\Models\Meal::where('user_id', 1)->forceDelete();
\App\Models\Exercise::where('user_id', 1)->forceDelete();
\App\Models\Medication::where('user_id', 1)->forceDelete();
exit

# Run all sync tests
php artisan test tests/Feature/MealsSyncTest.php tests/Feature/Api/MedicationsTest.php

# View sync logs (if enabled)
tail -f storage/logs/laravel.log | grep -i sync
```

---

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| 401 Unauthorized | Token expired - Get new token via Tinker |
| Date not matching | Use format YYYY-MM-DD exactly |
| No conflicts resolved | Check `updated_at` timestamps are different |
| Multi-device sync failed | Use same JWT token (same user account) |
| Offline data not syncing | Turn data back on and wait 30 seconds |

---

## Performance Targets

- Initial sync: **< 2 seconds** for 100 records
- Delta sync: **< 500ms** for 10 new records
- Bandwidth: **80-90% reduction** vs full sync
- Updates/second: **100+** records

---

## Files Reference

- 📖 Full guide: `MANUAL_TESTING_GUIDE_FR008.md`
- 🔧 Test script: `scripts/test_sync.sh`
- 📋 This reference: `TESTING_QUICK_REFERENCE.md`

---

**Last Updated**: 2026-01-18
**Status**: ✅ All 28 sync tests passing
**Ready for**: Manual testing and deployment

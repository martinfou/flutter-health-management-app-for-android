<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Meal;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class MealsSyncTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $token;

    protected function setUp(): void
    {
        parent::setUp();
        // Create user
        $this->user = User::factory()->create();

        // Generate JWT token using JwtService
        $jwtService = app(\App\Services\JwtService::class);
        $payload = ['user_id' => $this->user->id, 'email' => $this->user->email];
        $this->token = $jwtService->generateAccessToken($payload);
    }

    /**
     * Test creating a new meal via sync
     */
    public function test_sync_creates_new_meal()
    {
        $clientId = Str::uuid()->toString();

        $payload = [
            'changes' => [
                [
                    'client_id' => $clientId,
                    'date' => '2026-01-18',
                    'meal_type' => 'breakfast',
                    'name' => 'Test Breakfast',
                    'calories' => 500,
                    'updated_at' => now()->toIso8601String(),
                ]
            ]
        ];

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $this->token])
            ->postJson('/api/v1/meals/sync', $payload);

        $response->assertStatus(200)
            ->assertJsonPath('data.processed.created', 1);

        $this->assertDatabaseHas('meals', [
            'client_id' => $clientId,
            'name' => 'Test Breakfast',
            'user_id' => $this->user->id,
        ]);
    }

    /**
     * Test conflict resolution: Client update wins if newer
     */
    public function test_sync_conflict_client_wins_if_newer()
    {
        $clientId = Str::uuid()->toString();

        // Create initial meal on server (older)
        $meal = Meal::create([
            'user_id' => $this->user->id,
            'client_id' => $clientId,
            'date' => '2026-01-18',
            'meal_type' => 'lunch',
            'name' => 'Old Name',
        ]);

        // Force updated_at to be in the past
        $meal->updated_at = now()->subHour();
        $meal->save(['timestamps' => false]);

        $payload = [
            'changes' => [
                [
                    'client_id' => $clientId,
                    'date' => '2026-01-18',
                    'meal_type' => 'lunch',
                    'name' => 'New Name', // Changed
                    'updated_at' => now()->toIso8601String(), // Newer
                ]
            ]
        ];

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $this->token])
            ->postJson('/api/v1/meals/sync', $payload);

        $response->assertStatus(200)
            ->assertJsonPath('data.processed.updated', 1);

        $this->assertDatabaseHas('meals', [
            'id' => $meal->id,
            'name' => 'New Name',
        ]);
    }

    /**
     * Test conflict resolution: Server wins if client is older
     */
    public function test_sync_conflict_server_wins_if_newer()
    {
        $clientId = Str::uuid()->toString();

        // Create initial meal on server (newer)
        $meal = Meal::create([
            'user_id' => $this->user->id,
            'client_id' => $clientId,
            'date' => '2026-01-18',
            'meal_type' => 'lunch',
            'name' => 'Server Name',
        ]);

        // Force updated_at to be NOW (ensure it is newer than client payload)
        $meal->updated_at = now();
        $meal->save(['timestamps' => false]);

        $payload = [
            'changes' => [
                [
                    'client_id' => $clientId,
                    'date' => '2026-01-18',
                    'meal_type' => 'lunch',
                    'name' => 'Client Name',
                    'updated_at' => now()->subHour()->toIso8601String(), // Older
                ]
            ]
        ];

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $this->token])
            ->postJson('/api/v1/meals/sync', $payload);

        $response->assertStatus(200)
            ->assertJsonPath('data.processed.updated', 0); // No update

        $this->assertDatabaseHas('meals', [
            'id' => $meal->id,
            'name' => 'Server Name', // Should remain unchanged
        ]);
    }

    /**
     * Test sync soft deletion
     */
    public function test_sync_handles_soft_deletion()
    {
        $clientId = Str::uuid()->toString();

        $meal = Meal::create([
            'user_id' => $this->user->id,
            'client_id' => $clientId,
            'date' => '2026-01-18',
            'meal_type' => 'dinner',
            'name' => 'To Be Deleted',
        ]);

        // Ensure server record is older than deletion request
        $meal->updated_at = now()->subHour();
        $meal->save(['timestamps' => false]);

        $deleteTime = now()->toIso8601String();

        $payload = [
            'changes' => [
                [
                    'client_id' => $clientId,
                    'deleted_at' => $deleteTime,
                    'updated_at' => $deleteTime,
                ]
            ]
        ];

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $this->token])
            ->postJson('/api/v1/meals/sync', $payload);

        $response->assertStatus(200)
            ->assertJsonPath('data.processed.deleted', 1);

        $this->assertSoftDeleted('meals', [
            'id' => $meal->id,
        ]);
    }

    /**
     * Test delta sync: fetching only changes
     */
    public function test_delta_sync_returns_changes()
    {
        $clientId1 = Str::uuid()->toString();
        $clientId2 = Str::uuid()->toString();

        // Meal 1: Created before last sync
        $oldMeal = Meal::create([
            'user_id' => $this->user->id,
            'client_id' => $clientId1,
            'date' => '2026-01-18',
            'meal_type' => 'snack',
            'name' => 'Old Snack',
        ]);
        // Manually set old date
        $oldMeal->updated_at = now()->subDays(2);
        $oldMeal->save(['timestamps' => false]);

        // Meal 2: Created after last sync (SHOULD be returned)
        $newMeal = Meal::create([
            'user_id' => $this->user->id,
            'client_id' => $clientId2,
            'date' => '2026-01-18',
            'meal_type' => 'snack',
            'name' => 'New Snack',
        ]);
        // Set to now
        $newMeal->updated_at = now();
        $newMeal->save(['timestamps' => false]);

        $lastSyncTime = now()->subDay()->toIso8601String();

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $this->token])
            ->postJson('/api/v1/meals/sync', [
                'last_sync_timestamp' => $lastSyncTime
            ]);

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data.changes') // Only 1 meal changed
            ->assertJsonPath('data.changes.0.client_id', $clientId2);
    }
}

<?php

namespace Tests\Feature\Api;

use App\Models\MealPlan;

class MealPlansTest extends ApiTestCase
{
    public function setUp(): void
    {
        parent::setUp();
        $this->authenticateUser();
    }

    public function test_can_create_meal_plan(): void
    {
        $planData = [
            'name' => 'Keto Diet Plan',
            'description' => 'High fat, low carb ketogenic diet',
            'start_date' => now()->format('Y-m-d'),
            'end_date' => now()->addMonths(3)->format('Y-m-d'),
            'daily_calorie_target' => 2000,
            'daily_protein_target' => 150,
            'daily_fats_target' => 150,
            'daily_carbs_target' => 50,
            'active' => true,
            'meals' => [
                ['type' => 'breakfast', 'name' => 'Avocado Eggs'],
                ['type' => 'lunch', 'name' => 'Salmon Salad']
            ],
            'goals' => ['weight_loss', 'ketosis'],
            'metadata' => ['difficulty' => 'intermediate']
        ];

        $response = $this->authenticatedPost('/api/v1/meal-plans', $planData);

        $response->assertStatus(201);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.meal_plan.name', 'Keto Diet Plan');
        $response->assertJsonPath('data.meal_plan.daily_calorie_target', 2000);
        $response->assertJsonPath('data.meal_plan.active', true);
        $this->assertDatabaseHas('meal_plans', [
            'user_id' => $this->user->id,
            'name' => 'Keto Diet Plan',
            'active' => true
        ]);
    }

    public function test_can_list_meal_plans(): void
    {
        MealPlan::factory()->count(3)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/meal-plans');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonStructure(['data', 'pagination']);
        $this->assertCount(3, $response->json('data'));
    }

    public function test_can_filter_active_meal_plans(): void
    {
        MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'active' => true,
            'name' => 'Active Plan'
        ]);
        MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'active' => false,
            'name' => 'Inactive Plan'
        ]);

        $response = $this->authenticatedGet('/api/v1/meal-plans?active_only=true');

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Active Plan', $response->json('data.0.name'));
    }

    public function test_only_one_meal_plan_can_be_active(): void
    {
        $plan1 = MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'active' => true,
            'name' => 'First Active Plan'
        ]);

        // Create a second active plan
        $response = $this->authenticatedPost('/api/v1/meal-plans', [
            'name' => 'Second Active Plan',
            'start_date' => now()->format('Y-m-d'),
            'active' => true,
        ]);

        $response->assertStatus(201);

        // First plan should no longer be active
        $plan1->refresh();
        $this->assertFalse($plan1->active);

        // Check database state
        $activePlans = MealPlan::where('user_id', $this->user->id)
            ->where('active', true)
            ->count();
        $this->assertEquals(1, $activePlans);
    }

    public function test_activating_meal_plan_deactivates_others_on_update(): void
    {
        $plan1 = MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'active' => true,
            'name' => 'Currently Active'
        ]);
        $plan2 = MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'active' => false,
            'name' => 'Will Become Active'
        ]);

        // Update plan2 to be active
        $response = $this->authenticatedPut("/api/v1/meal-plans/{$plan2->id}", [
            'active' => true
        ]);

        $response->assertStatus(200);

        // Refresh both plans
        $plan1->refresh();
        $plan2->refresh();

        $this->assertFalse($plan1->active);
        $this->assertTrue($plan2->active);
    }

    public function test_can_get_specific_meal_plan(): void
    {
        $plan = MealPlan::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet("/api/v1/meal-plans/{$plan->id}");

        $response->assertStatus(200);
        $response->assertJsonPath('data.meal_plan.id', $plan->id);
        $response->assertJsonPath('data.meal_plan.name', $plan->name);
    }

    public function test_cannot_get_other_users_meal_plan(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $plan = MealPlan::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedGet("/api/v1/meal-plans/{$plan->id}");

        $response->assertStatus(404);
    }

    public function test_can_update_meal_plan(): void
    {
        $plan = MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'daily_calorie_target' => 1800
        ]);

        $updateData = [
            'daily_calorie_target' => 2200,
            'description' => 'Updated plan description',
            'goals' => ['muscle_gain', 'maintenance']
        ];

        $response = $this->authenticatedPut("/api/v1/meal-plans/{$plan->id}", $updateData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.meal_plan.daily_calorie_target', 2200);
        $response->assertJsonPath('data.meal_plan.description', 'Updated plan description');
        $this->assertDatabaseHas('meal_plans', [
            'id' => $plan->id,
            'daily_calorie_target' => 2200
        ]);
    }

    public function test_cannot_update_other_users_meal_plan(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $plan = MealPlan::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedPut("/api/v1/meal-plans/{$plan->id}", [
            'daily_calorie_target' => 2500
        ]);

        $response->assertStatus(404);
    }

    public function test_can_delete_meal_plan(): void
    {
        $plan = MealPlan::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedDelete("/api/v1/meal-plans/{$plan->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('meal_plans', ['id' => $plan->id]);
    }

    public function test_cannot_delete_other_users_meal_plan(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $plan = MealPlan::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedDelete("/api/v1/meal-plans/{$plan->id}");

        $response->assertStatus(404);
    }

    public function test_can_sync_meal_plans(): void
    {
        $syncData = [
            'meal_plans' => [
                [
                    'name' => 'Mediterranean Diet',
                    'start_date' => now()->format('Y-m-d'),
                    'daily_calorie_target' => 1800,
                ],
                [
                    'name' => 'Paleo Plan',
                    'start_date' => now()->format('Y-m-d'),
                    'daily_calorie_target' => 2200,
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/meal-plans/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 2);
        $response->assertJsonPath('data.updated_count', 0);
        $this->assertDatabaseHas('meal_plans', [
            'user_id' => $this->user->id,
            'name' => 'Mediterranean Diet'
        ]);
        $this->assertDatabaseHas('meal_plans', [
            'user_id' => $this->user->id,
            'name' => 'Paleo Plan'
        ]);
    }

    public function test_sync_updates_existing_meal_plans(): void
    {
        // Create existing meal plan
        $existingPlan = MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Existing Plan',
            'daily_calorie_target' => 1500
        ]);

        $syncData = [
            'meal_plans' => [
                [
                    'name' => 'Existing Plan',
                    'daily_calorie_target' => 2000, // Updated target
                    'description' => 'Updated description',
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/meal-plans/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 0);
        $response->assertJsonPath('data.updated_count', 1);
        $existingPlan->refresh();
        $this->assertEquals(2000, $existingPlan->daily_calorie_target);
        $this->assertEquals('Updated description', $existingPlan->description);
    }

    public function test_sync_respects_active_plan_constraint(): void
    {
        // Create existing active plan
        $existingActive = MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'active' => true,
            'name' => 'Current Active'
        ]);

        $syncData = [
            'meal_plans' => [
                [
                    'name' => 'New Active Plan',
                    'start_date' => now()->format('Y-m-d'),
                    'active' => true,
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/meal-plans/sync', $syncData);

        $response->assertStatus(200);

        // Check that only the new plan is active
        $activePlans = MealPlan::where('user_id', $this->user->id)
            ->where('active', true)
            ->get();
        $this->assertCount(1, $activePlans);
        $this->assertEquals('New Active Plan', $activePlans->first()->name);
    }

    public function test_validation_errors_on_create(): void
    {
        $response = $this->authenticatedPost('/api/v1/meal-plans', [
            'name' => '',
            'start_date' => 'invalid-date',
            'end_date' => now()->subDay()->format('Y-m-d'), // Before start
            'daily_calorie_target' => 100, // Too low
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
        $this->assertArrayHasKey('name', $response->json('errors'));
        $this->assertArrayHasKey('start_date', $response->json('errors'));
    }

    public function test_end_date_must_be_after_start_date(): void
    {
        $response = $this->authenticatedPost('/api/v1/meal-plans', [
            'name' => 'Test Plan',
            'start_date' => now()->format('Y-m-d'),
            'end_date' => now()->subDay()->format('Y-m-d'),
        ]);

        $response->assertStatus(422);
        $this->assertArrayHasKey('end_date', $response->json('errors'));
    }

    public function test_validation_errors_on_sync(): void
    {
        $response = $this->authenticatedPost('/api/v1/meal-plans/sync', [
            'meal_plans' => [
                [
                    'name' => '',
                ]
            ]
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
    }

    public function test_unauthorized_access_without_token(): void
    {
        $response = $this->getJson('/api/v1/meal-plans');

        $response->assertStatus(401);
    }

    public function test_not_found_for_invalid_meal_plan_id(): void
    {
        $response = $this->authenticatedGet('/api/v1/meal-plans/99999');

        $response->assertStatus(404);
    }

    public function test_meal_plans_ordered_by_start_date_desc(): void
    {
        $plan1 = MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Older Plan',
            'start_date' => now()->subDays(10)->format('Y-m-d')
        ]);
        $plan2 = MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Newer Plan',
            'start_date' => now()->format('Y-m-d')
        ]);

        $response = $this->authenticatedGet('/api/v1/meal-plans');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertEquals('Newer Plan', $data[0]['name']); // Most recent start date first
        $this->assertEquals('Older Plan', $data[1]['name']);
    }

    public function test_default_active_state_is_false(): void
    {
        $response = $this->authenticatedPost('/api/v1/meal-plans', [
            'name' => 'Test Plan',
            'start_date' => now()->format('Y-m-d'),
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('data.meal_plan.active', false);
        $this->assertDatabaseHas('meal_plans', [
            'user_id' => $this->user->id,
            'name' => 'Test Plan',
            'active' => false
        ]);
    }

    public function test_active_only_parameter_various_formats(): void
    {
        MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'active' => true
        ]);
        MealPlan::factory()->create([
            'user_id' => $this->user->id,
            'active' => false
        ]);

        // Test 'true' string
        $response = $this->authenticatedGet('/api/v1/meal-plans?active_only=true');
        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));

        // Test '1' string
        $response = $this->authenticatedGet('/api/v1/meal-plans?active_only=1');
        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
    }
}
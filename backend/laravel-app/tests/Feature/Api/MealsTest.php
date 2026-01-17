<?php

namespace Tests\Feature\Api;

use App\Models\Meal;
use Carbon\Carbon;

class MealsTest extends ApiTestCase
{
    public function setUp(): void
    {
        parent::setUp();
        $this->authenticateUser();
    }

    public function test_can_create_meal(): void
    {
        $mealData = [
            'date' => now()->format('Y-m-d'),
            'meal_type' => 'breakfast',
            'name' => 'Oatmeal with Berries',
            'description' => 'Healthy breakfast meal',
            'ingredients' => ['oats', 'berries', 'milk'],
            'nutritional_info' => ['fiber' => 5, 'protein' => 10],
            'calories' => 350,
            'protein_g' => 12.5,
            'fats_g' => 8.0,
            'carbs_g' => 45.0,
            'fiber_g' => 6.5,
            'sugar_g' => 15.0,
            'sodium_mg' => 120,
            'hunger_before' => 7,
            'hunger_after' => 3,
            'satisfaction' => 8,
            'eating_reasons' => ['nutrition', 'energy'],
            'notes' => 'Delicious and filling',
            'metadata' => ['prep_time' => 10, 'source' => 'recipe_app']
        ];

        $response = $this->authenticatedPost('/api/v1/meals', $mealData);

        $response->assertStatus(201);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.meal.name', 'Oatmeal with Berries');
        $response->assertJsonPath('data.meal.calories', 350);
        $response->assertJsonPath('data.meal.meal_type', 'breakfast');
        $this->assertDatabaseHas('meals', [
            'user_id' => $this->user->id,
            'name' => 'Oatmeal with Berries',
            'calories' => 350
        ]);
    }

    public function test_can_list_meals(): void
    {
        Meal::factory()->count(3)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/meals');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonStructure(['data', 'pagination']);
        $this->assertCount(3, $response->json('data'));
    }

    public function test_can_list_meals_with_pagination(): void
    {
        Meal::factory()->count(5)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/meals?limit=2');

        $response->assertStatus(200);
        $response->assertJsonPath('pagination.per_page', 2);
        $this->assertCount(2, $response->json('data'));
    }

    public function test_can_filter_meals_by_date(): void
    {
        $today = now()->format('Y-m-d');
        $yesterday = now()->subDay()->format('Y-m-d');

        Meal::factory()->create([
            'user_id' => $this->user->id,
            'date' => $today,
            'is_template' => false
        ]);
        Meal::factory()->create([
            'user_id' => $this->user->id,
            'date' => $yesterday,
            'is_template' => false
        ]);

        $response = $this->authenticatedGet("/api/v1/meals?date={$today}");

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertStringStartsWith($today, $response->json('data.0.date'));
    }

    public function test_can_filter_meals_by_date_range(): void
    {
        $startDate = now()->subDays(2)->format('Y-m-d');
        $endDate = now()->format('Y-m-d');

        Meal::factory()->create(['user_id' => $this->user->id, 'date' => $startDate]);
        Meal::factory()->create(['user_id' => $this->user->id, 'date' => $endDate]);
        Meal::factory()->create(['user_id' => $this->user->id, 'date' => now()->addDay()->format('Y-m-d')]);

        $response = $this->authenticatedGet("/api/v1/meals?start_date={$startDate}&end_date={$endDate}");

        $response->assertStatus(200);
        $this->assertCount(2, $response->json('data'));
    }

    public function test_can_filter_meals_by_meal_type(): void
    {
        Meal::factory()->create(['user_id' => $this->user->id, 'meal_type' => 'breakfast']);
        Meal::factory()->create(['user_id' => $this->user->id, 'meal_type' => 'lunch']);
        Meal::factory()->create(['user_id' => $this->user->id, 'meal_type' => 'lunch']);

        $response = $this->authenticatedGet('/api/v1/meals?meal_type=lunch');

        $response->assertStatus(200);
        $this->assertCount(2, $response->json('data'));
        foreach ($response->json('data') as $meal) {
            $this->assertEquals('lunch', $meal['meal_type']);
        }
    }

    public function test_can_get_specific_meal(): void
    {
        $meal = Meal::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet("/api/v1/meals/{$meal->id}");

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.meal.id', $meal->id);
        $response->assertJsonPath('data.meal.name', $meal->name);
    }

    public function test_cannot_get_other_users_meal(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $meal = Meal::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedGet("/api/v1/meals/{$meal->id}");

        $response->assertStatus(404);
        $response->assertJsonPath('success', false);
    }

    public function test_can_update_meal(): void
    {
        $meal = Meal::factory()->create(['user_id' => $this->user->id, 'calories' => 300]);

        $updateData = [
            'calories' => 400,
            'protein_g' => 25.0,
            'notes' => 'Updated nutritional info'
        ];

        $response = $this->authenticatedPut("/api/v1/meals/{$meal->id}", $updateData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.meal.calories', 400);
        $response->assertJsonPath('data.meal.protein_g', 25.0);
        $response->assertJsonPath('data.meal.notes', 'Updated nutritional info');
        $this->assertDatabaseHas('meals', [
            'id' => $meal->id,
            'calories' => 400,
            'notes' => 'Updated nutritional info'
        ]);
    }

    public function test_partial_update_works(): void
    {
        $meal = Meal::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Original Name',
            'calories' => 300
        ]);

        $response = $this->authenticatedPut("/api/v1/meals/{$meal->id}", [
            'calories' => 400
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.meal.name', 'Original Name'); // Unchanged
        $response->assertJsonPath('data.meal.calories', 400); // Updated
    }

    public function test_cannot_update_other_users_meal(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $meal = Meal::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedPut("/api/v1/meals/{$meal->id}", [
            'calories' => 400
        ]);

        $response->assertStatus(404);
    }

    public function test_can_delete_meal(): void
    {
        $meal = Meal::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedDelete("/api/v1/meals/{$meal->id}");

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $this->assertDatabaseMissing('meals', ['id' => $meal->id]);
    }

    public function test_cannot_delete_other_users_meal(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $meal = Meal::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedDelete("/api/v1/meals/{$meal->id}");

        $response->assertStatus(404);
    }

    public function test_can_sync_meals(): void
    {
        $syncData = [
            'meals' => [
                [
                    'date' => now()->format('Y-m-d'),
                    'meal_type' => 'breakfast',
                    'name' => 'Synced Breakfast',
                    'calories' => 300,
                ],
                [
                    'date' => now()->format('Y-m-d'),
                    'meal_type' => 'lunch',
                    'name' => 'Synced Lunch',
                    'calories' => 500,
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/meals/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 2);
        $response->assertJsonPath('data.updated_count', 0);
        $response->assertJsonPath('data.errors', []);
        $this->assertDatabaseHas('meals', [
            'user_id' => $this->user->id,
            'name' => 'Synced Breakfast',
            'calories' => 300
        ]);
        $this->assertDatabaseHas('meals', [
            'user_id' => $this->user->id,
            'name' => 'Synced Lunch',
            'calories' => 500
        ]);
    }

    public function test_sync_updates_existing_meals(): void
    {
        // Create existing meal
        $existingMeal = Meal::factory()->create([
            'user_id' => $this->user->id,
            'date' => now()->format('Y-m-d'),
            'meal_type' => 'breakfast',
            'name' => 'Existing Breakfast',
            'calories' => 200
        ]);

        $syncData = [
            'meals' => [
                [
                    'date' => now()->format('Y-m-d'),
                    'meal_type' => 'breakfast',
                    'name' => 'Existing Breakfast',
                    'calories' => 350, // Updated calories
                    'protein_g' => 15.0
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/meals/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 0);
        $response->assertJsonPath('data.updated_count', 1);
        $existingMeal->refresh();
        $this->assertEquals(350, $existingMeal->calories);
        $this->assertEquals(15.0, $existingMeal->protein_g);
    }

    public function test_validation_errors_on_create(): void
    {
        $response = $this->authenticatedPost('/api/v1/meals', [
            'date' => 'invalid-date',
            'meal_type' => 'invalid-type',
            'name' => '',
            'calories' => 'not-a-number',
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
        $response->assertJsonStructure(['errors']);
        $this->assertArrayHasKey('date', $response->json('errors'));
        $this->assertArrayHasKey('meal_type', $response->json('errors'));
        $this->assertArrayHasKey('name', $response->json('errors'));
    }

    public function test_validation_errors_on_sync(): void
    {
        $response = $this->authenticatedPost('/api/v1/meals/sync', [
            'meals' => [
                [
                    'date' => 'invalid',
                    'meal_type' => 'invalid',
                    'name' => '',
                ]
            ]
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
        $response->assertJsonStructure(['errors']);
    }

    public function test_unauthorized_access_without_token(): void
    {
        $response = $this->getJson('/api/v1/meals');

        $response->assertStatus(401);
    }

    public function test_not_found_for_invalid_meal_id(): void
    {
        $response = $this->authenticatedGet('/api/v1/meals/99999');

        $response->assertStatus(404);
        $response->assertJsonPath('success', false);
    }

    public function test_meal_ordering_and_pagination(): void
    {
        $date = now()->format('Y-m-d');
        Meal::factory()->create([
            'user_id' => $this->user->id,
            'date' => $date,
            'meal_type' => 'lunch',
            'name' => 'Lunch Meal'
        ]);
        Meal::factory()->create([
            'user_id' => $this->user->id,
            'date' => $date,
            'meal_type' => 'breakfast',
            'name' => 'Breakfast Meal'
        ]);

        $response = $this->authenticatedGet('/api/v1/meals');

        $response->assertStatus(200);
        $data = $response->json('data');
        // Should be ordered by date desc, meal_type asc
        $this->assertEquals('Breakfast Meal', $data[0]['name']);
        $this->assertEquals('Lunch Meal', $data[1]['name']);
    }
}
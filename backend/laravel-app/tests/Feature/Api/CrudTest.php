<?php

namespace Tests\Feature\Api;

use App\Models\Meal;
use App\Models\Exercise;
use App\Models\Medication;
use App\Models\MealPlan;

class CrudTest extends ApiTestCase
{
    public function setUp(): void
    {
        parent::setUp();
        $this->authenticateUser();
    }

    // ========== MEALS TESTS ==========

    public function test_can_create_meal(): void
    {
        $response = $this->authenticatedPost('/api/v1/meals', [
            'date' => now()->format('Y-m-d'),
            'meal_type' => 'breakfast',
            'name' => 'Oatmeal',
            'calories' => 350,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.meal.name', 'Oatmeal');
    }

    public function test_can_list_meals(): void
    {
        Meal::factory()->count(3)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/meals');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonStructure(['data', 'pagination']);
    }

    public function test_can_update_meal(): void
    {
        $meal = Meal::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedPut("/api/v1/meals/{$meal->id}", [
            'calories' => 400,
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.meal.calories', 400);
    }

    public function test_can_delete_meal(): void
    {
        $meal = Meal::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedDelete("/api/v1/meals/{$meal->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('meals', ['id' => $meal->id]);
    }

    public function test_can_sync_meals(): void
    {
        $response = $this->authenticatedPost('/api/v1/meals/sync', [
            'meals' => [
                [
                    'date' => now()->format('Y-m-d'),
                    'meal_type' => 'breakfast',
                    'name' => 'Toast',
                ],
                [
                    'date' => now()->subDay()->format('Y-m-d'),
                    'meal_type' => 'lunch',
                    'name' => 'Salad',
                ],
            ],
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 2);
    }

    // ========== EXERCISES TESTS ==========

    public function test_can_create_exercise(): void
    {
        $response = $this->authenticatedPost('/api/v1/exercises', [
            'date' => now()->format('Y-m-d'),
            'type' => 'cardio',
            'name' => 'Running',
            'duration_minutes' => 30,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.exercise.name', 'Running');
    }

    public function test_can_create_exercise_template(): void
    {
        $response = $this->authenticatedPost('/api/v1/exercises', [
            'type' => 'strength',
            'name' => 'Bench Press',
            'is_template' => true,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('data.exercise.is_template', true);
    }

    public function test_can_list_exercises(): void
    {
        Exercise::factory()->count(3)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/exercises');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
    }

    public function test_can_filter_exercises_by_template(): void
    {
        Exercise::factory()->create(['user_id' => $this->user->id, 'is_template' => true]);
        Exercise::factory()->create(['user_id' => $this->user->id, 'is_template' => false]);

        $response = $this->authenticatedGet('/api/v1/exercises?is_template=true');

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
    }

    public function test_can_sync_exercises(): void
    {
        $response = $this->authenticatedPost('/api/v1/exercises/sync', [
            'exercises' => [
                [
                    'date' => now()->format('Y-m-d'),
                    'type' => 'cardio',
                    'name' => 'Running',
                ],
            ],
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 1);
    }

    // ========== MEDICATIONS TESTS ==========

    public function test_can_create_medication(): void
    {
        $response = $this->authenticatedPost('/api/v1/medications', [
            'name' => 'Aspirin',
            'dosage' => '500',
            'unit' => 'mg',
            'frequency' => 'Once daily',
            'start_date' => now()->format('Y-m-d'),
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('data.medication.name', 'Aspirin');
    }

    public function test_can_list_medications(): void
    {
        Medication::factory()->count(2)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/medications');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
    }

    public function test_can_filter_active_medications(): void
    {
        Medication::factory()->create(['user_id' => $this->user->id, 'active' => true]);
        Medication::factory()->create(['user_id' => $this->user->id, 'active' => false]);

        $response = $this->authenticatedGet('/api/v1/medications?active_only=true');

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
    }

    public function test_can_sync_medications(): void
    {
        $response = $this->authenticatedPost('/api/v1/medications/sync', [
            'medications' => [
                [
                    'name' => 'Vitamin C',
                    'dosage' => '1000',
                    'unit' => 'mg',
                    'frequency' => 'Daily',
                    'start_date' => now()->format('Y-m-d'),
                ],
            ],
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 1);
    }

    // ========== MEAL PLANS TESTS ==========

    public function test_can_create_meal_plan(): void
    {
        $response = $this->authenticatedPost('/api/v1/meal-plans', [
            'name' => 'Keto Diet',
            'start_date' => now()->format('Y-m-d'),
            'daily_calorie_target' => 2000,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('data.meal_plan.name', 'Keto Diet');
    }

    public function test_can_list_meal_plans(): void
    {
        MealPlan::factory()->count(2)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/meal-plans');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
    }

    public function test_only_one_meal_plan_can_be_active(): void
    {
        $plan1 = MealPlan::factory()->create(['user_id' => $this->user->id, 'active' => true]);

        // Create a second active plan
        $response = $this->authenticatedPost('/api/v1/meal-plans', [
            'name' => 'New Plan',
            'start_date' => now()->format('Y-m-d'),
            'active' => true,
        ]);

        $response->assertStatus(201);

        // First plan should no longer be active
        $plan1->refresh();
        $this->assertFalse($plan1->active);
    }

    public function test_can_sync_meal_plans(): void
    {
        $response = $this->authenticatedPost('/api/v1/meal-plans/sync', [
            'meal_plans' => [
                [
                    'name' => 'Balanced Diet',
                    'start_date' => now()->format('Y-m-d'),
                    'daily_calorie_target' => 2500,
                ],
            ],
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 1);
    }

    // ========== RESPONSE FORMAT TESTS ==========

    public function test_all_responses_have_standard_format(): void
    {
        $response = $this->authenticatedGet('/api/v1/meals');

        $response->assertJsonStructure([
            'success',
            'message',
            'data',
            'timestamp',
        ]);

        $this->assertTrue(is_bool($response->json('success')));
        $this->assertTrue(is_string($response->json('message')));
        $this->assertTrue(is_string($response->json('timestamp')));
    }

    public function test_validation_errors_have_correct_format(): void
    {
        $response = $this->authenticatedPost('/api/v1/meals', [
            'date' => 'invalid',
            'meal_type' => 'invalid',
        ]);

        $response->assertStatus(422);
        $response->assertJsonStructure([
            'success',
            'message',
            'errors',
            'timestamp',
        ]);
        $response->assertJsonPath('success', false);
    }
}

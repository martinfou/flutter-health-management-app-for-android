<?php

namespace Tests\Feature\Api;

use App\Models\Exercise;
use Carbon\Carbon;

class ExercisesTest extends ApiTestCase
{
    public function setUp(): void
    {
        parent::setUp();
        $this->authenticateUser();
    }

    public function test_can_create_exercise(): void
    {
        $exerciseData = [
            'type' => 'cardio',
            'name' => 'Morning Run',
            'date' => now()->format('Y-m-d'),
            'duration_minutes' => 30,
            'calories_burned' => 250,
            'intensity' => 'medium',
            'distance_km' => 5.0,
            'notes' => 'Great weather for running',
            'muscle_groups' => ['legs', 'cardio'],
            'equipment' => ['running shoes'],
            'metadata' => ['pace' => '6:00/min']
        ];

        $response = $this->authenticatedPost('/api/v1/exercises', $exerciseData);

        $response->assertStatus(201);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.exercise.name', 'Morning Run');
        $response->assertJsonPath('data.exercise.duration_minutes', 30);
        $response->assertJsonPath('data.exercise.is_template', false);
        $this->assertDatabaseHas('exercises', [
            'user_id' => $this->user->id,
            'name' => 'Morning Run',
            'type' => 'cardio'
        ]);
    }

    public function test_can_create_exercise_template(): void
    {
        $templateData = [
            'type' => 'strength',
            'name' => 'Bench Press',
            'description' => 'Standard bench press exercise',
            'sets' => 3,
            'reps' => 10,
            'weight_kg' => 80,
            'is_template' => true,
            'muscle_groups' => ['chest', 'triceps'],
            'equipment' => ['barbell', 'bench']
        ];

        $response = $this->authenticatedPost('/api/v1/exercises', $templateData);

        $response->assertStatus(201);
        $response->assertJsonPath('data.exercise.is_template', true);
        $response->assertJsonPath('data.exercise.sets', 3);
        $this->assertDatabaseHas('exercises', [
            'user_id' => $this->user->id,
            'name' => 'Bench Press',
            'is_template' => true
        ]);
    }

    public function test_date_required_for_non_template_exercises(): void
    {
        $response = $this->authenticatedPost('/api/v1/exercises', [
            'type' => 'cardio',
            'name' => 'Running',
            'is_template' => false
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
        $this->assertArrayHasKey('date', $response->json('errors'));
    }

    public function test_date_optional_for_template_exercises(): void
    {
        $response = $this->authenticatedPost('/api/v1/exercises', [
            'type' => 'strength',
            'name' => 'Push-ups',
            'is_template' => true
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
        $response->assertJsonStructure(['data', 'pagination']);
        $this->assertCount(3, $response->json('data'));
    }

    public function test_can_filter_exercises_by_template(): void
    {
        Exercise::factory()->create([
            'user_id' => $this->user->id,
            'is_template' => true,
            'name' => 'Template Exercise'
        ]);
        Exercise::factory()->create([
            'user_id' => $this->user->id,
            'is_template' => false,
            'name' => 'Regular Exercise'
        ]);

        $response = $this->authenticatedGet('/api/v1/exercises?is_template=true');

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Template Exercise', $response->json('data.0.name'));
    }

    public function test_can_filter_exercises_by_type(): void
    {
        Exercise::factory()->create([
            'user_id' => $this->user->id,
            'type' => 'cardio',
            'name' => 'Cardio Exercise'
        ]);
        Exercise::factory()->create([
            'user_id' => $this->user->id,
            'type' => 'strength',
            'name' => 'Strength Exercise'
        ]);

        $response = $this->authenticatedGet('/api/v1/exercises?type=cardio');

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Cardio Exercise', $response->json('data.0.name'));
    }

    public function test_can_filter_exercises_by_date(): void
    {
        $today = now()->format('Y-m-d');
        $yesterday = now()->subDay()->format('Y-m-d');

        Exercise::factory()->create([
            'user_id' => $this->user->id,
            'date' => $today,
            'is_template' => false
        ]);
        Exercise::factory()->create([
            'user_id' => $this->user->id,
            'date' => $yesterday,
            'is_template' => false
        ]);

        $response = $this->authenticatedGet("/api/v1/exercises?date={$today}");

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals($today, $response->json('data.0.date'));
    }

    public function test_date_filter_ignored_for_templates(): void
    {
        $today = now()->format('Y-m-d');

        Exercise::factory()->create([
            'user_id' => $this->user->id,
            'date' => $today,
            'is_template' => true
        ]);

        $response = $this->authenticatedGet("/api/v1/exercises?date={$today}&is_template=true");

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
    }

    public function test_can_get_specific_exercise(): void
    {
        $exercise = Exercise::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet("/api/v1/exercises/{$exercise->id}");

        $response->assertStatus(200);
        $response->assertJsonPath('data.exercise.id', $exercise->id);
        $response->assertJsonPath('data.exercise.name', $exercise->name);
    }

    public function test_cannot_get_other_users_exercise(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $exercise = Exercise::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedGet("/api/v1/exercises/{$exercise->id}");

        $response->assertStatus(404);
    }

    public function test_can_update_exercise(): void
    {
        $exercise = Exercise::factory()->create([
            'user_id' => $this->user->id,
            'duration_minutes' => 20
        ]);

        $updateData = [
            'duration_minutes' => 45,
            'calories_burned' => 300,
            'notes' => 'Updated workout notes'
        ];

        $response = $this->authenticatedPut("/api/v1/exercises/{$exercise->id}", $updateData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.exercise.duration_minutes', 45);
        $response->assertJsonPath('data.exercise.calories_burned', 300);
        $this->assertDatabaseHas('exercises', [
            'id' => $exercise->id,
            'duration_minutes' => 45,
            'notes' => 'Updated workout notes'
        ]);
    }

    public function test_can_update_exercise_template(): void
    {
        $exercise = Exercise::factory()->create([
            'user_id' => $this->user->id,
            'is_template' => true,
            'sets' => 3
        ]);

        $response = $this->authenticatedPut("/api/v1/exercises/{$exercise->id}", [
            'sets' => 4,
            'reps' => 12
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.exercise.sets', 4);
        $response->assertJsonPath('data.exercise.reps', 12);
    }

    public function test_cannot_update_other_users_exercise(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $exercise = Exercise::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedPut("/api/v1/exercises/{$exercise->id}", [
            'duration_minutes' => 45
        ]);

        $response->assertStatus(404);
    }

    public function test_can_delete_exercise(): void
    {
        $exercise = Exercise::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedDelete("/api/v1/exercises/{$exercise->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('exercises', ['id' => $exercise->id]);
    }

    public function test_cannot_delete_other_users_exercise(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $exercise = Exercise::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedDelete("/api/v1/exercises/{$exercise->id}");

        $response->assertStatus(404);
    }

    public function test_can_sync_exercises(): void
    {
        $syncData = [
            'exercises' => [
                [
                    'type' => 'cardio',
                    'name' => 'Running',
                    'date' => now()->format('Y-m-d'),
                    'duration_minutes' => 30,
                ],
                [
                    'type' => 'strength',
                    'name' => 'Push-ups',
                    'is_template' => true,
                    'sets' => 3,
                    'reps' => 15,
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/exercises/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 2);
        $response->assertJsonPath('data.updated_count', 0);
        $this->assertDatabaseHas('exercises', [
            'user_id' => $this->user->id,
            'name' => 'Running',
            'type' => 'cardio'
        ]);
        $this->assertDatabaseHas('exercises', [
            'user_id' => $this->user->id,
            'name' => 'Push-ups',
            'is_template' => true
        ]);
    }

    public function test_sync_updates_existing_exercises(): void
    {
        // Create existing exercise
        $existingExercise = Exercise::factory()->create([
            'user_id' => $this->user->id,
            'type' => 'cardio',
            'name' => 'Running',
            'date' => now()->format('Y-m-d'),
            'duration_minutes' => 20
        ]);

        $syncData = [
            'exercises' => [
                [
                    'type' => 'cardio',
                    'name' => 'Running',
                    'date' => now()->format('Y-m-d'),
                    'duration_minutes' => 45, // Updated duration
                    'calories_burned' => 300
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/exercises/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 0);
        $response->assertJsonPath('data.updated_count', 1);
        $existingExercise->refresh();
        $this->assertEquals(45, $existingExercise->duration_minutes);
        $this->assertEquals(300, $existingExercise->calories_burned);
    }

    public function test_sync_updates_existing_templates(): void
    {
        // Create existing template
        $existingTemplate = Exercise::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Bench Press',
            'is_template' => true,
            'sets' => 3
        ]);

        $syncData = [
            'exercises' => [
                [
                    'type' => 'strength',
                    'name' => 'Bench Press',
                    'is_template' => true,
                    'sets' => 4, // Updated sets
                    'weight_kg' => 85
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/exercises/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 0);
        $response->assertJsonPath('data.updated_count', 1);
        $existingTemplate->refresh();
        $this->assertEquals(4, $existingTemplate->sets);
        $this->assertEquals(85, $existingTemplate->weight_kg);
    }

    public function test_validation_errors_on_create(): void
    {
        $response = $this->authenticatedPost('/api/v1/exercises', [
            'type' => 'invalid',
            'name' => '',
            'date' => 'invalid-date',
            'duration_minutes' => -5,
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
        $this->assertArrayHasKey('type', $response->json('errors'));
        $this->assertArrayHasKey('name', $response->json('errors'));
    }

    public function test_validation_errors_on_sync(): void
    {
        $response = $this->authenticatedPost('/api/v1/exercises/sync', [
            'exercises' => [
                [
                    'type' => 'invalid',
                    'name' => '',
                ]
            ]
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
    }

    public function test_unauthorized_access_without_token(): void
    {
        $response = $this->getJson('/api/v1/exercises');

        $response->assertStatus(401);
    }

    public function test_not_found_for_invalid_exercise_id(): void
    {
        $response = $this->authenticatedGet('/api/v1/exercises/99999');

        $response->assertStatus(404);
    }

    public function test_invalid_type_filter_ignored(): void
    {
        Exercise::factory()->count(2)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/exercises?type=invalid');

        $response->assertStatus(200);
        $this->assertCount(2, $response->json('data')); // Invalid type ignored, returns all
    }

    public function test_exercises_ordered_by_date_desc(): void
    {
        $today = now()->format('Y-m-d');
        $yesterday = now()->subDay()->format('Y-m-d');

        $exercise1 = Exercise::factory()->create([
            'user_id' => $this->user->id,
            'date' => $yesterday,
            'is_template' => false
        ]);
        $exercise2 = Exercise::factory()->create([
            'user_id' => $this->user->id,
            'date' => $today,
            'is_template' => false
        ]);

        $response = $this->authenticatedGet('/api/v1/exercises');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertEquals($exercise2->id, $data[0]['id']); // Today first
        $this->assertEquals($exercise1->id, $data[1]['id']); // Yesterday second
    }
}
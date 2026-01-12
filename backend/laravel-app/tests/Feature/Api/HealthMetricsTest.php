<?php

namespace Tests\Feature\Api;

use App\Models\HealthMetric;
use Illuminate\Support\Carbon;

class HealthMetricsTest extends ApiTestCase
{
    public function setUp(): void
    {
        parent::setUp();
        $this->authenticateUser();
    }

    /**
     * Test can list health metrics
     */
    public function test_can_list_health_metrics(): void
    {
        HealthMetric::factory()->count(3)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/health-metrics');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonStructure([
            'data',
            'pagination' => ['page', 'per_page', 'total', 'total_pages'],
        ]);
    }

    /**
     * Test can create health metric
     */
    public function test_can_create_health_metric(): void
    {
        $response = $this->authenticatedPost('/api/v1/health-metrics', [
            'date' => now()->format('Y-m-d'),
            'weight_kg' => 75.5,
            'sleep_hours' => 8,
            'mood' => 'good',
            'notes' => 'Feeling great',
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.health_metric.weight_kg', 75.5);
    }

    /**
     * Test cannot create duplicate date metric
     */
    public function test_cannot_create_duplicate_date_metric(): void
    {
        $date = now()->format('Y-m-d');
        HealthMetric::factory()->create([
            'user_id' => $this->user->id,
            'date' => $date,
        ]);

        $response = $this->authenticatedPost('/api/v1/health-metrics', [
            'date' => $date,
            'weight_kg' => 75,
        ]);

        $response->assertStatus(409);
        $response->assertJsonPath('success', false);
    }

    /**
     * Test can get single health metric
     */
    public function test_can_get_single_health_metric(): void
    {
        $metric = HealthMetric::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet("/api/v1/health-metrics/{$metric->id}");

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.health_metric.id', $metric->id);
    }

    /**
     * Test cannot get other user's metric
     */
    public function test_cannot_get_other_users_metric(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $metric = HealthMetric::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedGet("/api/v1/health-metrics/{$metric->id}");

        $response->assertStatus(404);
    }

    /**
     * Test can update health metric
     */
    public function test_can_update_health_metric(): void
    {
        $metric = HealthMetric::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedPut("/api/v1/health-metrics/{$metric->id}", [
            'weight_kg' => 80,
            'mood' => 'excellent',
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.health_metric.weight_kg', 80);
        $response->assertJsonPath('data.health_metric.mood', 'excellent');
    }

    /**
     * Test can delete health metric
     */
    public function test_can_delete_health_metric(): void
    {
        $metric = HealthMetric::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedDelete("/api/v1/health-metrics/{$metric->id}");

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $this->assertDatabaseMissing('health_metrics', ['id' => $metric->id]);
    }

    /**
     * Test can sync health metrics
     */
    public function test_can_sync_health_metrics(): void
    {
        $response = $this->authenticatedPost('/api/v1/health-metrics/sync', [
            'metrics' => [
                [
                    'date' => now()->format('Y-m-d'),
                    'weight_kg' => 75,
                    'sleep_hours' => 8,
                ],
                [
                    'date' => now()->subDay()->format('Y-m-d'),
                    'weight_kg' => 76,
                    'sleep_hours' => 7,
                ],
            ],
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.synced_count', 2);
    }

    /**
     * Test validation errors on create
     */
    public function test_validation_errors_on_create(): void
    {
        $response = $this->authenticatedPost('/api/v1/health-metrics', [
            'date' => 'invalid-date',
            'weight_kg' => 'not-a-number',
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
        $response->assertJsonStructure(['errors']);
    }

    /**
     * Test filtering by date range
     */
    public function test_can_filter_by_date_range(): void
    {
        HealthMetric::factory()->create([
            'user_id' => $this->user->id,
            'date' => now()->format('Y-m-d'),
        ]);
        HealthMetric::factory()->create([
            'user_id' => $this->user->id,
            'date' => now()->subDays(10)->format('Y-m-d'),
        ]);

        $response = $this->authenticatedGet('/api/v1/health-metrics', [
            'start_date' => now()->subDays(5)->format('Y-m-d'),
            'end_date' => now()->format('Y-m-d'),
        ]);

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
    }
}

<?php

namespace Tests\Feature\Api;

use App\Models\Medication;

class MedicationsTest extends ApiTestCase
{
    public function setUp(): void
    {
        parent::setUp();
        $this->authenticateUser();
    }

    public function test_can_create_medication(): void
    {
        $medicationData = [
            'name' => 'Lisinopril',
            'dosage' => '10',
            'unit' => 'mg',
            'frequency' => 'Once daily',
            'start_date' => now()->format('Y-m-d'),
            'end_date' => now()->addMonths(6)->format('Y-m-d'),
            'prescribing_doctor' => 'Dr. Smith',
            'notes' => 'For blood pressure',
            'active' => true,
            'reminder_times' => ['09:00'],
            'side_effects' => ['dry cough'],
            'metadata' => ['prescription_id' => 'RX123']
        ];

        $response = $this->authenticatedPost('/api/v1/medications', $medicationData);

        $response->assertStatus(201);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.medication.name', 'Lisinopril');
        $response->assertJsonPath('data.medication.dosage', '10');
        $response->assertJsonPath('data.medication.active', true);
        $this->assertDatabaseHas('medications', [
            'user_id' => $this->user->id,
            'name' => 'Lisinopril',
            'dosage' => '10'
        ]);
    }

    public function test_can_list_medications(): void
    {
        Medication::factory()->count(3)->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet('/api/v1/medications');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonStructure(['data', 'pagination']);
        $this->assertCount(3, $response->json('data'));
    }

    public function test_can_filter_active_medications(): void
    {
        Medication::factory()->create([
            'user_id' => $this->user->id,
            'active' => true,
            'name' => 'Active Med'
        ]);
        Medication::factory()->create([
            'user_id' => $this->user->id,
            'active' => false,
            'name' => 'Inactive Med'
        ]);

        $response = $this->authenticatedGet('/api/v1/medications?active_only=true');

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Active Med', $response->json('data.0.name'));
    }

    public function test_can_get_specific_medication(): void
    {
        $medication = Medication::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedGet("/api/v1/medications/{$medication->id}");

        $response->assertStatus(200);
        $response->assertJsonPath('data.medication.id', $medication->id);
        $response->assertJsonPath('data.medication.name', $medication->name);
    }

    public function test_cannot_get_other_users_medication(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $medication = Medication::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedGet("/api/v1/medications/{$medication->id}");

        $response->assertStatus(404);
    }

    public function test_can_update_medication(): void
    {
        $medication = Medication::factory()->create([
            'user_id' => $this->user->id,
            'dosage' => '5mg'
        ]);

        $updateData = [
            'dosage' => '10mg',
            'frequency' => 'Twice daily',
            'notes' => 'Updated dosage'
        ];

        $response = $this->authenticatedPut("/api/v1/medications/{$medication->id}", $updateData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.medication.dosage', '10mg');
        $response->assertJsonPath('data.medication.frequency', 'Twice daily');
        $this->assertDatabaseHas('medications', [
            'id' => $medication->id,
            'dosage' => '10mg',
            'notes' => 'Updated dosage'
        ]);
    }

    public function test_can_deactivate_medication(): void
    {
        $medication = Medication::factory()->create([
            'user_id' => $this->user->id,
            'active' => true
        ]);

        $response = $this->authenticatedPut("/api/v1/medications/{$medication->id}", [
            'active' => false
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.medication.active', false);
        $this->assertDatabaseHas('medications', [
            'id' => $medication->id,
            'active' => false
        ]);
    }

    public function test_cannot_update_other_users_medication(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $medication = Medication::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedPut("/api/v1/medications/{$medication->id}", [
            'dosage' => '20mg'
        ]);

        $response->assertStatus(404);
    }

    public function test_can_delete_medication(): void
    {
        $medication = Medication::factory()->create(['user_id' => $this->user->id]);

        $response = $this->authenticatedDelete("/api/v1/medications/{$medication->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('medications', ['id' => $medication->id]);
    }

    public function test_cannot_delete_other_users_medication(): void
    {
        $otherUser = \App\Models\User::factory()->create();
        $medication = Medication::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->authenticatedDelete("/api/v1/medications/{$medication->id}");

        $response->assertStatus(404);
    }

    public function test_can_sync_medications(): void
    {
        $syncData = [
            'medications' => [
                [
                    'name' => 'Aspirin',
                    'dosage' => '81',
                    'unit' => 'mg',
                    'frequency' => 'Once daily',
                    'start_date' => now()->format('Y-m-d'),
                ],
                [
                    'name' => 'Vitamin D',
                    'dosage' => '1000',
                    'unit' => 'IU',
                    'frequency' => 'Daily',
                    'start_date' => now()->format('Y-m-d'),
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/medications/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 2);
        $response->assertJsonPath('data.updated_count', 0);
        $this->assertDatabaseHas('medications', [
            'user_id' => $this->user->id,
            'name' => 'Aspirin'
        ]);
        $this->assertDatabaseHas('medications', [
            'user_id' => $this->user->id,
            'name' => 'Vitamin D'
        ]);
    }

    public function test_sync_updates_existing_medications(): void
    {
        // Create existing medication
        $existingMed = Medication::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Ibuprofen',
            'dosage' => '200mg'
        ]);

        $syncData = [
            'medications' => [
                [
                    'name' => 'Ibuprofen',
                    'dosage' => '400mg', // Updated dosage
                    'frequency' => 'As needed',
                ]
            ]
        ];

        $response = $this->authenticatedPost('/api/v1/medications/sync', $syncData);

        $response->assertStatus(200);
        $response->assertJsonPath('data.synced_count', 0);
        $response->assertJsonPath('data.updated_count', 1);
        $existingMed->refresh();
        $this->assertEquals('400mg', $existingMed->dosage);
        $this->assertEquals('As needed', $existingMed->frequency);
    }

    public function test_validation_errors_on_create(): void
    {
        $response = $this->authenticatedPost('/api/v1/medications', [
            'name' => '',
            'dosage' => '',
            'unit' => '',
            'frequency' => '',
            'start_date' => 'invalid-date',
            'end_date' => now()->subDay()->format('Y-m-d'), // Before start date
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
        $this->assertArrayHasKey('name', $response->json('errors'));
        $this->assertArrayHasKey('dosage', $response->json('errors'));
        $this->assertArrayHasKey('start_date', $response->json('errors'));
    }

    public function test_end_date_must_be_after_start_date(): void
    {
        $response = $this->authenticatedPost('/api/v1/medications', [
            'name' => 'Test Med',
            'dosage' => '10',
            'unit' => 'mg',
            'frequency' => 'Daily',
            'start_date' => now()->format('Y-m-d'),
            'end_date' => now()->subDay()->format('Y-m-d'),
        ]);

        $response->assertStatus(422);
        $this->assertArrayHasKey('end_date', $response->json('errors'));
    }

    public function test_validation_errors_on_sync(): void
    {
        $response = $this->authenticatedPost('/api/v1/medications/sync', [
            'medications' => [
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
        $response = $this->getJson('/api/v1/medications');

        $response->assertStatus(401);
    }

    public function test_not_found_for_invalid_medication_id(): void
    {
        $response = $this->authenticatedGet('/api/v1/medications/99999');

        $response->assertStatus(404);
    }

    public function test_medications_ordered_by_created_at_desc(): void
    {
        $med1 = Medication::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'First Med'
        ]);
        $med2 = Medication::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Second Med'
        ]);

        $response = $this->authenticatedGet('/api/v1/medications');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertEquals('Second Med', $data[0]['name']); // Most recent first
        $this->assertEquals('First Med', $data[1]['name']);
    }

    public function test_default_active_state_is_true(): void
    {
        $response = $this->authenticatedPost('/api/v1/medications', [
            'name' => 'Test Med',
            'dosage' => '10',
            'unit' => 'mg',
            'frequency' => 'Daily',
            'start_date' => now()->format('Y-m-d'),
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('data.medication.active', true);
        $this->assertDatabaseHas('medications', [
            'user_id' => $this->user->id,
            'name' => 'Test Med',
            'active' => true
        ]);
    }

    public function test_active_only_parameter_various_formats(): void
    {
        Medication::factory()->create([
            'user_id' => $this->user->id,
            'active' => true
        ]);
        Medication::factory()->create([
            'user_id' => $this->user->id,
            'active' => false
        ]);

        // Test 'true' string
        $response = $this->authenticatedGet('/api/v1/medications?active_only=true');
        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));

        // Test '1' string
        $response = $this->authenticatedGet('/api/v1/medications?active_only=1');
        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
    }
}
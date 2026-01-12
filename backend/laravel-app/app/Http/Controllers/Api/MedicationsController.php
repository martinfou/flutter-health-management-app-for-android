<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseHelper;
use App\Models\Medication;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MedicationsController extends Controller
{
    /**
     * Get all medications for the authenticated user
     * GET /api/v1/medications
     */
    public function index(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            // Parse query parameters
            $activeOnly = $request->input('active_only', false);
            $limit = (int) $request->input('limit', 20);
            $limit = min($limit, 100); // Cap at 100

            // Build query
            $query = Medication::where('user_id', $user->id);

            if ($activeOnly === 'true' || $activeOnly === '1' || $activeOnly === true) {
                $query->where('active', true);
            }

            // Order and paginate
            $medications = $query->orderBy('created_at', 'desc')
                ->paginate($limit);

            return ResponseHelper::paginated($medications, 'Medications retrieved successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve medications: ' . $e->getMessage());
        }
    }

    /**
     * Get a specific medication by ID
     * GET /api/v1/medications/{id}
     */
    public function show(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            $medication = Medication::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$medication) {
                return ResponseHelper::notFound('Medication not found');
            }

            return ResponseHelper::success(
                ['medication' => $medication],
                'Medication retrieved successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve medication: ' . $e->getMessage());
        }
    }

    /**
     * Create a new medication
     * POST /api/v1/medications
     */
    public function store(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            // Validate input
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'dosage' => 'required|string|max:100',
                'unit' => 'required|string|max:50',
                'frequency' => 'required|string|max:100',
                'start_date' => 'required|date',
                'end_date' => 'nullable|date|after_or_equal:start_date',
                'prescribing_doctor' => 'nullable|string|max:255',
                'notes' => 'nullable|string|max:1000',
                'active' => 'nullable|boolean',
                'reminder_times' => 'nullable|array',
                'side_effects' => 'nullable|array',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            // Create medication
            $medication = Medication::create([
                'user_id' => $user->id,
                'name' => $request->input('name'),
                'dosage' => $request->input('dosage'),
                'unit' => $request->input('unit'),
                'frequency' => $request->input('frequency'),
                'start_date' => $request->input('start_date'),
                'end_date' => $request->input('end_date'),
                'prescribing_doctor' => $request->input('prescribing_doctor'),
                'notes' => $request->input('notes'),
                'active' => (bool) $request->input('active', true),
                'reminder_times' => $request->input('reminder_times', []),
                'side_effects' => $request->input('side_effects', []),
                'metadata' => $request->input('metadata', []),
            ]);

            return ResponseHelper::success(
                ['medication' => $medication],
                'Medication created successfully',
                201
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to create medication: ' . $e->getMessage());
        }
    }

    /**
     * Update an existing medication
     * PUT /api/v1/medications/{id}
     */
    public function update(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            // Check if medication exists and belongs to user
            $medication = Medication::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$medication) {
                return ResponseHelper::notFound('Medication not found');
            }

            // Validate input (all optional for partial updates)
            $validator = Validator::make($request->all(), [
                'name' => 'nullable|string|max:255',
                'dosage' => 'nullable|string|max:100',
                'unit' => 'nullable|string|max:50',
                'frequency' => 'nullable|string|max:100',
                'start_date' => 'nullable|date',
                'end_date' => 'nullable|date|after_or_equal:start_date',
                'prescribing_doctor' => 'nullable|string|max:255',
                'notes' => 'nullable|string|max:1000',
                'active' => 'nullable|boolean',
                'reminder_times' => 'nullable|array',
                'side_effects' => 'nullable|array',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            // Update only provided fields
            $updateData = $request->only([
                'name', 'dosage', 'unit', 'frequency', 'start_date', 'end_date',
                'prescribing_doctor', 'notes', 'active', 'reminder_times',
                'side_effects', 'metadata'
            ]);

            $medication->update($updateData);

            return ResponseHelper::success(
                ['medication' => $medication],
                'Medication updated successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to update medication: ' . $e->getMessage());
        }
    }

    /**
     * Delete a medication
     * DELETE /api/v1/medications/{id}
     */
    public function destroy(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            // Check if medication exists and belongs to user
            $medication = Medication::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$medication) {
                return ResponseHelper::notFound('Medication not found');
            }

            $medication->delete();

            return ResponseHelper::success([], 'Medication deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to delete medication: ' . $e->getMessage());
        }
    }

    /**
     * Sync medications (bulk upload for offline support)
     * POST /api/v1/medications/sync
     */
    public function sync(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            $validator = Validator::make($request->all(), [
                'medications' => 'required|array',
                'medications.*.name' => 'required|string|max:255',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            $medications = $request->input('medications', []);
            $synced = 0;
            $updated = 0;
            $errors = [];

            foreach ($medications as $index => $medicationData) {
                try {
                    // Match by user_id + name
                    $existing = Medication::where('user_id', $user->id)
                        ->where('name', $medicationData['name'])
                        ->first();

                    if ($existing) {
                        // Update existing
                        $updateData = array_filter($medicationData, function ($key) {
                            return $key !== 'name';
                        }, ARRAY_FILTER_USE_KEY);

                        $existing->update($updateData);
                        $updated++;
                    } else {
                        // Create new
                        Medication::create([
                            'user_id' => $user->id,
                            'name' => $medicationData['name'] ?? null,
                            'dosage' => $medicationData['dosage'] ?? null,
                            'unit' => $medicationData['unit'] ?? null,
                            'frequency' => $medicationData['frequency'] ?? null,
                            'start_date' => $medicationData['start_date'] ?? null,
                            'end_date' => $medicationData['end_date'] ?? null,
                            'prescribing_doctor' => $medicationData['prescribing_doctor'] ?? null,
                            'notes' => $medicationData['notes'] ?? null,
                            'active' => (bool) ($medicationData['active'] ?? true),
                            'reminder_times' => $medicationData['reminder_times'] ?? [],
                            'side_effects' => $medicationData['side_effects'] ?? [],
                            'metadata' => $medicationData['metadata'] ?? [],
                        ]);
                        $synced++;
                    }
                } catch (\Exception $e) {
                    $errors[] = "Medication $index: " . $e->getMessage();
                }
            }

            return ResponseHelper::success(
                [
                    'synced_count' => $synced,
                    'updated_count' => $updated,
                    'errors' => $errors,
                ],
                'Medications sync completed'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Sync failed: ' . $e->getMessage());
        }
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseHelper;
use App\Models\Meal;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MealsController extends Controller
{
    /**
     * Get all meals for the authenticated user
     * GET /api/v1/meals
     */
    public function index(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            // Parse query parameters
            $date = $request->input('date');
            $startDate = $request->input('start_date');
            $endDate = $request->input('end_date');
            $mealType = $request->input('meal_type');
            $limit = (int) $request->input('limit', 20);
            $limit = min($limit, 100); // Cap at 100

            // Build query
            $query = Meal::where('user_id', $user->id);

            if ($date) {
                $query->whereDate('date', $date);
            } elseif ($startDate && $endDate) {
                $query->whereBetween('date', [$startDate, $endDate]);
            }

            if ($mealType) {
                $validTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
                if (in_array($mealType, $validTypes)) {
                    $query->where('meal_type', $mealType);
                }
            }

            // Order and paginate
            $meals = $query->orderBy('date', 'desc')
                ->orderBy('meal_type', 'asc')
                ->orderBy('created_at', 'desc')
                ->paginate($limit);

            return ResponseHelper::paginated($meals, 'Meals retrieved successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve meals: ' . $e->getMessage());
        }
    }

    /**
     * Get a specific meal by ID
     * GET /api/v1/meals/{id}
     */
    public function show(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            $meal = Meal::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$meal) {
                return ResponseHelper::notFound('Meal not found');
            }

            return ResponseHelper::success(
                ['meal' => $meal],
                'Meal retrieved successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve meal: ' . $e->getMessage());
        }
    }

    /**
     * Create a new meal
     * POST /api/v1/meals
     */
    public function store(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            // Validate input
            $validator = Validator::make($request->all(), [
                'date' => 'required|date',
                'meal_type' => 'required|in:breakfast,lunch,dinner,snack',
                'name' => 'required|string|max:255',
                'description' => 'nullable|string|max:1000',
                'ingredients' => 'nullable|array',
                'nutritional_info' => 'nullable|array',
                'calories' => 'nullable|numeric|between:0,10000',
                'protein_g' => 'nullable|numeric|between:0,1000',
                'fats_g' => 'nullable|numeric|between:0,1000',
                'carbs_g' => 'nullable|numeric|between:0,1000',
                'fiber_g' => 'nullable|numeric|between:0,500',
                'sugar_g' => 'nullable|numeric|between:0,1000',
                'sodium_mg' => 'nullable|numeric|between:0,50000',
                'hunger_before' => 'nullable|integer|between:1,10',
                'hunger_after' => 'nullable|integer|between:1,10',
                'satisfaction' => 'nullable|integer|between:1,10',
                'eating_reasons' => 'nullable|array',
                'notes' => 'nullable|string|max:1000',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            // Create meal
            $meal = Meal::create([
                'user_id' => $user->id,
                'date' => $request->input('date'),
                'meal_type' => $request->input('meal_type'),
                'name' => $request->input('name'),
                'description' => $request->input('description'),
                'ingredients' => $request->input('ingredients', []),
                'nutritional_info' => $request->input('nutritional_info', []),
                'calories' => $request->input('calories'),
                'protein_g' => $request->input('protein_g'),
                'fats_g' => $request->input('fats_g'),
                'carbs_g' => $request->input('carbs_g'),
                'fiber_g' => $request->input('fiber_g'),
                'sugar_g' => $request->input('sugar_g'),
                'sodium_mg' => $request->input('sodium_mg'),
                'hunger_before' => $request->input('hunger_before'),
                'hunger_after' => $request->input('hunger_after'),
                'satisfaction' => $request->input('satisfaction'),
                'eating_reasons' => $request->input('eating_reasons', []),
                'notes' => $request->input('notes'),
                'metadata' => $request->input('metadata', []),
            ]);

            return ResponseHelper::success(
                ['meal' => $meal],
                'Meal created successfully',
                201
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to create meal: ' . $e->getMessage());
        }
    }

    /**
     * Update an existing meal
     * PUT /api/v1/meals/{id}
     */
    public function update(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            // Check if meal exists and belongs to user
            $meal = Meal::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$meal) {
                return ResponseHelper::notFound('Meal not found');
            }

            // Validate input (all optional for partial updates)
            $validator = Validator::make($request->all(), [
                'date' => 'nullable|date',
                'meal_type' => 'nullable|in:breakfast,lunch,dinner,snack',
                'name' => 'nullable|string|max:255',
                'description' => 'nullable|string|max:1000',
                'ingredients' => 'nullable|array',
                'nutritional_info' => 'nullable|array',
                'calories' => 'nullable|numeric|between:0,10000',
                'protein_g' => 'nullable|numeric|between:0,1000',
                'fats_g' => 'nullable|numeric|between:0,1000',
                'carbs_g' => 'nullable|numeric|between:0,1000',
                'fiber_g' => 'nullable|numeric|between:0,500',
                'sugar_g' => 'nullable|numeric|between:0,1000',
                'sodium_mg' => 'nullable|numeric|between:0,50000',
                'hunger_before' => 'nullable|integer|between:1,10',
                'hunger_after' => 'nullable|integer|between:1,10',
                'satisfaction' => 'nullable|integer|between:1,10',
                'eating_reasons' => 'nullable|array',
                'notes' => 'nullable|string|max:1000',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            // Update only provided fields
            $updateData = $request->only([
                'date',
                'meal_type',
                'name',
                'description',
                'ingredients',
                'nutritional_info',
                'calories',
                'protein_g',
                'fats_g',
                'carbs_g',
                'fiber_g',
                'sugar_g',
                'sodium_mg',
                'hunger_before',
                'hunger_after',
                'satisfaction',
                'eating_reasons',
                'notes',
                'metadata'
            ]);

            $meal->update($updateData);

            return ResponseHelper::success(
                ['meal' => $meal],
                'Meal updated successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to update meal: ' . $e->getMessage());
        }
    }

    /**
     * Delete a meal
     * DELETE /api/v1/meals/{id}
     */
    public function destroy(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            // Check if meal exists and belongs to user
            $meal = Meal::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$meal) {
                return ResponseHelper::notFound('Meal not found');
            }

            $meal->delete();

            return ResponseHelper::success([], 'Meal deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to delete meal: ' . $e->getMessage());
        }
    }

    /**
     * Sync meals (bulk upload for offline support)
     * POST /api/v1/meals/sync
     */
    /**
     * Sync meals (bidirectional delta sync)
     * POST /api/v1/meals/sync
     */
    public function sync(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            $validator = Validator::make($request->all(), [
                'channels' => 'nullable|array', // Optional: list of channel IDs to sync specific data? No, keep simple
                'changes' => 'nullable|array', // List of changed records from client
                'last_sync_timestamp' => 'nullable|date', // Last time client synced
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            $lastSync = $request->input('last_sync_timestamp');
            $changes = $request->input('changes', []);
            $syncedCount = 0;
            $updatedCount = 0;
            $deletedCount = 0;
            $errors = [];

            // 1. Process client changes
            foreach ($changes as $index => $change) {
                try {
                    // Check required fields for sync
                    if (!isset($change['client_id'])) {
                        $errors[] = "Item $index: Missing client_id";
                        continue;
                    }

                    // Try to find existing record by client_id (reliable) or id (fallback)
                    $query = Meal::withTrashed()->where('user_id', $user->id);

                    if (isset($change['client_id'])) {
                        $query->where('client_id', $change['client_id']);
                    } else if (isset($change['id'])) {
                        $query->where('id', $change['id']);
                    }

                    $existing = $query->first();

                    // DETERMINE ACTION:
                    // If deleted_at is set in payload -> DELETE
                    if (isset($change['deleted_at']) && $change['deleted_at']) {
                        if ($existing) {
                            if (!$existing->trashed() || $existing->deleted_at != $change['deleted_at']) {
                                // Only update if not already deleted or timestamp differs
                                // Conflict Resolution: Newest wins
                                $clientUpdate = strtotime($change['updated_at'] ?? now());
                                $serverUpdate = $existing->updated_at ? $existing->updated_at->timestamp : 0;

                                if ($clientUpdate > $serverUpdate) {
                                    $existing->delete(); // Soft delete
                                    // Manually update updated_at to match client if desired, or let Laravel set it
                                    // For sync to be idempotent, we might want to respect client timestamp
                                    $existing->deleted_at = $change['deleted_at'];
                                    $existing->save();
                                    $deletedCount++;
                                }
                            }
                        }
                        continue; // Done with this item
                    }

                    // UPSERT (Create or Update)
                    $data = array_filter($change, function ($key) {
                        return in_array($key, [
                            'client_id',
                            'date',
                            'meal_type',
                            'name',
                            'description',
                            'ingredients',
                            'nutritional_info',
                            'calories',
                            'protein_g',
                            'fats_g',
                            'carbs_g',
                            'fiber_g',
                            'sugar_g',
                            'sodium_mg',
                            'hunger_before',
                            'hunger_after',
                            'satisfaction',
                            'eating_reasons',
                            'notes',
                            'metadata',
                            'created_at',
                            'updated_at'
                        ]);
                    }, ARRAY_FILTER_USE_KEY);

                    // Ensure user_id is set
                    $data['user_id'] = $user->id;

                    if ($existing) {
                        // Conflict Resolution: Newest wins
                        $clientUpdate = strtotime($change['updated_at'] ?? 0);
                        $serverUpdate = $existing->updated_at ? $existing->updated_at->timestamp : 0;

                        if ($clientUpdate > $serverUpdate) {
                            // Restore if it was deleted but client says it's active
                            if ($existing->trashed()) {
                                $existing->restore();
                            }
                            $existing->update($data);
                            $updatedCount++;
                        }
                        // Else: Server has newer data, ignore client change (server version will be sent back)
                    } else {
                        // Create new
                        Meal::create($data);
                        $syncedCount++;
                    }

                } catch (\Exception $e) {
                    $errors[] = "Item $index: " . $e->getMessage();
                }
            }

            // 2. Fetch updates for client (Delta Sync)
            $query = Meal::withTrashed()->where('user_id', $user->id);

            if ($lastSync) {
                $query->where('updated_at', '>', $lastSync);
            }

            $serverChanges = $query->get();

            // Format response
            return ResponseHelper::success(
                [
                    'changes' => $serverChanges, // Send back updated/new/deleted records
                    'processed' => [
                        'created' => $syncedCount,
                        'updated' => $updatedCount,
                        'deleted' => $deletedCount,
                    ],
                    'errors' => $errors,
                    'timestamp' => now()->toIso8601String(), // New sync watermark
                ],
                'Sync completed successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Sync failed: ' . $e->getMessage());
        }
    }
}

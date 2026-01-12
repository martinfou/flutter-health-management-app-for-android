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
                'date', 'meal_type', 'name', 'description', 'ingredients',
                'nutritional_info', 'calories', 'protein_g', 'fats_g', 'carbs_g',
                'fiber_g', 'sugar_g', 'sodium_mg', 'hunger_before', 'hunger_after',
                'satisfaction', 'eating_reasons', 'notes', 'metadata'
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
    public function sync(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            $validator = Validator::make($request->all(), [
                'meals' => 'required|array',
                'meals.*.date' => 'required|date',
                'meals.*.meal_type' => 'required|in:breakfast,lunch,dinner,snack',
                'meals.*.name' => 'required|string|max:255',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            $meals = $request->input('meals', []);
            $synced = 0;
            $updated = 0;
            $errors = [];

            foreach ($meals as $index => $mealData) {
                try {
                    // Match by user_id + date + meal_type + name
                    $existing = Meal::where('user_id', $user->id)
                        ->where('date', $mealData['date'])
                        ->where('meal_type', $mealData['meal_type'])
                        ->where('name', $mealData['name'])
                        ->first();

                    if ($existing) {
                        // Update existing meal
                        $updateData = array_filter($mealData, function ($key) {
                            return !in_array($key, ['date', 'meal_type', 'name']);
                        }, ARRAY_FILTER_USE_KEY);

                        $existing->update($updateData);
                        $updated++;
                    } else {
                        // Create new meal
                        Meal::create([
                            'user_id' => $user->id,
                            'date' => $mealData['date'] ?? null,
                            'meal_type' => $mealData['meal_type'] ?? null,
                            'name' => $mealData['name'] ?? null,
                            'description' => $mealData['description'] ?? null,
                            'ingredients' => $mealData['ingredients'] ?? [],
                            'nutritional_info' => $mealData['nutritional_info'] ?? [],
                            'calories' => $mealData['calories'] ?? null,
                            'protein_g' => $mealData['protein_g'] ?? null,
                            'fats_g' => $mealData['fats_g'] ?? null,
                            'carbs_g' => $mealData['carbs_g'] ?? null,
                            'fiber_g' => $mealData['fiber_g'] ?? null,
                            'sugar_g' => $mealData['sugar_g'] ?? null,
                            'sodium_mg' => $mealData['sodium_mg'] ?? null,
                            'hunger_before' => $mealData['hunger_before'] ?? null,
                            'hunger_after' => $mealData['hunger_after'] ?? null,
                            'satisfaction' => $mealData['satisfaction'] ?? null,
                            'eating_reasons' => $mealData['eating_reasons'] ?? [],
                            'notes' => $mealData['notes'] ?? null,
                            'metadata' => $mealData['metadata'] ?? [],
                        ]);
                        $synced++;
                    }
                } catch (\Exception $e) {
                    $errors[] = "Meal $index: " . $e->getMessage();
                }
            }

            return ResponseHelper::success(
                [
                    'synced_count' => $synced,
                    'updated_count' => $updated,
                    'errors' => $errors,
                ],
                'Meals sync completed'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Sync failed: ' . $e->getMessage());
        }
    }
}

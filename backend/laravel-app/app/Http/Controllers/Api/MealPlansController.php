<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseHelper;
use App\Models\MealPlan;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MealPlansController extends Controller
{
    /**
     * Get all meal plans for the authenticated user
     * GET /api/v1/meal-plans
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
            $query = MealPlan::where('user_id', $user->id);

            if ($activeOnly === 'true' || $activeOnly === '1' || $activeOnly === true) {
                $query->where('active', true);
            }

            // Order and paginate
            $plans = $query->orderBy('start_date', 'desc')
                ->orderBy('created_at', 'desc')
                ->paginate($limit);

            return ResponseHelper::paginated($plans, 'Meal plans retrieved successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve meal plans: ' . $e->getMessage());
        }
    }

    /**
     * Get a specific meal plan by ID
     * GET /api/v1/meal-plans/{id}
     */
    public function show(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            $plan = MealPlan::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$plan) {
                return ResponseHelper::notFound('Meal plan not found');
            }

            return ResponseHelper::success(
                ['meal_plan' => $plan],
                'Meal plan retrieved successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve meal plan: ' . $e->getMessage());
        }
    }

    /**
     * Create a new meal plan
     * POST /api/v1/meal-plans
     */
    public function store(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            // Validate input
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'description' => 'nullable|string|max:1000',
                'start_date' => 'required|date',
                'end_date' => 'nullable|date|after_or_equal:start_date',
                'daily_calorie_target' => 'nullable|numeric|between:500,10000',
                'daily_protein_target' => 'nullable|numeric|between:0,1000',
                'daily_fats_target' => 'nullable|numeric|between:0,1000',
                'daily_carbs_target' => 'nullable|numeric|between:0,1000',
                'active' => 'nullable|boolean',
                'meals' => 'nullable|array',
                'goals' => 'nullable|array',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            $isActive = (bool) $request->input('active', false);

            // If setting as active, deactivate all other plans for this user
            if ($isActive) {
                MealPlan::where('user_id', $user->id)
                    ->update(['active' => false]);
            }

            // Create meal plan
            $plan = MealPlan::create([
                'user_id' => $user->id,
                'name' => $request->input('name'),
                'description' => $request->input('description'),
                'start_date' => $request->input('start_date'),
                'end_date' => $request->input('end_date'),
                'daily_calorie_target' => $request->input('daily_calorie_target'),
                'daily_protein_target' => $request->input('daily_protein_target'),
                'daily_fats_target' => $request->input('daily_fats_target'),
                'daily_carbs_target' => $request->input('daily_carbs_target'),
                'active' => $isActive,
                'meals' => $request->input('meals', []),
                'goals' => $request->input('goals', []),
                'metadata' => $request->input('metadata', []),
            ]);

            return ResponseHelper::success(
                ['meal_plan' => $plan],
                'Meal plan created successfully',
                201
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to create meal plan: ' . $e->getMessage());
        }
    }

    /**
     * Update an existing meal plan
     * PUT /api/v1/meal-plans/{id}
     */
    public function update(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            // Check if meal plan exists and belongs to user
            $plan = MealPlan::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$plan) {
                return ResponseHelper::notFound('Meal plan not found');
            }

            // Validate input (all optional for partial updates)
            $validator = Validator::make($request->all(), [
                'name' => 'nullable|string|max:255',
                'description' => 'nullable|string|max:1000',
                'start_date' => 'nullable|date',
                'end_date' => 'nullable|date|after_or_equal:start_date',
                'daily_calorie_target' => 'nullable|numeric|between:500,10000',
                'daily_protein_target' => 'nullable|numeric|between:0,1000',
                'daily_fats_target' => 'nullable|numeric|between:0,1000',
                'daily_carbs_target' => 'nullable|numeric|between:0,1000',
                'active' => 'nullable|boolean',
                'meals' => 'nullable|array',
                'goals' => 'nullable|array',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            $isActive = $request->input('active');

            // If setting as active, deactivate all other plans for this user
            if ($isActive === true || $isActive === 'true' || $isActive === '1') {
                MealPlan::where('user_id', $user->id)
                    ->where('id', '!=', $id)
                    ->update(['active' => false]);
            }

            // Update only provided fields
            $updateData = $request->only([
                'name', 'description', 'start_date', 'end_date',
                'daily_calorie_target', 'daily_protein_target',
                'daily_fats_target', 'daily_carbs_target', 'active',
                'meals', 'goals', 'metadata'
            ]);

            $plan->update($updateData);

            return ResponseHelper::success(
                ['meal_plan' => $plan],
                'Meal plan updated successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to update meal plan: ' . $e->getMessage());
        }
    }

    /**
     * Delete a meal plan
     * DELETE /api/v1/meal-plans/{id}
     */
    public function destroy(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            // Check if meal plan exists and belongs to user
            $plan = MealPlan::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$plan) {
                return ResponseHelper::notFound('Meal plan not found');
            }

            $plan->delete();

            return ResponseHelper::success([], 'Meal plan deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to delete meal plan: ' . $e->getMessage());
        }
    }

    /**
     * Sync meal plans (bulk upload for offline support)
     * POST /api/v1/meal-plans/sync
     */
    public function sync(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            $validator = Validator::make($request->all(), [
                'meal_plans' => 'required|array',
                'meal_plans.*.name' => 'required|string|max:255',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            $plans = $request->input('meal_plans', []);
            $synced = 0;
            $updated = 0;
            $errors = [];

            foreach ($plans as $index => $planData) {
                try {
                    // Match by user_id + name
                    $existing = MealPlan::where('user_id', $user->id)
                        ->where('name', $planData['name'])
                        ->first();

                    $isActive = (bool) ($planData['active'] ?? false);

                    if ($existing) {
                        // Update existing
                        $updateData = array_filter($planData, function ($key) {
                            return $key !== 'name';
                        }, ARRAY_FILTER_USE_KEY);

                        // If setting as active, deactivate others
                        if ($isActive) {
                            MealPlan::where('user_id', $user->id)
                                ->where('id', '!=', $existing->id)
                                ->update(['active' => false]);
                        }

                        $existing->update($updateData);
                        $updated++;
                    } else {
                        // Create new
                        // If setting as active, deactivate others
                        if ($isActive) {
                            MealPlan::where('user_id', $user->id)
                                ->update(['active' => false]);
                        }

                        MealPlan::create([
                            'user_id' => $user->id,
                            'name' => $planData['name'] ?? null,
                            'description' => $planData['description'] ?? null,
                            'start_date' => $planData['start_date'] ?? null,
                            'end_date' => $planData['end_date'] ?? null,
                            'daily_calorie_target' => $planData['daily_calorie_target'] ?? null,
                            'daily_protein_target' => $planData['daily_protein_target'] ?? null,
                            'daily_fats_target' => $planData['daily_fats_target'] ?? null,
                            'daily_carbs_target' => $planData['daily_carbs_target'] ?? null,
                            'active' => $isActive,
                            'meals' => $planData['meals'] ?? [],
                            'goals' => $planData['goals'] ?? [],
                            'metadata' => $planData['metadata'] ?? [],
                        ]);
                        $synced++;
                    }
                } catch (\Exception $e) {
                    $errors[] = "Meal plan $index: " . $e->getMessage();
                }
            }

            return ResponseHelper::success(
                [
                    'synced_count' => $synced,
                    'updated_count' => $updated,
                    'errors' => $errors,
                ],
                'Meal plans sync completed'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Sync failed: ' . $e->getMessage());
        }
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseHelper;
use App\Models\Exercise;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ExercisesController extends Controller
{
    /**
     * Get all exercises for the authenticated user
     * GET /api/v1/exercises
     */
    public function index(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            // Parse query parameters
            $date = $request->input('date');
            $startDate = $request->input('start_date');
            $endDate = $request->input('end_date');
            $type = $request->input('type');
            $isTemplate = $request->input('is_template');
            $limit = (int) $request->input('limit', 20);
            $limit = min($limit, 100); // Cap at 100

            // Build query
            $query = Exercise::where('user_id', $user->id);

            if ($isTemplate === 'true' || $isTemplate === '1') {
                $query->where('is_template', true);
            } elseif ($isTemplate === 'false' || $isTemplate === '0') {
                $query->where('is_template', false);
            }

            if ($date && $isTemplate !== 'true') {
                $query->whereDate('date', $date);
            } elseif ($startDate && $endDate && $isTemplate !== 'true') {
                $query->whereBetween('date', [$startDate, $endDate]);
            }

            if ($type) {
                $validTypes = ['strength', 'cardio', 'flexibility', 'sports'];
                if (in_array($type, $validTypes)) {
                    $query->where('type', $type);
                }
            }

            // Order and paginate
            $exercises = $query->orderBy('date', 'desc')
                ->orderBy('created_at', 'desc')
                ->paginate($limit);

            return ResponseHelper::paginated($exercises, 'Exercises retrieved successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve exercises: ' . $e->getMessage());
        }
    }

    /**
     * Get a specific exercise by ID
     * GET /api/v1/exercises/{id}
     */
    public function show(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            $exercise = Exercise::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$exercise) {
                return ResponseHelper::notFound('Exercise not found');
            }

            return ResponseHelper::success(
                ['exercise' => $exercise],
                'Exercise retrieved successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve exercise: ' . $e->getMessage());
        }
    }

    /**
     * Create a new exercise
     * POST /api/v1/exercises
     */
    public function store(Request $request)
    {
        try {
            $user = $request->attributes->get('user');
            $isTemplate = $request->input('is_template', false);

            // Validate input
            $rules = [
                'type' => 'required|in:strength,cardio,flexibility,sports',
                'name' => 'required|string|max:255',
                'description' => 'nullable|string|max:1000',
                'date' => 'nullable|date',
                'duration_minutes' => 'nullable|numeric|between:1,1440',
                'calories_burned' => 'nullable|numeric|between:0,10000',
                'intensity' => 'nullable|in:low,medium,high',
                'distance_km' => 'nullable|numeric|between:0,1000',
                'sets' => 'nullable|integer|between:1,100',
                'reps' => 'nullable|integer|between:1,100',
                'weight_kg' => 'nullable|numeric|between:0,1000',
                'notes' => 'nullable|string|max:1000',
                'muscle_groups' => 'nullable|array',
                'equipment' => 'nullable|array',
                'metadata' => 'nullable|array',
                'is_template' => 'nullable|boolean',
            ];

            // Date is required for non-template exercises
            if (!$isTemplate) {
                $rules['date'] = 'required|date';
            }

            $validator = Validator::make($request->all(), $rules);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            // Create exercise
            $exercise = Exercise::create([
                'user_id' => $user->id,
                'type' => $request->input('type'),
                'name' => $request->input('name'),
                'description' => $request->input('description'),
                'date' => $request->input('date'),
                'duration_minutes' => $request->input('duration_minutes'),
                'calories_burned' => $request->input('calories_burned'),
                'intensity' => $request->input('intensity'),
                'distance_km' => $request->input('distance_km'),
                'sets' => $request->input('sets'),
                'reps' => $request->input('reps'),
                'weight_kg' => $request->input('weight_kg'),
                'notes' => $request->input('notes'),
                'muscle_groups' => $request->input('muscle_groups', []),
                'equipment' => $request->input('equipment', []),
                'metadata' => $request->input('metadata', []),
                'is_template' => (bool) $request->input('is_template', false),
            ]);

            return ResponseHelper::success(
                ['exercise' => $exercise],
                'Exercise created successfully',
                201
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to create exercise: ' . $e->getMessage());
        }
    }

    /**
     * Update an existing exercise
     * PUT /api/v1/exercises/{id}
     */
    public function update(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            // Check if exercise exists and belongs to user
            $exercise = Exercise::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$exercise) {
                return ResponseHelper::notFound('Exercise not found');
            }

            // Validate input (all optional for partial updates)
            $validator = Validator::make($request->all(), [
                'type' => 'nullable|in:strength,cardio,flexibility,sports',
                'name' => 'nullable|string|max:255',
                'description' => 'nullable|string|max:1000',
                'date' => 'nullable|date',
                'duration_minutes' => 'nullable|numeric|between:1,1440',
                'calories_burned' => 'nullable|numeric|between:0,10000',
                'intensity' => 'nullable|in:low,medium,high',
                'distance_km' => 'nullable|numeric|between:0,1000',
                'sets' => 'nullable|integer|between:1,100',
                'reps' => 'nullable|integer|between:1,100',
                'weight_kg' => 'nullable|numeric|between:0,1000',
                'notes' => 'nullable|string|max:1000',
                'muscle_groups' => 'nullable|array',
                'equipment' => 'nullable|array',
                'metadata' => 'nullable|array',
                'is_template' => 'nullable|boolean',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            // Update only provided fields
            $updateData = $request->only([
                'type', 'name', 'description', 'date', 'duration_minutes',
                'calories_burned', 'intensity', 'distance_km', 'sets', 'reps',
                'weight_kg', 'notes', 'muscle_groups', 'equipment', 'metadata', 'is_template'
            ]);

            $exercise->update($updateData);

            return ResponseHelper::success(
                ['exercise' => $exercise],
                'Exercise updated successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to update exercise: ' . $e->getMessage());
        }
    }

    /**
     * Delete an exercise
     * DELETE /api/v1/exercises/{id}
     */
    public function destroy(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            // Check if exercise exists and belongs to user
            $exercise = Exercise::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$exercise) {
                return ResponseHelper::notFound('Exercise not found');
            }

            $exercise->delete();

            return ResponseHelper::success([], 'Exercise deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to delete exercise: ' . $e->getMessage());
        }
    }

    /**
     * Sync exercises (bulk upload for offline support)
     * POST /api/v1/exercises/sync
     */
    public function sync(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            $validator = Validator::make($request->all(), [
                'exercises' => 'required|array',
                'exercises.*.type' => 'required|in:strength,cardio,flexibility,sports',
                'exercises.*.name' => 'required|string|max:255',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            $exercises = $request->input('exercises', []);
            $synced = 0;
            $updated = 0;
            $errors = [];

            foreach ($exercises as $index => $exerciseData) {
                try {
                    $isTemplate = $exerciseData['is_template'] ?? false;

                    if ($isTemplate) {
                        // Match templates by user_id + name + is_template=1
                        $existing = Exercise::where('user_id', $user->id)
                            ->where('name', $exerciseData['name'])
                            ->where('is_template', true)
                            ->first();
                    } else {
                        // Match regular exercises by user_id + date + name + type
                        $existing = Exercise::where('user_id', $user->id)
                            ->where('date', $exerciseData['date'] ?? null)
                            ->where('name', $exerciseData['name'])
                            ->where('type', $exerciseData['type'])
                            ->first();
                    }

                    if ($existing) {
                        // Update existing
                        $updateData = array_filter($exerciseData, function ($key) {
                            return !in_array($key, ['name', 'type']);
                        }, ARRAY_FILTER_USE_KEY);

                        $existing->update($updateData);
                        $updated++;
                    } else {
                        // Create new
                        Exercise::create([
                            'user_id' => $user->id,
                            'type' => $exerciseData['type'] ?? null,
                            'name' => $exerciseData['name'] ?? null,
                            'description' => $exerciseData['description'] ?? null,
                            'date' => $exerciseData['date'] ?? null,
                            'duration_minutes' => $exerciseData['duration_minutes'] ?? null,
                            'calories_burned' => $exerciseData['calories_burned'] ?? null,
                            'intensity' => $exerciseData['intensity'] ?? null,
                            'distance_km' => $exerciseData['distance_km'] ?? null,
                            'sets' => $exerciseData['sets'] ?? null,
                            'reps' => $exerciseData['reps'] ?? null,
                            'weight_kg' => $exerciseData['weight_kg'] ?? null,
                            'notes' => $exerciseData['notes'] ?? null,
                            'muscle_groups' => $exerciseData['muscle_groups'] ?? [],
                            'equipment' => $exerciseData['equipment'] ?? [],
                            'metadata' => $exerciseData['metadata'] ?? [],
                            'is_template' => (bool) ($exerciseData['is_template'] ?? false),
                        ]);
                        $synced++;
                    }
                } catch (\Exception $e) {
                    $errors[] = "Exercise $index: " . $e->getMessage();
                }
            }

            return ResponseHelper::success(
                [
                    'synced_count' => $synced,
                    'updated_count' => $updated,
                    'errors' => $errors,
                ],
                'Exercises sync completed'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Sync failed: ' . $e->getMessage());
        }
    }
}

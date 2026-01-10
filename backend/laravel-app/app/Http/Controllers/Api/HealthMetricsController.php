<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\HealthMetric;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class HealthMetricsController extends Controller
{
    /**
     * Get all health metrics
     * GET /api/v1/health-metrics
     */
    public function index(Request $request)
    {
        $user = $request->attributes->get('user');

        $query = HealthMetric::where('user_id', $user->id);

        // Apply filters
        if ($request->has('start_date')) {
            $query->where('date', '>=', $request->start_date);
        }
        if ($request->has('end_date')) {
            $query->where('date', '<=', $request->end_date);
        }

        $limit = $request->input('limit', 100);
        $offset = $request->input('offset', 0);

        $total = $query->count();
        $metrics = $query->orderBy('date', 'desc')
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->offset($offset)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Health metrics retrieved successfully',
            'data' => $metrics,
            'pagination' => [
                'total' => $total,
                'page' => (int)($offset / $limit) + 1,
                'limit' => $limit,
            ],
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Create health metric
     * POST /api/v1/health-metrics
     */
    public function store(Request $request)
    {
        $user = $request->attributes->get('user');

        $validator = Validator::make($request->all(), [
            'date' => 'required|date',
            'weight_kg' => 'nullable|numeric|min:0|max:500',
            'sleep_hours' => 'nullable|numeric|min:0|max:24',
            'sleep_quality' => 'nullable|integer|min:1|max:10',
            'energy_level' => 'nullable|integer|min:1|max:10',
            'resting_heart_rate' => 'nullable|integer|min:0|max:300',
            'blood_pressure_systolic' => 'nullable|integer|min:0|max:300',
            'blood_pressure_diastolic' => 'nullable|integer|min:0|max:200',
            'steps' => 'nullable|integer|min:0|max:100000',
            'calories_burned' => 'nullable|integer|min:0|max:10000',
            'water_intake_ml' => 'nullable|integer|min:0|max:10000',
            'mood' => 'nullable|in:excellent,good,neutral,poor,terrible',
            'stress_level' => 'nullable|integer|min:1|max:10',
            'notes' => 'nullable|string|max:1000',
            'metadata' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
                'timestamp' => now()->toIso8601String(),
            ], 422);
        }

        // Check for duplicate date
        $existing = HealthMetric::where('user_id', $user->id)
            ->where('date', $request->date)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'A health metric entry already exists for this date',
                'timestamp' => now()->toIso8601String(),
            ], 409);
        }

        try {
            $metric = HealthMetric::create([
                'user_id' => $user->id,
                'date' => $request->date,
                'weight_kg' => $request->weight_kg,
                'sleep_hours' => $request->sleep_hours,
                'sleep_quality' => $request->sleep_quality,
                'energy_level' => $request->energy_level,
                'resting_heart_rate' => $request->resting_heart_rate,
                'blood_pressure_systolic' => $request->blood_pressure_systolic,
                'blood_pressure_diastolic' => $request->blood_pressure_diastolic,
                'steps' => $request->steps,
                'calories_burned' => $request->calories_burned,
                'water_intake_ml' => $request->water_intake_ml,
                'mood' => $request->mood,
                'stress_level' => $request->stress_level,
                'notes' => $request->notes,
                'metadata' => $request->metadata ?? [],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Health metric created successfully',
                'data' => ['health_metric' => $metric],
                'timestamp' => now()->toIso8601String(),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create health metric',
                'timestamp' => now()->toIso8601String(),
            ], 500);
        }
    }

    /**
     * Get single health metric
     * GET /api/v1/health-metrics/{id}
     */
    public function show(Request $request, $id)
    {
        $user = $request->attributes->get('user');

        $metric = HealthMetric::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$metric) {
            return response()->json([
                'success' => false,
                'message' => 'Health metric not found',
                'timestamp' => now()->toIso8601String(),
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Health metric retrieved successfully',
            'data' => ['health_metric' => $metric],
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Update health metric
     * PUT /api/v1/health-metrics/{id}
     */
    public function update(Request $request, $id)
    {
        $user = $request->attributes->get('user');

        $metric = HealthMetric::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$metric) {
            return response()->json([
                'success' => false,
                'message' => 'Health metric not found',
                'timestamp' => now()->toIso8601String(),
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'date' => 'nullable|date',
            'weight_kg' => 'nullable|numeric|min:0|max:500',
            'sleep_hours' => 'nullable|numeric|min:0|max:24',
            'sleep_quality' => 'nullable|integer|min:1|max:10',
            'energy_level' => 'nullable|integer|min:1|max:10',
            'resting_heart_rate' => 'nullable|integer|min:0|max:300',
            'blood_pressure_systolic' => 'nullable|integer|min:0|max:300',
            'blood_pressure_diastolic' => 'nullable|integer|min:0|max:200',
            'steps' => 'nullable|integer|min:0|max:100000',
            'calories_burned' => 'nullable|integer|min:0|max:10000',
            'water_intake_ml' => 'nullable|integer|min:0|max:10000',
            'mood' => 'nullable|in:excellent,good,neutral,poor,terrible',
            'stress_level' => 'nullable|integer|min:1|max:10',
            'notes' => 'nullable|string|max:1000',
            'metadata' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
                'timestamp' => now()->toIso8601String(),
            ], 422);
        }

        try {
            $metric->fill($request->all());
            $metric->save();

            return response()->json([
                'success' => true,
                'message' => 'Health metric updated successfully',
                'data' => ['health_metric' => $metric],
                'timestamp' => now()->toIso8601String(),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update health metric',
                'timestamp' => now()->toIso8601String(),
            ], 500);
        }
    }

    /**
     * Delete health metric
     * DELETE /api/v1/health-metrics/{id}
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->attributes->get('user');

        $metric = HealthMetric::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$metric) {
            return response()->json([
                'success' => false,
                'message' => 'Health metric not found',
                'timestamp' => now()->toIso8601String(),
            ], 404);
        }

        try {
            $metric->delete();

            return response()->json([
                'success' => true,
                'message' => 'Health metric deleted successfully',
                'timestamp' => now()->toIso8601String(),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete health metric',
                'timestamp' => now()->toIso8601String(),
            ], 500);
        }
    }

    /**
     * Bulk sync health metrics
     * POST /api/v1/health-metrics/sync
     */
    public function sync(Request $request)
    {
        $user = $request->attributes->get('user');

        $validator = Validator::make($request->all(), [
            'metrics' => 'required|array',
            'metrics.*.date' => 'required|date',
            'metrics.*.weight_kg' => 'nullable|numeric',
            'metrics.*.sleep_hours' => 'nullable|numeric',
            'metrics.*.sleep_quality' => 'nullable|integer',
            'metrics.*.energy_level' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
                'timestamp' => now()->toIso8601String(),
            ], 422);
        }

        try {
            $synced = [];
            $errors = [];

            foreach ($request->metrics as $metricData) {
                try {
                    // Check if metric exists
                    $metric = HealthMetric::where('user_id', $user->id)
                        ->where('date', $metricData['date'])
                        ->first();

                    if ($metric) {
                        // Update existing
                        $metric->fill($metricData);
                        $metric->save();
                    } else {
                        // Create new
                        $metricData['user_id'] = $user->id;
                        $metric = HealthMetric::create($metricData);
                    }

                    $synced[] = $metric;

                } catch (\Exception $e) {
                    $errors[] = [
                        'date' => $metricData['date'] ?? 'unknown',
                        'error' => $e->getMessage(),
                    ];
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Health metrics synced successfully',
                'data' => [
                    'synced' => count($synced),
                    'failed' => count($errors),
                    'metrics' => $synced,
                    'errors' => $errors,
                ],
                'timestamp' => now()->toIso8601String(),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to sync health metrics',
                'timestamp' => now()->toIso8601String(),
            ], 500);
        }
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseHelper;
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
        try {
            $user = $request->attributes->get('user');

            $query = HealthMetric::where('user_id', $user->id);

            // Apply filters
            if ($request->has('start_date')) {
                $query->where('date', '>=', $request->start_date);
            }
            if ($request->has('end_date')) {
                $query->where('date', '<=', $request->end_date);
            }

            $limit = (int) $request->input('limit', 20);
            $limit = min($limit, 100);

            $metrics = $query->orderBy('date', 'desc')
                ->orderBy('created_at', 'desc')
                ->paginate($limit);

            return ResponseHelper::paginated($metrics, 'Health metrics retrieved successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve health metrics: ' . $e->getMessage());
        }
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
            return ResponseHelper::validationError($validator->errors());
        }

        // Check for duplicate date
        $existing = HealthMetric::where('user_id', $user->id)
            ->where('date', $request->date)
            ->first();

        if ($existing) {
            return ResponseHelper::error(
                'A health metric entry already exists for this date',
                409
            );
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

            return ResponseHelper::success(
                ['health_metric' => $metric],
                'Health metric created successfully',
                201
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to create health metric: ' . $e->getMessage());
        }
    }

    /**
     * Get single health metric
     * GET /api/v1/health-metrics/{id}
     */
    public function show(Request $request, $id)
    {
        try {
            $user = $request->attributes->get('user');

            $metric = HealthMetric::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$metric) {
                return ResponseHelper::notFound('Health metric not found');
            }

            return ResponseHelper::success(
                ['health_metric' => $metric],
                'Health metric retrieved successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve health metric: ' . $e->getMessage());
        }
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
            return ResponseHelper::notFound('Health metric not found');
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
            return ResponseHelper::validationError($validator->errors());
        }

        try {
            $metric->fill($request->only([
                'date', 'weight_kg', 'sleep_hours', 'sleep_quality', 'energy_level',
                'resting_heart_rate', 'blood_pressure_systolic', 'blood_pressure_diastolic',
                'steps', 'calories_burned', 'water_intake_ml', 'mood', 'stress_level',
                'notes', 'metadata'
            ]));
            $metric->save();

            return ResponseHelper::success(
                ['health_metric' => $metric],
                'Health metric updated successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to update health metric: ' . $e->getMessage());
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
            return ResponseHelper::notFound('Health metric not found');
        }

        try {
            $metric->delete();

            return ResponseHelper::success([], 'Health metric deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to delete health metric: ' . $e->getMessage());
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
            return ResponseHelper::validationError($validator->errors());
        }

        try {
            $synced = 0;
            $updated = 0;
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
                        $updated++;
                    } else {
                        // Create new
                        $metricData['user_id'] = $user->id;
                        HealthMetric::create($metricData);
                        $synced++;
                    }

                } catch (\Exception $e) {
                    $errors[] = [
                        'date' => $metricData['date'] ?? 'unknown',
                        'error' => $e->getMessage(),
                    ];
                }
            }

            return ResponseHelper::success(
                [
                    'synced_count' => $synced,
                    'updated_count' => $updated,
                    'errors' => $errors,
                ],
                'Health metrics sync completed'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to sync health metrics: ' . $e->getMessage());
        }
    }
}

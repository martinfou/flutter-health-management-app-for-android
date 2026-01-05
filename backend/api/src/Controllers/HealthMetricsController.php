<?php

declare(strict_types=1);

namespace HealthApp\Controllers;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Respect\Validation\Validator as v;

class HealthMetricsController
{
    private DatabaseService $db;

    public function __construct(DatabaseService $db)
    {
        $this->db = $db;
    }

    /**
     * Get all health metrics for the authenticated user
     */
    public function getAll(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $queryParams = $request->getQueryParams();

        // Parse query parameters
        $startDate = $queryParams['start_date'] ?? null;
        $endDate = $queryParams['end_date'] ?? null;
        $limit = (int)($queryParams['limit'] ?? 100);
        $offset = (int)($queryParams['offset'] ?? 0);

        // Build query
        $whereClauses = ["user_id = ?"];
        $params = [$user['id']];

        if ($startDate) {
            $whereClauses[] = "date >= ?";
            $params[] = $startDate;
        }

        if ($endDate) {
            $whereClauses[] = "date <= ?";
            $params[] = $endDate;
        }

        $whereClause = implode(' AND ', $whereClauses);

        // Get total count
        $countResult = $this->db->select(
            "SELECT COUNT(*) as total FROM health_metrics WHERE $whereClause",
            $params
        );
        $total = $countResult[0]['total'];

        // Get paginated results
        $metrics = $this->db->select(
            "SELECT * FROM health_metrics WHERE $whereClause ORDER BY date DESC, created_at DESC LIMIT ? OFFSET ?",
            array_merge($params, [$limit, $offset])
        );

        // Decode JSON fields
        foreach ($metrics as &$metric) {
            $metric['metadata'] = json_decode($metric['metadata'] ?? '{}', true);
        }

        return ResponseHelper::paginated(
            $response,
            $metrics,
            (int)($offset / $limit) + 1,
            $limit,
            $total,
            'Health metrics retrieved successfully'
        );
    }

    /**
     * Get a specific health metric by ID
     */
    public function getById(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        $metrics = $this->db->select(
            "SELECT * FROM health_metrics WHERE id = ? AND user_id = ? AND deleted_at IS NULL",
            [$id, $user['id']]
        );

        if (empty($metrics)) {
            return ResponseHelper::notFound($response, 'Health metric not found');
        }

        $metric = $metrics[0];
        $metric['metadata'] = json_decode($metric['metadata'] ?? '{}', true);

        return ResponseHelper::success($response, [
            'health_metric' => $metric
        ], 'Health metric retrieved successfully');
    }

    /**
     * Create a new health metric
     */
    public function create(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateHealthMetricData($data);
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Check for duplicate date (one entry per date per user)
            $existing = $this->db->select(
                "SELECT id FROM health_metrics WHERE user_id = ? AND date = ?",
                [$user['id'], $data['date']]
            );

            if (!empty($existing)) {
                return ResponseHelper::error(
                    $response,
                    'A health metric entry already exists for this date',
                    409
                );
            }

            // Prepare data for insertion
            $insertData = $this->prepareHealthMetricData($data, $user['id']);

            // Insert record
            $this->db->execute(
                "INSERT INTO health_metrics (user_id, date, weight_kg, sleep_hours, sleep_quality,
                energy_level, resting_heart_rate, blood_pressure_systolic, blood_pressure_diastolic,
                steps, calories_burned, water_intake_ml, mood, stress_level, notes, metadata,
                created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                $insertData
            );

            $metricId = (int) $this->db->lastInsertId();

            // Return created record
            $request = $request->withAttribute('id', $metricId);
            return $this->getById($request, $response)->withStatus(201);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to create health metric');
        }
    }

    /**
     * Update an existing health metric
     */
    public function update(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateHealthMetricData($data, false); // Partial update allowed
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM health_metrics WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Health metric not found');
            }

            // Prepare update data
            $updateFields = [];
            $params = [];

            $allowedFields = [
                'weight_kg', 'sleep_hours', 'sleep_quality', 'energy_level',
                'resting_heart_rate', 'blood_pressure_systolic', 'blood_pressure_diastolic',
                'steps', 'calories_burned', 'water_intake_ml', 'mood', 'stress_level',
                'notes', 'metadata'
            ];

            foreach ($allowedFields as $field) {
                if (isset($data[$field])) {
                    if ($field === 'metadata') {
                        $updateFields[] = "$field = ?";
                        $params[] = json_encode($data[$field]);
                    } else {
                        $updateFields[] = "$field = ?";
                        $params[] = $data[$field];
                    }
                }
            }

            if (empty($updateFields)) {
                return ResponseHelper::validationError($response, [
                    'data' => 'No valid fields to update'
                ]);
            }

            $updateFields[] = "updated_at = NOW()";
            $params[] = $id;

            $query = "UPDATE health_metrics SET " . implode(', ', $updateFields) . " WHERE id = ?";
            $this->db->execute($query, $params);

            // Return updated record
            return $this->getById($request, $response);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to update health metric');
        }
    }

    /**
     * Delete a health metric (soft delete)
     */
    public function delete(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM health_metrics WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Health metric not found');
            }

            // Soft delete
            $this->db->execute(
                "UPDATE health_metrics SET deleted_at = NOW(), updated_at = NOW() WHERE id = ?",
                [$id]
            );

            return ResponseHelper::success($response, [], 'Health metric deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to delete health metric');
        }
    }

    /**
     * Sync health metrics (bulk upload for offline support)
     */
    public function sync(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        if (empty($data['metrics']) || !is_array($data['metrics'])) {
            return ResponseHelper::validationError($response, [
                'metrics' => 'Metrics array is required'
            ]);
        }

        $synced = 0;
        $errors = [];

        try {
            $this->db->beginTransaction();

            foreach ($data['metrics'] as $index => $metric) {
                try {
                    // Validate each metric
                    $validation = $this->validateHealthMetricData($metric);
                    if (!$validation['valid']) {
                        $errors[] = "Metric $index: " . implode(', ', $validation['errors']);
                        continue;
                    }

                    // Check for existing record
                    $existing = $this->db->select(
                        "SELECT id FROM health_metrics WHERE user_id = ? AND date = ?",
                        [$user['id'], $metric['date']]
                    );

                    $insertData = $this->prepareHealthMetricData($metric, $user['id']);

                    if (!empty($existing)) {
                        // Update existing
                        $updateFields = [];
                        $params = [];

                        $fieldMap = [
                            'weight_kg', 'sleep_hours', 'sleep_quality', 'energy_level',
                            'resting_heart_rate', 'blood_pressure_systolic', 'blood_pressure_diastolic',
                            'steps', 'calories_burned', 'water_intake_ml', 'mood', 'stress_level',
                            'notes', 'metadata'
                        ];

                        foreach ($fieldMap as $i => $field) {
                            $updateFields[] = "$field = ?";
                            $params[] = $insertData[$i + 1]; // Skip user_id and date
                        }

                        $updateFields[] = "updated_at = NOW()";
                        $params[] = $existing[0]['id'];

                        $query = "UPDATE health_metrics SET " . implode(', ', $updateFields) . " WHERE id = ?";
                        $this->db->execute($query, $params);
                    } else {
                        // Insert new
                        $this->db->execute(
                            "INSERT INTO health_metrics (user_id, date, weight_kg, sleep_hours, sleep_quality,
                            energy_level, resting_heart_rate, blood_pressure_systolic, blood_pressure_diastolic,
                            steps, calories_burned, water_intake_ml, mood, stress_level, notes, metadata,
                            created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                            $insertData
                        );
                    }

                    $synced++;

                } catch (\Exception $e) {
                    $errors[] = "Metric $index: " . $e->getMessage();
                }
            }

            $this->db->commit();

            return ResponseHelper::success($response, [
                'synced_count' => $synced,
                'errors' => $errors
            ], 'Health metrics sync completed');

        } catch (\Exception $e) {
            $this->db->rollback();
            return ResponseHelper::serverError($response, 'Sync failed: ' . $e->getMessage());
        }
    }

    /**
     * Validate health metric data
     */
    private function validateHealthMetricData(array $data, bool $requireDate = true): array
    {
        $errors = [];

        if ($requireDate && (empty($data['date']) || !strtotime($data['date']))) {
            $errors['date'] = 'Valid date is required';
        }

        $numericFields = [
            'weight_kg' => [0, 500],
            'sleep_hours' => [0, 24],
            'sleep_quality' => [1, 10],
            'energy_level' => [1, 10],
            'resting_heart_rate' => [30, 200],
            'blood_pressure_systolic' => [70, 250],
            'blood_pressure_diastolic' => [40, 150],
            'steps' => [0, 100000],
            'calories_burned' => [0, 10000],
            'water_intake_ml' => [0, 10000],
            'stress_level' => [1, 10]
        ];

        foreach ($numericFields as $field => $range) {
            if (isset($data[$field])) {
                if (!is_numeric($data[$field]) || $data[$field] < $range[0] || $data[$field] > $range[1]) {
                    $errors[$field] = "Must be a number between {$range[0]} and {$range[1]}";
                }
            }
        }

        if (isset($data['mood'])) {
            $validMoods = ['excellent', 'good', 'neutral', 'poor', 'terrible'];
            if (!in_array($data['mood'], $validMoods)) {
                $errors['mood'] = 'Invalid mood value';
            }
        }

        if (isset($data['notes']) && strlen($data['notes']) > 1000) {
            $errors['notes'] = 'Notes must be less than 1000 characters';
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }

    /**
     * Prepare health metric data for database insertion
     */
    private function prepareHealthMetricData(array $data, int $userId): array
    {
        return [
            $userId,
            $data['date'],
            $data['weight_kg'] ?? null,
            $data['sleep_hours'] ?? null,
            $data['sleep_quality'] ?? null,
            $data['energy_level'] ?? null,
            $data['resting_heart_rate'] ?? null,
            $data['blood_pressure_systolic'] ?? null,
            $data['blood_pressure_diastolic'] ?? null,
            $data['steps'] ?? null,
            $data['calories_burned'] ?? null,
            $data['water_intake_ml'] ?? null,
            $data['mood'] ?? null,
            $data['stress_level'] ?? null,
            $data['notes'] ?? null,
            isset($data['metadata']) ? json_encode($data['metadata']) : null,
        ];
    }
}
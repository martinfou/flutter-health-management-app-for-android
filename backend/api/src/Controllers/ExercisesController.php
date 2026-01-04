<?php

declare(strict_types=1);

namespace HealthApp\Controllers;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Respect\Validation\Validator as v;

class ExercisesController
{
    private DatabaseService $db;

    public function __construct(DatabaseService $db)
    {
        $this->db = $db;
    }

    /**
     * Get all exercises for the authenticated user
     */
    public function getAll(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $queryParams = $request->getQueryParams();

        // Parse query parameters
        $date = $queryParams['date'] ?? null;
        $startDate = $queryParams['start_date'] ?? null;
        $endDate = $queryParams['end_date'] ?? null;
        $type = $queryParams['type'] ?? null;
        $templatesOnly = filter_var($queryParams['templates_only'] ?? false, FILTER_VALIDATE_BOOLEAN);
        $loggedOnly = filter_var($queryParams['logged_only'] ?? false, FILTER_VALIDATE_BOOLEAN);
        $limit = (int)($queryParams['limit'] ?? 100);
        $offset = (int)($queryParams['offset'] ?? 0);

        // Build query
        $whereClauses = ["user_id = ?"];
        $params = [$user['id']];

        if ($templatesOnly) {
            $whereClauses[] = "is_template = 1";
        } elseif ($loggedOnly) {
            $whereClauses[] = "is_template = 0 AND date IS NOT NULL";
        }

        if ($date) {
            $whereClauses[] = "date = ?";
            $params[] = $date;
        } elseif ($startDate && $endDate) {
            $whereClauses[] = "date BETWEEN ? AND ?";
            $params[] = $startDate;
            $params[] = $endDate;
        }

        if ($type) {
            $validTypes = ['cardio', 'strength', 'flexibility', 'sports', 'other'];
            if (in_array($type, $validTypes)) {
                $whereClauses[] = "type = ?";
                $params[] = $type;
            }
        }

        $whereClause = implode(' AND ', $whereClauses);

        // Get total count
        $countResult = $this->db->select(
            "SELECT COUNT(*) as total FROM exercises WHERE $whereClause",
            $params
        );
        $total = $countResult[0]['total'];

        // Get paginated results
        $exercises = $this->db->select(
            "SELECT * FROM exercises WHERE $whereClause ORDER BY is_template DESC, date DESC, name ASC LIMIT ? OFFSET ?",
            array_merge($params, [$limit, $offset])
        );

        // Decode JSON fields and add template info
        foreach ($exercises as &$exercise) {
            $exercise['muscle_groups'] = json_decode($exercise['muscle_groups'] ?? '[]', true);
            $exercise['equipment'] = json_decode($exercise['equipment'] ?? '[]', true);
            $exercise['metadata'] = json_decode($exercise['metadata'] ?? '{}', true);

            // Add template information if this is a logged exercise
            if (!$exercise['is_template'] && $exercise['template_id']) {
                $template = $this->db->select(
                    "SELECT name, type, muscle_groups, equipment, instructions, difficulty FROM exercises WHERE id = ? AND is_template = 1",
                    [$exercise['template_id']]
                );
                if (!empty($template)) {
                    $exercise['template_info'] = $template[0];
                    $exercise['template_info']['muscle_groups'] = json_decode($exercise['template_info']['muscle_groups'] ?? '[]', true);
                    $exercise['template_info']['equipment'] = json_decode($exercise['template_info']['equipment'] ?? '[]', true);
                }
            }
        }

        return ResponseHelper::paginated(
            $response,
            $exercises,
            (int)($offset / $limit) + 1,
            $limit,
            $total,
            'Exercises retrieved successfully'
        );
    }

    /**
     * Get a specific exercise by ID
     */
    public function getById(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        $exercises = $this->db->select(
            "SELECT * FROM exercises WHERE id = ? AND user_id = ?",
            [$id, $user['id']]
        );

        if (empty($exercises)) {
            return ResponseHelper::notFound($response, 'Exercise not found');
        }

        $exercise = $exercises[0];
        $exercise['muscle_groups'] = json_decode($exercise['muscle_groups'] ?? '[]', true);
        $exercise['equipment'] = json_decode($exercise['equipment'] ?? '[]', true);
        $exercise['metadata'] = json_decode($exercise['metadata'] ?? '{}', true);

        return ResponseHelper::success($response, [
            'exercise' => $exercise
        ], 'Exercise retrieved successfully');
    }

    /**
     * Create a new exercise
     */
    public function create(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateExerciseData($data);
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // If this is a logged exercise with a template_id, verify template exists
            if (isset($data['template_id']) && !$data['is_template']) {
                $template = $this->db->select(
                    "SELECT id FROM exercises WHERE id = ? AND user_id = ? AND is_template = 1",
                    [$data['template_id'], $user['id']]
                );
                if (empty($template)) {
                    return ResponseHelper::validationError($response, [
                        'template_id' => 'Invalid template ID'
                    ]);
                }
            }

            // Prepare data for insertion
            $insertData = $this->prepareExerciseData($data, $user['id']);

            // Insert record
            $this->db->execute(
                "INSERT INTO exercises (user_id, name, type, muscle_groups, equipment, instructions, difficulty, estimated_calories_per_minute, is_template, template_id, date, sets, reps_per_set, weight_kg, duration_minutes, distance_km, calories_burned, heart_rate_avg, heart_rate_max, perceived_effort, notes, metadata, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                $insertData
            );

            $exerciseId = (int) $this->db->lastInsertId();

            // Return created record
            $request = $request->withAttribute('id', $exerciseId);
            return $this->getById($request, $response)->withStatus(201);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to create exercise');
        }
    }

    /**
     * Update an existing exercise
     */
    public function update(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateExerciseData($data, false); // Partial update allowed
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id, is_template FROM exercises WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Exercise not found');
            }

            // If this is a logged exercise with a template_id, verify template exists
            if (isset($data['template_id']) && !$existing[0]['is_template']) {
                $template = $this->db->select(
                    "SELECT id FROM exercises WHERE id = ? AND user_id = ? AND is_template = 1",
                    [$data['template_id'], $user['id']]
                );
                if (empty($template)) {
                    return ResponseHelper::validationError($response, [
                        'template_id' => 'Invalid template ID'
                    ]);
                }
            }

            // Prepare update data
            $updateFields = [];
            $params = [];

            $allowedFields = [
                'name', 'type', 'muscle_groups', 'equipment', 'instructions', 'difficulty',
                'estimated_calories_per_minute', 'is_template', 'template_id', 'date', 'sets',
                'reps_per_set', 'weight_kg', 'duration_minutes', 'distance_km', 'calories_burned',
                'heart_rate_avg', 'heart_rate_max', 'perceived_effort', 'notes', 'metadata'
            ];

            foreach ($allowedFields as $field) {
                if (isset($data[$field])) {
                    if (in_array($field, ['muscle_groups', 'equipment', 'metadata'])) {
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

            $query = "UPDATE exercises SET " . implode(', ', $updateFields) . " WHERE id = ?";
            $this->db->execute($query, $params);

            // Return updated record
            return $this->getById($request, $response);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to update exercise');
        }
    }

    /**
     * Delete an exercise
     */
    public function delete(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM exercises WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Exercise not found');
            }

            // Check if this template is referenced by logged exercises
            $references = $this->db->select(
                "SELECT COUNT(*) as count FROM exercises WHERE template_id = ?",
                [$id]
            );

            if ($references[0]['count'] > 0) {
                return ResponseHelper::error(
                    $response,
                    'Cannot delete template that is referenced by logged exercises',
                    409
                );
            }

            // Hard delete exercise
            $this->db->execute(
                "DELETE FROM exercises WHERE id = ?",
                [$id]
            );

            return ResponseHelper::success($response, [], 'Exercise deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to delete exercise');
        }
    }

    /**
     * Sync exercises (bulk upload for offline support)
     */
    public function sync(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        if (empty($data['exercises']) || !is_array($data['exercises'])) {
            return ResponseHelper::validationError($response, [
                'exercises' => 'Exercises array is required'
            ]);
        }

        $synced = 0;
        $updated = 0;
        $errors = [];

        try {
            $this->db->beginTransaction();

            foreach ($data['exercises'] as $index => $exercise) {
                try {
                    // For templates, use name as unique identifier
                    // For logged exercises, use combination of template_id and date
                    if ($exercise['is_template']) {
                        $existing = $this->db->select(
                            "SELECT id FROM exercises WHERE user_id = ? AND name = ? AND is_template = 1",
                            [$user['id'], $exercise['name']]
                        );
                    } else {
                        $existing = $this->db->select(
                            "SELECT id FROM exercises WHERE user_id = ? AND template_id = ? AND date = ?",
                            [$user['id'], $exercise['template_id'] ?? null, $exercise['date']]
                        );
                    }

                    $insertData = $this->prepareExerciseData($exercise, $user['id']);

                    if (!empty($existing)) {
                        // Update existing exercise
                        $updateFields = [];
                        $params = [];

                        $fieldMap = [
                            'type', 'muscle_groups', 'equipment', 'instructions', 'difficulty',
                            'estimated_calories_per_minute', 'sets', 'reps_per_set', 'weight_kg',
                            'duration_minutes', 'distance_km', 'calories_burned', 'heart_rate_avg',
                            'heart_rate_max', 'perceived_effort', 'notes', 'metadata'
                        ];

                        foreach ($fieldMap as $i => $field) {
                            $updateFields[] = "$field = ?";
                            $params[] = $insertData[$i + 3]; // Skip user_id, name, is_template
                        }

                        $updateFields[] = "updated_at = NOW()";
                        $params[] = $existing[0]['id'];

                        $query = "UPDATE exercises SET " . implode(', ', $updateFields) . " WHERE id = ?";
                        $this->db->execute($query, $params);
                        $updated++;
                    } else {
                        // Insert new exercise
                        $this->db->execute(
                            "INSERT INTO exercises (user_id, name, type, muscle_groups, equipment, instructions, difficulty, estimated_calories_per_minute, is_template, template_id, date, sets, reps_per_set, weight_kg, duration_minutes, distance_km, calories_burned, heart_rate_avg, heart_rate_max, perceived_effort, notes, metadata, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                            $insertData
                        );
                        $synced++;
                    }

                } catch (\Exception $e) {
                    $errors[] = "Exercise $index: " . $e->getMessage();
                }
            }

            $this->db->commit();

            return ResponseHelper::success($response, [
                'synced_count' => $synced,
                'updated_count' => $updated,
                'errors' => $errors
            ], 'Exercises sync completed');

        } catch (\Exception $e) {
            $this->db->rollback();
            return ResponseHelper::serverError($response, 'Sync failed: ' . $e->getMessage());
        }
    }

    /**
     * Validate exercise data
     */
    private function validateExerciseData(array $data, bool $requireAll = true): array
    {
        $errors = [];

        if ($requireAll && (empty($data['name']) || strlen($data['name']) < 1)) {
            $errors['name'] = 'Exercise name is required';
        }

        if (isset($data['name']) && strlen($data['name']) > 255) {
            $errors['name'] = 'Exercise name must be less than 255 characters';
        }

        if ($requireAll && (empty($data['type']) || !isset($data['is_template']))) {
            $errors['type'] = 'Exercise type is required';
            $errors['is_template'] = 'Template flag is required';
        }

        if (isset($data['type'])) {
            $validTypes = ['cardio', 'strength', 'flexibility', 'sports', 'other'];
            if (!in_array($data['type'], $validTypes)) {
                $errors['type'] = 'Invalid exercise type';
            }
        }

        if (isset($data['difficulty'])) {
            $validDifficulties = ['beginner', 'intermediate', 'advanced'];
            if (!in_array($data['difficulty'], $validDifficulties)) {
                $errors['difficulty'] = 'Invalid difficulty level';
            }
        }

        if (isset($data['date']) && !strtotime($data['date'])) {
            $errors['date'] = 'Invalid date format';
        }

        // Validate numeric fields
        $numericFields = [
            'estimated_calories_per_minute' => [0, 50],
            'sets' => [1, 100],
            'reps_per_set' => [1, 1000],
            'weight_kg' => [0, 1000],
            'duration_minutes' => [1, 1440], // Max 24 hours
            'distance_km' => [0, 500],
            'calories_burned' => [0, 5000],
            'heart_rate_avg' => [30, 220],
            'heart_rate_max' => [30, 220],
            'perceived_effort' => [1, 10]
        ];

        foreach ($numericFields as $field => $range) {
            if (isset($data[$field])) {
                if (!is_numeric($data[$field]) || $data[$field] < $range[0] || $data[$field] > $range[1]) {
                    $errors[$field] = "Must be a number between {$range[0]} and {$range[1]}";
                }
            }
        }

        if (isset($data['instructions']) && strlen($data['instructions']) > 2000) {
            $errors['instructions'] = 'Instructions must be less than 2000 characters';
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
     * Prepare exercise data for database insertion
     */
    private function prepareExerciseData(array $data, int $userId): array
    {
        return [
            $userId,
            $data['name'],
            $data['type'],
            isset($data['muscle_groups']) ? json_encode($data['muscle_groups']) : '[]',
            isset($data['equipment']) ? json_encode($data['equipment']) : '[]',
            $data['instructions'] ?? null,
            $data['difficulty'] ?? 'intermediate',
            $data['estimated_calories_per_minute'] ?? null,
            $data['is_template'] ?? false,
            $data['template_id'] ?? null,
            $data['date'] ?? null,
            $data['sets'] ?? null,
            $data['reps_per_set'] ?? null,
            $data['weight_kg'] ?? null,
            $data['duration_minutes'] ?? null,
            $data['distance_km'] ?? null,
            $data['calories_burned'] ?? null,
            $data['heart_rate_avg'] ?? null,
            $data['heart_rate_max'] ?? null,
            $data['perceived_effort'] ?? null,
            $data['notes'] ?? null,
            isset($data['metadata']) ? json_encode($data['metadata']) : '{}',
        ];
    }
}
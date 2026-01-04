<?php

declare(strict_types=1);

namespace HealthApp\Controllers;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Respect\Validation\Validator as v;

class MealPlansController
{
    private DatabaseService $db;

    public function __construct(DatabaseService $db)
    {
        $this->db = $db;
    }

    /**
     * Get all meal plans for the authenticated user
     */
    public function getAll(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $queryParams = $request->getQueryParams();

        // Parse query parameters
        $activeOnly = filter_var($queryParams['active_only'] ?? true, FILTER_VALIDATE_BOOLEAN);
        $limit = (int)($queryParams['limit'] ?? 100);
        $offset = (int)($queryParams['offset'] ?? 0);

        // Build query
        $whereClauses = ["user_id = ?"];
        $params = [$user['id']];

        if ($activeOnly) {
            $whereClauses[] = "is_active = 1";
        }

        $whereClause = implode(' AND ', $whereClauses);

        // Get total count
        $countResult = $this->db->select(
            "SELECT COUNT(*) as total FROM meal_plans WHERE $whereClause",
            $params
        );
        $total = $countResult[0]['total'];

        // Get paginated results
        $mealPlans = $this->db->select(
            "SELECT * FROM meal_plans WHERE $whereClause ORDER BY is_active DESC, name ASC, created_at DESC LIMIT ? OFFSET ?",
            array_merge($params, [$limit, $offset])
        );

        // Decode JSON fields
        foreach ($mealPlans as &$mealPlan) {
            $mealPlan['meals'] = json_decode($mealPlan['meals'] ?? '[]', true);
            $mealPlan['metadata'] = json_decode($mealPlan['metadata'] ?? '{}', true);
        }

        return ResponseHelper::paginated(
            $response,
            $mealPlans,
            (int)($offset / $limit) + 1,
            $limit,
            $total,
            'Meal plans retrieved successfully'
        );
    }

    /**
     * Get a specific meal plan by ID
     */
    public function getById(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        $mealPlans = $this->db->select(
            "SELECT * FROM meal_plans WHERE id = ? AND user_id = ?",
            [$id, $user['id']]
        );

        if (empty($mealPlans)) {
            return ResponseHelper::notFound($response, 'Meal plan not found');
        }

        $mealPlan = $mealPlans[0];
        $mealPlan['meals'] = json_decode($mealPlan['meals'] ?? '[]', true);
        $mealPlan['metadata'] = json_decode($mealPlan['metadata'] ?? '{}', true);

        return ResponseHelper::success($response, [
            'meal_plan' => $mealPlan
        ], 'Meal plan retrieved successfully');
    }

    /**
     * Create a new meal plan
     */
    public function create(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateMealPlanData($data);
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // If setting this as active, deactivate other active plans
            if ($data['is_active'] ?? false) {
                $this->db->execute(
                    "UPDATE meal_plans SET is_active = 0, updated_at = NOW() WHERE user_id = ? AND is_active = 1",
                    [$user['id']]
                );
            }

            // Prepare data for insertion
            $insertData = $this->prepareMealPlanData($data, $user['id']);

            // Insert record
            $this->db->execute(
                "INSERT INTO meal_plans (user_id, name, description, start_date, end_date, is_active, target_calories, target_protein_g, target_fats_g, target_carbs_g, meals, notes, metadata, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                $insertData
            );

            $mealPlanId = (int) $this->db->lastInsertId();

            // Return created record
            $request = $request->withAttribute('id', $mealPlanId);
            return $this->getById($request, $response)->withStatus(201);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to create meal plan');
        }
    }

    /**
     * Update an existing meal plan
     */
    public function update(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateMealPlanData($data, false); // Partial update allowed
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM meal_plans WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Meal plan not found');
            }

            // If setting this as active, deactivate other active plans
            if (isset($data['is_active']) && $data['is_active']) {
                $this->db->execute(
                    "UPDATE meal_plans SET is_active = 0, updated_at = NOW() WHERE user_id = ? AND is_active = 1 AND id != ?",
                    [$user['id'], $id]
                );
            }

            // Prepare update data
            $updateFields = [];
            $params = [];

            $allowedFields = [
                'name', 'description', 'start_date', 'end_date', 'is_active',
                'target_calories', 'target_protein_g', 'target_fats_g', 'target_carbs_g',
                'meals', 'notes', 'metadata'
            ];

            foreach ($allowedFields as $field) {
                if (isset($data[$field])) {
                    if (in_array($field, ['meals', 'metadata'])) {
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

            $query = "UPDATE meal_plans SET " . implode(', ', $updateFields) . " WHERE id = ?";
            $this->db->execute($query, $params);

            // Return updated record
            return $this->getById($request, $response);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to update meal plan');
        }
    }

    /**
     * Delete a meal plan
     */
    public function delete(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM meal_plans WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Meal plan not found');
            }

            // Hard delete meal plan
            $this->db->execute(
                "DELETE FROM meal_plans WHERE id = ?",
                [$id]
            );

            return ResponseHelper::success($response, [], 'Meal plan deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to delete meal plan');
        }
    }

    /**
     * Sync meal plans (bulk upload for offline support)
     */
    public function sync(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        if (empty($data['meal_plans']) || !is_array($data['meal_plans'])) {
            return ResponseHelper::validationError($response, [
                'meal_plans' => 'Meal plans array is required'
            ]);
        }

        $synced = 0;
        $updated = 0;
        $errors = [];

        try {
            $this->db->beginTransaction();

            foreach ($data['meal_plans'] as $index => $mealPlan) {
                try {
                    // Use name as unique identifier for meal plans
                    $existing = $this->db->select(
                        "SELECT id FROM meal_plans WHERE user_id = ? AND name = ?",
                        [$user['id'], $mealPlan['name']]
                    );

                    $insertData = $this->prepareMealPlanData($mealPlan, $user['id']);

                    if (!empty($existing)) {
                        // Update existing meal plan
                        $updateFields = [];
                        $params = [];

                        $fieldMap = [
                            'description', 'start_date', 'end_date', 'is_active', 'target_calories',
                            'target_protein_g', 'target_fats_g', 'target_carbs_g', 'meals', 'notes', 'metadata'
                        ];

                        foreach ($fieldMap as $i => $field) {
                            $updateFields[] = "$field = ?";
                            $params[] = $insertData[$i + 2]; // Skip user_id and name
                        }

                        // Handle active status - if syncing an active plan, deactivate others
                        if ($mealPlan['is_active']) {
                            $this->db->execute(
                                "UPDATE meal_plans SET is_active = 0, updated_at = NOW() WHERE user_id = ? AND is_active = 1 AND id != ?",
                                [$user['id'], $existing[0]['id']]
                            );
                        }

                        $updateFields[] = "updated_at = NOW()";
                        $params[] = $existing[0]['id'];

                        $query = "UPDATE meal_plans SET " . implode(', ', $updateFields) . " WHERE id = ?";
                        $this->db->execute($query, $params);
                        $updated++;
                    } else {
                        // Insert new meal plan
                        $this->db->execute(
                            "INSERT INTO meal_plans (user_id, name, description, start_date, end_date, is_active, target_calories, target_protein_g, target_fats_g, target_carbs_g, meals, notes, metadata, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                            $insertData
                        );
                        $synced++;
                    }

                } catch (\Exception $e) {
                    $errors[] = "Meal plan $index: " . $e->getMessage();
                }
            }

            $this->db->commit();

            return ResponseHelper::success($response, [
                'synced_count' => $synced,
                'updated_count' => $updated,
                'errors' => $errors
            ], 'Meal plans sync completed');

        } catch (\Exception $e) {
            $this->db->rollback();
            return ResponseHelper::serverError($response, 'Sync failed: ' . $e->getMessage());
        }
    }

    /**
     * Validate meal plan data
     */
    private function validateMealPlanData(array $data, bool $requireAll = true): array
    {
        $errors = [];

        if ($requireAll && (empty($data['name']) || strlen($data['name']) < 1)) {
            $errors['name'] = 'Meal plan name is required';
        }

        if (isset($data['name']) && strlen($data['name']) > 255) {
            $errors['name'] = 'Meal plan name must be less than 255 characters';
        }

        if (isset($data['description']) && strlen($data['description']) > 1000) {
            $errors['description'] = 'Description must be less than 1000 characters';
        }

        if (isset($data['start_date']) && !strtotime($data['start_date'])) {
            $errors['start_date'] = 'Invalid start date format';
        }

        if (isset($data['end_date']) && !strtotime($data['end_date'])) {
            $errors['end_date'] = 'Invalid end date format';
        }

        // Validate date range
        if (isset($data['start_date']) && isset($data['end_date'])) {
            if (strtotime($data['start_date']) > strtotime($data['end_date'])) {
                $errors['end_date'] = 'End date must be after start date';
            }
        }

        // Validate nutritional targets
        $numericFields = [
            'target_calories' => [500, 10000],
            'target_protein_g' => [10, 1000],
            'target_fats_g' => [10, 1000],
            'target_carbs_g' => [10, 1000]
        ];

        foreach ($numericFields as $field => $range) {
            if (isset($data[$field])) {
                if (!is_numeric($data[$field]) || $data[$field] < $range[0] || $data[$field] > $range[1]) {
                    $errors[$field] = "Must be a number between {$range[0]} and {$range[1]}";
                }
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
     * Prepare meal plan data for database insertion
     */
    private function prepareMealPlanData(array $data, int $userId): array
    {
        return [
            $userId,
            $data['name'],
            $data['description'] ?? null,
            $data['start_date'] ?? null,
            $data['end_date'] ?? null,
            $data['is_active'] ?? false,
            $data['target_calories'] ?? null,
            $data['target_protein_g'] ?? null,
            $data['target_fats_g'] ?? null,
            $data['target_carbs_g'] ?? null,
            isset($data['meals']) ? json_encode($data['meals']) : '[]',
            $data['notes'] ?? null,
            isset($data['metadata']) ? json_encode($data['metadata']) : '{}',
        ];
    }
}
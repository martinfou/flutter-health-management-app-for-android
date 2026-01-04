<?php

declare(strict_types=1);

namespace HealthApp\Controllers;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Respect\Validation\Validator as v;

class MealsController
{
    private DatabaseService $db;

    public function __construct(DatabaseService $db)
    {
        $this->db = $db;
    }

    /**
     * Get all meals for the authenticated user
     */
    public function getAll(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $queryParams = $request->getQueryParams();

        // Parse query parameters
        $date = $queryParams['date'] ?? null;
        $startDate = $queryParams['start_date'] ?? null;
        $endDate = $queryParams['end_date'] ?? null;
        $mealType = $queryParams['meal_type'] ?? null;
        $limit = (int)($queryParams['limit'] ?? 100);
        $offset = (int)($queryParams['offset'] ?? 0);

        // Build query
        $whereClauses = ["user_id = ?"];
        $params = [$user['id']];

        if ($date) {
            $whereClauses[] = "date = ?";
            $params[] = $date;
        } elseif ($startDate && $endDate) {
            $whereClauses[] = "date BETWEEN ? AND ?";
            $params[] = $startDate;
            $params[] = $endDate;
        }

        if ($mealType) {
            $validTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
            if (in_array($mealType, $validTypes)) {
                $whereClauses[] = "meal_type = ?";
                $params[] = $mealType;
            }
        }

        $whereClause = implode(' AND ', $whereClauses);

        // Get total count
        $countResult = $this->db->select(
            "SELECT COUNT(*) as total FROM meals WHERE $whereClause",
            $params
        );
        $total = $countResult[0]['total'];

        // Get paginated results
        $meals = $this->db->select(
            "SELECT * FROM meals WHERE $whereClause ORDER BY date DESC, meal_type ASC, created_at DESC LIMIT ? OFFSET ?",
            array_merge($params, [$limit, $offset])
        );

        // Decode JSON fields
        foreach ($meals as &$meal) {
            $meal['ingredients'] = json_decode($meal['ingredients'] ?? '[]', true);
            $meal['nutritional_info'] = json_decode($meal['nutritional_info'] ?? '{}', true);
            $meal['eating_reasons'] = json_decode($meal['eating_reasons'] ?? '[]', true);
            $meal['metadata'] = json_decode($meal['metadata'] ?? '{}', true);
        }

        return ResponseHelper::paginated(
            $response,
            $meals,
            (int)($offset / $limit) + 1,
            $limit,
            $total,
            'Meals retrieved successfully'
        );
    }

    /**
     * Get a specific meal by ID
     */
    public function getById(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        $meals = $this->db->select(
            "SELECT * FROM meals WHERE id = ? AND user_id = ?",
            [$id, $user['id']]
        );

        if (empty($meals)) {
            return ResponseHelper::notFound($response, 'Meal not found');
        }

        $meal = $meals[0];
        $meal['ingredients'] = json_decode($meal['ingredients'] ?? '[]', true);
        $meal['nutritional_info'] = json_decode($meal['nutritional_info'] ?? '{}', true);
        $meal['eating_reasons'] = json_decode($meal['eating_reasons'] ?? '[]', true);
        $meal['metadata'] = json_decode($meal['metadata'] ?? '{}', true);

        return ResponseHelper::success($response, [
            'meal' => $meal
        ], 'Meal retrieved successfully');
    }

    /**
     * Create a new meal
     */
    public function create(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateMealData($data);
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Prepare data for insertion
            $insertData = $this->prepareMealData($data, $user['id']);

            // Insert record
            $this->db->execute(
                "INSERT INTO meals (user_id, date, meal_type, name, description, ingredients, nutritional_info, calories, protein_g, fats_g, carbs_g, fiber_g, sugar_g, sodium_mg, hunger_before, hunger_after, satisfaction, eating_reasons, notes, metadata, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                $insertData
            );

            $mealId = (int) $this->db->lastInsertId();

            // Return created record
            $request = $request->withAttribute('id', $mealId);
            return $this->getById($request, $response)->withStatus(201);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to create meal');
        }
    }

    /**
     * Update an existing meal
     */
    public function update(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateMealData($data, false); // Partial update allowed
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM meals WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Meal not found');
            }

            // Prepare update data
            $updateFields = [];
            $params = [];

            $allowedFields = [
                'date', 'meal_type', 'name', 'description', 'ingredients', 'nutritional_info',
                'calories', 'protein_g', 'fats_g', 'carbs_g', 'fiber_g', 'sugar_g', 'sodium_mg',
                'hunger_before', 'hunger_after', 'satisfaction', 'eating_reasons', 'notes', 'metadata'
            ];

            foreach ($allowedFields as $field) {
                if (isset($data[$field])) {
                    if (in_array($field, ['ingredients', 'nutritional_info', 'eating_reasons', 'metadata'])) {
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

            $query = "UPDATE meals SET " . implode(', ', $updateFields) . " WHERE id = ?";
            $this->db->execute($query, $params);

            // Return updated record
            return $this->getById($request, $response);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to update meal');
        }
    }

    /**
     * Delete a meal
     */
    public function delete(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM meals WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Meal not found');
            }

            // Hard delete meals (they're user-generated content)
            $this->db->execute(
                "DELETE FROM meals WHERE id = ?",
                [$id]
            );

            return ResponseHelper::success($response, [], 'Meal deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to delete meal');
        }
    }

    /**
     * Sync meals (bulk upload for offline support)
     */
    public function sync(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        if (empty($data['meals']) || !is_array($data['meals'])) {
            return ResponseHelper::validationError($response, [
                'meals' => 'Meals array is required'
            ]);
        }

        $synced = 0;
        $updated = 0;
        $errors = [];

        try {
            $this->db->beginTransaction();

            foreach ($data['meals'] as $index => $meal) {
                try {
                    // For meals, we'll use a combination of date, meal_type, and name as unique identifier
                    // This allows updating the same meal across syncs
                    $existing = $this->db->select(
                        "SELECT id FROM meals WHERE user_id = ? AND date = ? AND meal_type = ? AND name = ?",
                        [$user['id'], $meal['date'], $meal['meal_type'], $meal['name']]
                    );

                    $insertData = $this->prepareMealData($meal, $user['id']);

                    if (!empty($existing)) {
                        // Update existing meal
                        $updateFields = [];
                        $params = [];

                        $fieldMap = [
                            'description', 'ingredients', 'nutritional_info', 'calories', 'protein_g',
                            'fats_g', 'carbs_g', 'fiber_g', 'sugar_g', 'sodium_mg', 'hunger_before',
                            'hunger_after', 'satisfaction', 'eating_reasons', 'notes', 'metadata'
                        ];

                        foreach ($fieldMap as $i => $field) {
                            $updateFields[] = "$field = ?";
                            $params[] = $insertData[$i + 5]; // Skip user_id, date, meal_type, name, and created_at
                        }

                        $updateFields[] = "updated_at = NOW()";
                        $params[] = $existing[0]['id'];

                        $query = "UPDATE meals SET " . implode(', ', $updateFields) . " WHERE id = ?";
                        $this->db->execute($query, $params);
                        $updated++;
                    } else {
                        // Insert new meal
                        $this->db->execute(
                            "INSERT INTO meals (user_id, date, meal_type, name, description, ingredients, nutritional_info, calories, protein_g, fats_g, carbs_g, fiber_g, sugar_g, sodium_mg, hunger_before, hunger_after, satisfaction, eating_reasons, notes, metadata, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                            $insertData
                        );
                        $synced++;
                    }

                } catch (\Exception $e) {
                    $errors[] = "Meal $index: " . $e->getMessage();
                }
            }

            $this->db->commit();

            return ResponseHelper::success($response, [
                'synced_count' => $synced,
                'updated_count' => $updated,
                'errors' => $errors
            ], 'Meals sync completed');

        } catch (\Exception $e) {
            $this->db->rollback();
            return ResponseHelper::serverError($response, 'Sync failed: ' . $e->getMessage());
        }
    }

    /**
     * Validate meal data
     */
    private function validateMealData(array $data, bool $requireAll = true): array
    {
        $errors = [];

        if ($requireAll) {
            if (empty($data['date']) || !strtotime($data['date'])) {
                $errors['date'] = 'Valid date is required';
            }

            if (empty($data['meal_type'])) {
                $errors['meal_type'] = 'Meal type is required';
            } else {
                $validTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
                if (!in_array($data['meal_type'], $validTypes)) {
                    $errors['meal_type'] = 'Invalid meal type';
                }
            }

            if (empty($data['name']) || strlen($data['name']) < 1) {
                $errors['name'] = 'Meal name is required';
            }
        }

        if (isset($data['meal_type'])) {
            $validTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
            if (!in_array($data['meal_type'], $validTypes)) {
                $errors['meal_type'] = 'Invalid meal type';
            }
        }

        if (isset($data['date']) && !strtotime($data['date'])) {
            $errors['date'] = 'Invalid date format';
        }

        if (isset($data['name']) && strlen($data['name']) > 255) {
            $errors['name'] = 'Meal name must be less than 255 characters';
        }

        if (isset($data['description']) && strlen($data['description']) > 1000) {
            $errors['description'] = 'Description must be less than 1000 characters';
        }

        // Validate nutritional fields
        $numericFields = [
            'calories' => [0, 10000],
            'protein_g' => [0, 1000],
            'fats_g' => [0, 1000],
            'carbs_g' => [0, 1000],
            'fiber_g' => [0, 500],
            'sugar_g' => [0, 1000],
            'sodium_mg' => [0, 50000],
            'hunger_before' => [1, 10],
            'hunger_after' => [1, 10],
            'satisfaction' => [1, 10]
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
     * Prepare meal data for database insertion
     */
    private function prepareMealData(array $data, int $userId): array
    {
        return [
            $userId,
            $data['date'],
            $data['meal_type'],
            $data['name'],
            $data['description'] ?? null,
            isset($data['ingredients']) ? json_encode($data['ingredients']) : '[]',
            isset($data['nutritional_info']) ? json_encode($data['nutritional_info']) : '{}',
            $data['calories'] ?? null,
            $data['protein_g'] ?? null,
            $data['fats_g'] ?? null,
            $data['carbs_g'] ?? null,
            $data['fiber_g'] ?? null,
            $data['sugar_g'] ?? null,
            $data['sodium_mg'] ?? null,
            $data['hunger_before'] ?? null,
            $data['hunger_after'] ?? null,
            $data['satisfaction'] ?? null,
            isset($data['eating_reasons']) ? json_encode($data['eating_reasons']) : '[]',
            $data['notes'] ?? null,
            isset($data['metadata']) ? json_encode($data['metadata']) : '{}',
        ];
    }
}
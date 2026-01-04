<?php

declare(strict_types=1);

namespace HealthApp\Controllers;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Respect\Validation\Validator as v;

class MedicationsController
{
    private DatabaseService $db;

    public function __construct(DatabaseService $db)
    {
        $this->db = $db;
    }

    /**
     * Get all medications for the authenticated user
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
            "SELECT COUNT(*) as total FROM medications WHERE $whereClause",
            $params
        );
        $total = $countResult[0]['total'];

        // Get paginated results
        $medications = $this->db->select(
            "SELECT * FROM medications WHERE $whereClause ORDER BY name ASC, created_at DESC LIMIT ? OFFSET ?",
            array_merge($params, [$limit, $offset])
        );

        // Decode JSON fields
        foreach ($medications as &$medication) {
            $medication['reminder_times'] = json_decode($medication['reminder_times'] ?? '[]', true);
            $medication['metadata'] = json_decode($medication['metadata'] ?? '{}', true);
        }

        return ResponseHelper::paginated(
            $response,
            $medications,
            (int)($offset / $limit) + 1,
            $limit,
            $total,
            'Medications retrieved successfully'
        );
    }

    /**
     * Get a specific medication by ID
     */
    public function getById(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        $medications = $this->db->select(
            "SELECT * FROM medications WHERE id = ? AND user_id = ?",
            [$id, $user['id']]
        );

        if (empty($medications)) {
            return ResponseHelper::notFound($response, 'Medication not found');
        }

        $medication = $medications[0];
        $medication['reminder_times'] = json_decode($medication['reminder_times'] ?? '[]', true);
        $medication['metadata'] = json_decode($medication['metadata'] ?? '{}', true);

        return ResponseHelper::success($response, [
            'medication' => $medication
        ], 'Medication retrieved successfully');
    }

    /**
     * Create a new medication
     */
    public function create(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateMedicationData($data);
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Prepare data for insertion
            $insertData = $this->prepareMedicationData($data, $user['id']);

            // Insert record
            $this->db->execute(
                "INSERT INTO medications (user_id, name, dosage, frequency, instructions, start_date, end_date, is_active, reminder_enabled, reminder_times, notes, metadata, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                $insertData
            );

            $medicationId = (int) $this->db->lastInsertId();

            // Return created record
            $request = $request->withAttribute('id', $medicationId);
            return $this->getById($request, $response)->withStatus(201);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to create medication');
        }
    }

    /**
     * Update an existing medication
     */
    public function update(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateMedicationData($data, false); // Partial update allowed
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM medications WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Medication not found');
            }

            // Prepare update data
            $updateFields = [];
            $params = [];

            $allowedFields = [
                'name', 'dosage', 'frequency', 'instructions', 'start_date', 'end_date',
                'is_active', 'reminder_enabled', 'reminder_times', 'notes', 'metadata'
            ];

            foreach ($allowedFields as $field) {
                if (isset($data[$field])) {
                    if (in_array($field, ['reminder_times', 'metadata'])) {
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

            $query = "UPDATE medications SET " . implode(', ', $updateFields) . " WHERE id = ?";
            $this->db->execute($query, $params);

            // Return updated record
            return $this->getById($request, $response);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to update medication');
        }
    }

    /**
     * Delete a medication
     */
    public function delete(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $id = (int)$request->getAttribute('id');

        try {
            // Check if record exists and belongs to user
            $existing = $this->db->select(
                "SELECT id FROM medications WHERE id = ? AND user_id = ?",
                [$id, $user['id']]
            );

            if (empty($existing)) {
                return ResponseHelper::notFound($response, 'Medication not found');
            }

            // Hard delete medications (they're not as sensitive as health data)
            $this->db->execute(
                "DELETE FROM medications WHERE id = ?",
                [$id]
            );

            return ResponseHelper::success($response, [], 'Medication deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Failed to delete medication');
        }
    }

    /**
     * Sync medications (bulk upload for offline support)
     */
    public function sync(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        if (empty($data['medications']) || !is_array($data['medications'])) {
            return ResponseHelper::validationError($response, [
                'medications' => 'Medications array is required'
            ]);
        }

        $synced = 0;
        $updated = 0;
        $errors = [];

        try {
            $this->db->beginTransaction();

            foreach ($data['medications'] as $index => $medication) {
                try {
                    // Check if medication exists
                    $existing = $this->db->select(
                        "SELECT id FROM medications WHERE user_id = ? AND name = ?",
                        [$user['id'], $medication['name']]
                    );

                    $insertData = $this->prepareMedicationData($medication, $user['id']);

                    if (!empty($existing)) {
                        // Update existing medication
                        $updateFields = [];
                        $params = [];

                        $fieldMap = [
                            'dosage', 'frequency', 'instructions', 'start_date', 'end_date',
                            'is_active', 'reminder_enabled', 'reminder_times', 'notes', 'metadata'
                        ];

                        foreach ($fieldMap as $i => $field) {
                            $updateFields[] = "$field = ?";
                            $params[] = $insertData[$i + 2]; // Skip user_id and name
                        }

                        $updateFields[] = "updated_at = NOW()";
                        $params[] = $existing[0]['id'];

                        $query = "UPDATE medications SET " . implode(', ', $updateFields) . " WHERE id = ?";
                        $this->db->execute($query, $params);
                        $updated++;
                    } else {
                        // Insert new medication
                        $this->db->execute(
                            "INSERT INTO medications (user_id, name, dosage, frequency, instructions, start_date, end_date, is_active, reminder_enabled, reminder_times, notes, metadata, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
                            $insertData
                        );
                        $synced++;
                    }

                } catch (\Exception $e) {
                    $errors[] = "Medication $index: " . $e->getMessage();
                }
            }

            $this->db->commit();

            return ResponseHelper::success($response, [
                'synced_count' => $synced,
                'updated_count' => $updated,
                'errors' => $errors
            ], 'Medications sync completed');

        } catch (\Exception $e) {
            $this->db->rollback();
            return ResponseHelper::serverError($response, 'Sync failed: ' . $e->getMessage());
        }
    }

    /**
     * Validate medication data
     */
    private function validateMedicationData(array $data, bool $requireAll = true): array
    {
        $errors = [];

        if ($requireAll && (empty($data['name']) || strlen($data['name']) < 1)) {
            $errors['name'] = 'Medication name is required';
        }

        if (isset($data['name']) && strlen($data['name']) > 255) {
            $errors['name'] = 'Medication name must be less than 255 characters';
        }

        if (isset($data['dosage']) && strlen($data['dosage']) > 100) {
            $errors['dosage'] = 'Dosage must be less than 100 characters';
        }

        if (isset($data['frequency']) && strlen($data['frequency']) > 100) {
            $errors['frequency'] = 'Frequency must be less than 100 characters';
        }

        if (isset($data['start_date']) && !strtotime($data['start_date'])) {
            $errors['start_date'] = 'Invalid start date format';
        }

        if (isset($data['end_date']) && !strtotime($data['end_date'])) {
            $errors['end_date'] = 'Invalid end date format';
        }

        if (isset($data['instructions']) && strlen($data['instructions']) > 1000) {
            $errors['instructions'] = 'Instructions must be less than 1000 characters';
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
     * Prepare medication data for database insertion
     */
    private function prepareMedicationData(array $data, int $userId): array
    {
        return [
            $userId,
            $data['name'],
            $data['dosage'] ?? null,
            $data['frequency'] ?? null,
            $data['instructions'] ?? null,
            $data['start_date'] ?? null,
            $data['end_date'] ?? null,
            $data['is_active'] ?? true,
            $data['reminder_enabled'] ?? false,
            isset($data['reminder_times']) ? json_encode($data['reminder_times']) : '[]',
            $data['notes'] ?? null,
            isset($data['metadata']) ? json_encode($data['metadata']) : '{}',
        ];
    }
}
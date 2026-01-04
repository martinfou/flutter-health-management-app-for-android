<?php

declare(strict_types=1);

namespace HealthApp\Controllers;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;

class SyncController
{
    private DatabaseService $db;

    public function __construct(DatabaseService $db)
    {
        $this->db = $db;
    }

    /**
     * Get sync status for the user
     */
    public function getStatus(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');

        // Get last sync timestamps for each entity type
        $syncStatuses = $this->db->select(
            "SELECT entity_type, last_sync_timestamp, last_sync_version
             FROM sync_status
             WHERE user_id = ?
             ORDER BY entity_type",
            [$user['id']]
        );

        $status = [];
        foreach ($syncStatuses as $syncStatus) {
            $status[$syncStatus['entity_type']] = [
                'last_sync_timestamp' => $syncStatus['last_sync_timestamp'],
                'last_sync_version' => $syncStatus['last_sync_version']
            ];
        }

        return ResponseHelper::success($response, [
            'sync_status' => $status,
            'server_timestamp' => date('c')
        ], 'Sync status retrieved successfully');
    }

    /**
     * Bulk sync all entity types
     */
    public function bulkSync(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        $results = [];
        $errors = [];

        try {
            $this->db->beginTransaction();

            // Sync each entity type
            $entityTypes = ['health_metrics', 'medications', 'meals', 'exercises', 'meal_plans'];

            foreach ($entityTypes as $entityType) {
                if (isset($data[$entityType])) {
                    try {
                        $result = $this->syncEntityType($user['id'], $entityType, $data[$entityType]);
                        $results[$entityType] = $result;
                    } catch (\Exception $e) {
                        $errors[$entityType] = $e->getMessage();
                    }
                }
            }

            // Update sync status
            $this->updateSyncStatus($user['id'], $entityTypes);

            $this->db->commit();

            $responseData = [
                'results' => $results,
                'errors' => $errors,
                'server_timestamp' => date('c')
            ];

            if (!empty($errors)) {
                return ResponseHelper::error(
                    $response,
                    'Bulk sync completed with errors',
                    207, // Multi-status
                    $responseData
                );
            }

            return ResponseHelper::success($response, $responseData, 'Bulk sync completed successfully');

        } catch (\Exception $e) {
            $this->db->rollback();
            return ResponseHelper::serverError($response, 'Bulk sync failed: ' . $e->getMessage());
        }
    }

    /**
     * Resolve sync conflicts
     */
    public function resolveConflicts(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        if (empty($data['conflicts']) || !is_array($data['conflicts'])) {
            return ResponseHelper::validationError($response, [
                'conflicts' => 'Conflicts array is required'
            ]);
        }

        $resolved = 0;
        $errors = [];

        try {
            $this->db->beginTransaction();

            foreach ($data['conflicts'] as $index => $conflict) {
                try {
                    if (!$this->validateConflictData($conflict)) {
                        $errors[] = "Conflict $index: Invalid conflict data structure";
                        continue;
                    }

                    $this->resolveEntityConflict($user['id'], $conflict);
                    $resolved++;

                } catch (\Exception $e) {
                    $errors[] = "Conflict $index: " . $e->getMessage();
                }
            }

            $this->db->commit();

            return ResponseHelper::success($response, [
                'resolved_count' => $resolved,
                'errors' => $errors
            ], 'Conflict resolution completed');

        } catch (\Exception $e) {
            $this->db->rollback();
            return ResponseHelper::serverError($response, 'Conflict resolution failed: ' . $e->getMessage());
        }
    }

    /**
     * Sync a specific entity type
     */
    private function syncEntityType(int $userId, string $entityType, array $entities): array
    {
        $synced = 0;
        $updated = 0;
        $errors = [];

        foreach ($entities as $index => $entity) {
            try {
                $result = $this->syncEntity($userId, $entityType, $entity);
                if ($result['action'] === 'created') {
                    $synced++;
                } elseif ($result['action'] === 'updated') {
                    $updated++;
                }
            } catch (\Exception $e) {
                $errors[] = "Entity $index: " . $e->getMessage();
            }
        }

        return [
            'synced_count' => $synced,
            'updated_count' => $updated,
            'errors' => $errors
        ];
    }

    /**
     * Sync a single entity
     */
    private function syncEntity(int $userId, string $entityType, array $entity): array
    {
        // This is a simplified implementation
        // In a real implementation, you'd have specific logic for each entity type
        // For now, we'll use a generic approach

        $tableName = $this->getTableName($entityType);
        $idField = $this->getIdField($entityType);

        // Check if entity exists
        $existing = $this->db->select(
            "SELECT id, updated_at FROM $tableName WHERE user_id = ? AND $idField = ?",
            [$userId, $entity[$idField]]
        );

        if (!empty($existing)) {
            // Update existing entity (last write wins)
            $this->updateEntity($tableName, $userId, $entity, $existing[0]['id']);
            return ['action' => 'updated', 'id' => $existing[0]['id']];
        } else {
            // Create new entity
            $id = $this->createEntity($tableName, $userId, $entity);
            return ['action' => 'created', 'id' => $id];
        }
    }

    /**
     * Resolve conflict for a specific entity
     */
    private function resolveEntityConflict(int $userId, array $conflict): void
    {
        $entityType = $conflict['entity_type'];
        $resolution = $conflict['resolution']; // 'server_wins' or 'client_wins'

        $tableName = $this->getTableName($entityType);
        $idField = $this->getIdField($entityType);

        if ($resolution === 'client_wins') {
            // Update server data with client data
            $this->updateEntity($tableName, $userId, $conflict['client_data'], $conflict['server_id']);
        }
        // If server_wins, do nothing (server data is already correct)
    }

    /**
     * Update sync status for user
     */
    private function updateSyncStatus(int $userId, array $entityTypes): void
    {
        $now = date('Y-m-d H:i:s');

        foreach ($entityTypes as $entityType) {
            // Upsert sync status
            $this->db->execute(
                "INSERT INTO sync_status (user_id, entity_type, last_sync_timestamp, updated_at)
                 VALUES (?, ?, ?, NOW())
                 ON DUPLICATE KEY UPDATE
                 last_sync_timestamp = VALUES(last_sync_timestamp),
                 updated_at = NOW()",
                [$userId, $entityType, $now]
            );
        }
    }

    /**
     * Get table name for entity type
     */
    private function getTableName(string $entityType): string
    {
        $tableMap = [
            'health_metrics' => 'health_metrics',
            'medications' => 'medications',
            'meals' => 'meals',
            'exercises' => 'exercises',
            'meal_plans' => 'meal_plans'
        ];

        return $tableMap[$entityType] ?? $entityType;
    }

    /**
     * Get ID field name for entity type
     */
    private function getIdField(string $entityType): string
    {
        // Most entities use 'id', but some might use different field names
        return 'id';
    }

    /**
     * Create a new entity
     */
    private function createEntity(string $tableName, int $userId, array $data): int
    {
        // This is a simplified implementation
        // In practice, you'd have specific logic for each entity type
        // For now, we'll assume the data structure matches the table

        $data['user_id'] = $userId;
        $data['created_at'] = date('Y-m-d H:i:s');
        $data['updated_at'] = date('Y-m-d H:i:s');

        $fields = array_keys($data);
        $placeholders = array_fill(0, count($fields), '?');
        $values = array_values($data);

        $query = "INSERT INTO $tableName (" . implode(', ', $fields) . ") VALUES (" . implode(', ', $placeholders) . ")";
        $this->db->execute($query, $values);

        return (int) $this->db->lastInsertId();
    }

    /**
     * Update an existing entity
     */
    private function updateEntity(string $tableName, int $userId, array $data, int $id): void
    {
        // This is a simplified implementation
        // In practice, you'd have specific logic for each entity type

        $data['updated_at'] = date('Y-m-d H:i:s');

        $setParts = [];
        $values = [];

        foreach ($data as $field => $value) {
            if ($field !== 'id' && $field !== 'user_id') {
                $setParts[] = "$field = ?";
                $values[] = $value;
            }
        }

        $values[] = $id;
        $query = "UPDATE $tableName SET " . implode(', ', $setParts) . " WHERE id = ?";
        $this->db->execute($query, $values);
    }

    /**
     * Validate conflict data structure
     */
    private function validateConflictData(array $conflict): bool
    {
        return isset($conflict['entity_type']) &&
               isset($conflict['resolution']) &&
               in_array($conflict['resolution'], ['server_wins', 'client_wins']) &&
               isset($conflict['server_id']);
    }
}
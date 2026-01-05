<?php

declare(strict_types=1);

namespace App\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use App\Services\DatabaseService;
use App\Utils\ResponseHelper;

class HealthMetricsController
{
    private DatabaseService $db;
    private ResponseHelper $responseHelper;

    public function __construct(DatabaseService $db, ResponseHelper $responseHelper)
    {
        $this->db = $db;
        $this->responseHelper = $responseHelper;
    }

    public function index(Request $request, Response $response): Response
    {
        return $this->responseHelper->jsonResponse($response, [
            'success' => true,
            'data' => []
        ]);
    }

    public function create(Request $request, Response $response): Response
    {
        return $this->responseHelper->createdResponse($response, ['id' => 1], 'Health metric created');
    }

    public function show(Request $request, Response $response, array $args): Response
    {
        return $this->responseHelper->jsonResponse($response, [
            'success' => true,
            'data' => ['id' => $args['id'], 'metric_type' => 'weight', 'value' => 75.5]
        ]);
    }

    public function update(Request $request, Response $response, array $args): Response
    {
        return $this->responseHelper->jsonResponse($response, [
            'success' => true,
            'message' => 'Health metric updated',
            'data' => ['id' => $args['id']]
        ]);
    }

    public function delete(Request $request, Response $response, array $args): Response
    {
        return $this->responseHelper->jsonResponse($response, [
            'success' => true,
            'message' => 'Health metric deleted'
        ]);
    }
}
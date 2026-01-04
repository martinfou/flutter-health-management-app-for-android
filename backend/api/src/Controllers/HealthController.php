<?php

declare(strict_types=1);

namespace HealthApp\Controllers;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;

class HealthController
{
    private DatabaseService $db;

    public function __construct(DatabaseService $db)
    {
        $this->db = $db;
    }

    /**
     * Health check endpoint
     */
    public function check(Request $request, Response $response): Response
    {
        $health = [
            'status' => 'ok',
            'timestamp' => date('c'),
            'version' => '1.0.0',
            'services' => [
                'database' => $this->db->ping() ? 'ok' : 'error',
                'api' => 'ok',
            ],
        ];

        $statusCode = ($health['services']['database'] === 'ok') ? 200 : 503;

        return ResponseHelper::success($response, $health, 'Health check completed', $statusCode);
    }
}
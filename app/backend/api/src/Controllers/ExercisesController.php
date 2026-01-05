<?php

declare(strict_types=1);

namespace App\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use App\Services\DatabaseService;
use App\Utils\ResponseHelper;

class ExercisesController
{
    private ResponseHelper $responseHelper;

    public function __construct(DatabaseService $db, ResponseHelper $responseHelper)
    {
        $this->responseHelper = $responseHelper;
    }

    public function index(Request $request, Response $response): Response
    {
        return $this->responseHelper->jsonResponse($response, ['success' => true, 'data' => []]);
    }

    public function create(Request $request, Response $response): Response
    {
        return $this->responseHelper->createdResponse($response, ['id' => 1], 'Exercise created');
    }

    public function show(Request $request, Response $response, array $args): Response
    {
        return $this->responseHelper->jsonResponse($response, ['success' => true, 'data' => ['id' => $args['id']]]);
    }

    public function update(Request $request, Response $response, array $args): Response
    {
        return $this->responseHelper->jsonResponse($response, ['success' => true, 'message' => 'Exercise updated']);
    }

    public function delete(Request $request, Response $response, array $args): Response
    {
        return $this->responseHelper->jsonResponse($response, ['success' => true, 'message' => 'Exercise deleted']);
    }

    public function getStatistics(Request $request, Response $response): Response
    {
        return $this->responseHelper->jsonResponse($response, ['success' => true, 'data' => []]);
    }

    public function getExerciseSuggestions(Request $request, Response $response): Response
    {
        return $this->responseHelper->jsonResponse($response, ['success' => true, 'data' => []]);
    }

    public function getWorkoutHistory(Request $request, Response $response): Response
    {
        return $this->responseHelper->jsonResponse($response, ['success' => true, 'data' => []]);
    }
}
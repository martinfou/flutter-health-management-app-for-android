<?php

declare(strict_types=1);

namespace App\Utils;

use Psr\Http\Message\ResponseInterface as Response;

class ResponseHelper
{
    /**
     * Create a JSON response
     */
    public function jsonResponse(Response $response, array $data, int $status = 200): Response
    {
        $response->getBody()->write(json_encode($data, JSON_PRETTY_PRINT));
        return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus($status);
    }

    /**
     * Create a success response
     */
    public function successResponse(Response $response, string $message, array $data = [], int $status = 200): Response
    {
        return $this->jsonResponse($response, [
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $status);
    }

    /**
     * Create an error response
     */
    public function errorResponse(Response $response, string $message, int $status = 400, array $errors = []): Response
    {
        $errorData = [
            'success' => false,
            'message' => $message
        ];

        if (!empty($errors)) {
            $errorData['errors'] = $errors;
        }

        return $this->jsonResponse($response, $errorData, $status);
    }

    /**
     * Create a validation error response
     */
    public function validationErrorResponse(Response $response, array $errors): Response
    {
        return $this->jsonResponse($response, [
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }

    /**
     * Create an unauthorized response
     */
    public function unauthorizedResponse(Response $response, string $message = 'Unauthorized'): Response
    {
        return $this->jsonResponse($response, [
            'success' => false,
            'message' => $message
        ], 401);
    }

    /**
     * Create a forbidden response
     */
    public function forbiddenResponse(Response $response, string $message = 'Forbidden'): Response
    {
        return $this->jsonResponse($response, [
            'success' => false,
            'message' => $message
        ], 403);
    }

    /**
     * Create a not found response
     */
    public function notFoundResponse(Response $response, string $message = 'Resource not found'): Response
    {
        return $this->jsonResponse($response, [
            'success' => false,
            'message' => $message
        ], 404);
    }

    /**
     * Create a server error response
     */
    public function serverErrorResponse(Response $response, string $message = 'Internal server error'): Response
    {
        return $this->jsonResponse($response, [
            'success' => false,
            'message' => $message
        ], 500);
    }

    /**
     * Create a created response
     */
    public function createdResponse(Response $response, array $data, string $message = 'Resource created successfully'): Response
    {
        return $this->jsonResponse($response, [
            'success' => true,
            'message' => $message,
            'data' => $data
        ], 201);
    }

    /**
     * Create a no content response
     */
    public function noContentResponse(Response $response): Response
    {
        return $response->withStatus(204);
    }
}
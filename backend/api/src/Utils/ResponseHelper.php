<?php

declare(strict_types=1);

namespace HealthApp\Utils;

use Psr\Http\Message\ResponseInterface as Response;
use Slim\Psr7\Response as SlimResponse;

class ResponseHelper
{
    /**
     * Create success response
     */
    public static function success(
        Response $response,
        array $data = [],
        string $message = '',
        int $statusCode = 200
    ): Response {
        $payload = [
            'success' => true,
            'data' => $data,
            'message' => $message,
            'timestamp' => date('c'),
        ];

        $response->getBody()->write(json_encode($payload));

        return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus($statusCode);
    }

    /**
     * Create error response
     */
    public static function error(
        Response $response,
        string $message,
        int $statusCode = 400,
        array $errors = [],
        string $errorCode = ''
    ): Response {
        $payload = [
            'success' => false,
            'message' => $message,
            'error_code' => $errorCode,
            'errors' => $errors,
            'timestamp' => date('c'),
        ];

        $response->getBody()->write(json_encode($payload));

        return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus($statusCode);
    }

    /**
     * Create validation error response
     */
    public static function validationError(
        Response $response,
        array $errors,
        string $message = 'Validation failed'
    ): Response {
        return self::error($response, $message, 422, $errors, 'VALIDATION_ERROR');
    }

    /**
     * Create not found response
     */
    public static function notFound(
        Response $response,
        string $message = 'Resource not found'
    ): Response {
        return self::error($response, $message, 404, [], 'NOT_FOUND');
    }

    /**
     * Create unauthorized response
     */
    public static function unauthorized(
        Response $response,
        string $message = 'Unauthorized access'
    ): Response {
        return self::error($response, $message, 401, [], 'UNAUTHORIZED');
    }

    /**
     * Create forbidden response
     */
    public static function forbidden(
        Response $response,
        string $message = 'Access forbidden'
    ): Response {
        return self::error($response, $message, 403, [], 'FORBIDDEN');
    }

    /**
     * Create rate limit exceeded response
     */
    public static function rateLimitExceeded(
        Response $response,
        string $message = 'Rate limit exceeded'
    ): Response {
        return self::error($response, $message, 429, [], 'RATE_LIMIT_EXCEEDED');
    }

    /**
     * Create server error response
     */
    public static function serverError(
        Response $response,
        string $message = 'Internal server error'
    ): Response {
        return self::error($response, $message, 500, [], 'SERVER_ERROR');
    }

    /**
     * Create paginated response
     */
    public static function paginated(
        Response $response,
        array $data,
        int $page,
        int $perPage,
        int $total,
        string $message = ''
    ): Response {
        $totalPages = (int) ceil($total / $perPage);

        $pagination = [
            'page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'total_pages' => $totalPages,
            'has_next' => $page < $totalPages,
            'has_prev' => $page > 1,
        ];

        $payload = [
            'success' => true,
            'data' => $data,
            'pagination' => $pagination,
            'message' => $message,
            'timestamp' => date('c'),
        ];

        $response->getBody()->write(json_encode($payload));

        return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus(200);
    }
}
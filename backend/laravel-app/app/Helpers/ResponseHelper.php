<?php

namespace App\Helpers;

use Illuminate\Pagination\LengthAwarePaginator;

class ResponseHelper
{
    /**
     * Create success response matching Slim API format
     */
    public static function success(
        array $data = [],
        string $message = '',
        int $statusCode = 200
    ) {
        return response()->json([
            'success' => true,
            'data' => $data,
            'message' => $message,
            'timestamp' => now()->toIso8601String(),
        ], $statusCode);
    }

    /**
     * Create error response matching Slim API format
     */
    public static function error(
        string $message,
        int $statusCode = 400,
        array $errors = [],
        string $errorCode = ''
    ) {
        $payload = [
            'success' => false,
            'message' => $message,
            'timestamp' => now()->toIso8601String(),
        ];

        if (!empty($errorCode)) {
            $payload['error_code'] = $errorCode;
        }

        if (!empty($errors)) {
            $payload['errors'] = $errors;
        }

        return response()->json($payload, $statusCode);
    }

    /**
     * Create validation error response
     */
    public static function validationError(
        $errors,
        string $message = 'Validation failed'
    ) {
        // Handle both array and Illuminate\Support\MessageBag
        $errorArray = is_array($errors) ? $errors : $errors->toArray();

        return self::error($message, 422, $errorArray, 'VALIDATION_ERROR');
    }

    /**
     * Create not found response
     */
    public static function notFound(string $message = 'Resource not found')
    {
        return self::error($message, 404, [], 'NOT_FOUND');
    }

    /**
     * Create unauthorized response
     */
    public static function unauthorized(string $message = 'Unauthorized access')
    {
        return self::error($message, 401, [], 'UNAUTHORIZED');
    }

    /**
     * Create forbidden response
     */
    public static function forbidden(string $message = 'Access forbidden')
    {
        return self::error($message, 403, [], 'FORBIDDEN');
    }

    /**
     * Create rate limit exceeded response
     */
    public static function rateLimitExceeded(string $message = 'Rate limit exceeded')
    {
        return self::error($message, 429, [], 'RATE_LIMIT_EXCEEDED');
    }

    /**
     * Create server error response
     */
    public static function serverError(string $message = 'Internal server error')
    {
        return self::error($message, 500, [], 'SERVER_ERROR');
    }

    /**
     * Create paginated response matching Slim API format
     */
    public static function paginated(
        LengthAwarePaginator $items,
        string $message = 'Success'
    ) {
        return response()->json([
            'success' => true,
            'data' => $items->items(),
            'pagination' => [
                'page' => $items->currentPage(),
                'per_page' => $items->perPage(),
                'total' => $items->total(),
                'total_pages' => $items->lastPage(),
                'has_next' => $items->hasMorePages(),
                'has_prev' => $items->currentPage() > 1,
            ],
            'message' => $message,
            'timestamp' => now()->toIso8601String(),
        ]);
    }
}

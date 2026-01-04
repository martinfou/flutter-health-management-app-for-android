<?php

declare(strict_types=1);

namespace HealthApp\Middleware;

use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Throwable;

class ErrorMiddleware implements MiddlewareInterface
{
    private bool $displayErrorDetails;
    private bool $logErrors;
    private $logger;

    public function __construct(bool $displayErrorDetails = false, bool $logErrors = true, $logger = null)
    {
        $this->displayErrorDetails = $displayErrorDetails;
        $this->logErrors = $logErrors;
        $this->logger = $logger;
    }

    public function process(Request $request, RequestHandler $handler): Response
    {
        try {
            return $handler->handle($request);
        } catch (Throwable $e) {
            return $this->handleException($e, $request);
        }
    }

    private function handleException(Throwable $e, Request $request): Response
    {
        // Log the error if logging is enabled
        if ($this->logErrors) {
            $this->logError($e, $request);
        }

        // Determine error type and response
        $statusCode = $this->determineStatusCode($e);
        $errorCode = $this->determineErrorCode($e);
        $message = $this->determineErrorMessage($e);

        // Create error response
        $response = new \Slim\Psr7\Response();

        if ($this->displayErrorDetails) {
            // Include detailed error information for development
            return ResponseHelper::error($response, $message, $statusCode, [
                'error_code' => $errorCode,
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ], $errorCode);
        } else {
            // Production-safe error response
            return ResponseHelper::error($response, $message, $statusCode, [], $errorCode);
        }
    }

    private function determineStatusCode(Throwable $e): int
    {
        // Map exception types to HTTP status codes
        if ($e instanceof \InvalidArgumentException) {
            return 400; // Bad Request
        }

        if ($e instanceof \DomainException) {
            return 422; // Unprocessable Entity
        }

        if ($e instanceof \RuntimeException) {
            return 500; // Internal Server Error
        }

        if ($e instanceof \PDOException) {
            return 500; // Database error
        }

        if ($e instanceof \Firebase\JWT\ExpiredException) {
            return 401; // Unauthorized - token expired
        }

        if ($e instanceof \Firebase\JWT\SignatureInvalidException) {
            return 401; // Unauthorized - invalid signature
        }

        // Default to 500 for unknown exceptions
        return 500;
    }

    private function determineErrorCode(Throwable $e): string
    {
        // Map exception types to error codes
        if ($e instanceof \InvalidArgumentException) {
            return 'VALIDATION_ERROR';
        }

        if ($e instanceof \DomainException) {
            return 'DOMAIN_ERROR';
        }

        if ($e instanceof \RuntimeException) {
            return 'RUNTIME_ERROR';
        }

        if ($e instanceof \PDOException) {
            return 'DATABASE_ERROR';
        }

        if ($e instanceof \Firebase\JWT\ExpiredException) {
            return 'TOKEN_EXPIRED';
        }

        if ($e instanceof \Firebase\JWT\SignatureInvalidException) {
            return 'INVALID_TOKEN';
        }

        // Default error code
        return 'INTERNAL_ERROR';
    }

    private function determineErrorMessage(Throwable $e): string
    {
        // Use custom messages for known exceptions
        if ($e instanceof \Firebase\JWT\ExpiredException) {
            return 'Authentication token has expired';
        }

        if ($e instanceof \Firebase\JWT\SignatureInvalidException) {
            return 'Invalid authentication token';
        }

        if ($e instanceof \PDOException) {
            return 'Database error occurred';
        }

        // For security, don't expose internal error messages in production
        if ($this->displayErrorDetails) {
            return $e->getMessage();
        }

        // Default production-safe message
        return 'An unexpected error occurred';
    }

    private function logError(Throwable $e, Request $request): void
    {
        $logData = [
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'code' => $e->getCode(),
            'trace' => $e->getTraceAsString(),
            'request' => [
                'method' => $request->getMethod(),
                'uri' => (string) $request->getUri(),
                'headers' => $request->getHeaders(),
                'remote_addr' => $request->getServerParams()['REMOTE_ADDR'] ?? 'unknown',
            ],
            'timestamp' => date('c'),
        ];

        if ($this->logger) {
            // Use configured logger
            $this->logger->error('Application error', $logData);
        } else {
            // Fallback to error log
            error_log('Application error: ' . json_encode($logData));
        }
    }
}
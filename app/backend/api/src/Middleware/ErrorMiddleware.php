<?php

declare(strict_types=1);

namespace App\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Psr\Http\Message\ResponseInterface as Response;
use Throwable;
use App\Utils\ResponseHelper;

class ErrorMiddleware
{
    private ResponseHelper $responseHelper;

    public function __construct(ResponseHelper $responseHelper)
    {
        $this->responseHelper = $responseHelper;
    }

    public function __invoke(Request $request, RequestHandler $handler): Response
    {
        try {
            return $handler->handle($request);
        } catch (Throwable $e) {
            // Log the error (in production, use proper logging)
            error_log('API Error: ' . $e->getMessage() . ' in ' . $e->getFile() . ':' . $e->getLine());

            // Don't expose internal errors in production
            $isDevelopment = $_ENV['APP_ENV'] === 'development' ?? false;

            $errorMessage = $isDevelopment ? $e->getMessage() : 'Internal server error';
            $errorData = [];

            if ($isDevelopment) {
                $errorData = [
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'trace' => $e->getTraceAsString()
                ];
            }

            return $this->responseHelper->errorResponse(
                new \Slim\Psr7\Response(),
                $errorMessage,
                500,
                $errorData
            );
        }
    }
}
<?php

declare(strict_types=1);

namespace App\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Psr\Http\Message\ResponseInterface as Response;

class ValidationMiddleware
{
    public function __invoke(Request $request, RequestHandler $handler): Response
    {
        $contentType = $request->getHeaderLine('Content-Type');

        // Check Content-Type for POST/PUT requests
        if (in_array($request->getMethod(), ['POST', 'PUT', 'PATCH'])) {
            if (empty($contentType) || !str_contains($contentType, 'application/json')) {
                $response = new \Slim\Psr7\Response();
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'Content-Type must be application/json',
                    'errors' => ['content_type' => 'Invalid content type']
                ]));
                return $response
                    ->withHeader('Content-Type', 'application/json')
                    ->withStatus(400);
            }

            // Validate JSON body
            $body = $request->getBody()->getContents();
            if (!empty($body)) {
                $decoded = json_decode($body, true);
                if (json_last_error() !== JSON_ERROR_NONE) {
                    $response = new \Slim\Psr7\Response();
                    $response->getBody()->write(json_encode([
                        'success' => false,
                        'message' => 'Invalid JSON in request body',
                        'errors' => ['json' => json_last_error_msg()]
                    ]));
                    return $response
                        ->withHeader('Content-Type', 'application/json')
                        ->withStatus(400);
                }

                // Reconstruct the request with parsed body
                $request = $request->withParsedBody($decoded);
            }
        }

        return $handler->handle($request);
    }
}
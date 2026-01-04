<?php

declare(strict_types=1);

namespace HealthApp\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;

class CorsMiddleware implements MiddlewareInterface
{
    private array $config;

    public function __construct(array $config = [])
    {
        $this->config = array_merge([
            'allowed_origins' => ['*'],
            'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
            'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
            'max_age' => 86400, // 24 hours
            'allow_credentials' => false,
        ], $config);
    }

    public function process(Request $request, RequestHandler $handler): Response
    {
        $response = $handler->handle($request);

        // Handle preflight OPTIONS requests
        if ($request->getMethod() === 'OPTIONS') {
            $response = $this->handlePreflightRequest($request, $response);
        } else {
            // Add CORS headers to actual requests
            $response = $this->addCorsHeaders($request, $response);
        }

        return $response;
    }

    private function handlePreflightRequest(Request $request, Response $response): Response
    {
        $response = $response->withStatus(200);

        return $this->addCorsHeaders($request, $response)
            ->withHeader('Access-Control-Allow-Methods', implode(', ', $this->config['allowed_methods']))
            ->withHeader('Access-Control-Allow-Headers', implode(', ', $this->config['allowed_headers']))
            ->withHeader('Access-Control-Max-Age', (string) $this->config['max_age']);
    }

    private function addCorsHeaders(Request $request, Response $response): Response
    {
        $origin = $request->getHeaderLine('Origin');

        // Check if origin is allowed
        $allowedOrigin = $this->isOriginAllowed($origin);

        $response = $response->withHeader('Access-Control-Allow-Origin', $allowedOrigin);

        if ($this->config['allow_credentials']) {
            $response = $response->withHeader('Access-Control-Allow-Credentials', 'true');
        }

        return $response;
    }

    private function isOriginAllowed(string $origin): string
    {
        if (in_array('*', $this->config['allowed_origins'])) {
            return '*';
        }

        if (in_array($origin, $this->config['allowed_origins'])) {
            return $origin;
        }

        // Return first allowed origin as fallback (not ideal but prevents errors)
        return $this->config['allowed_origins'][0] ?? '*';
    }
}
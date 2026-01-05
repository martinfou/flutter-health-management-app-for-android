<?php

declare(strict_types=1);

namespace App\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Psr\Http\Message\ResponseInterface as Response;

class RateLimitMiddleware
{
    private array $requests = [];
    private int $maxRequests = 100; // requests per window
    private int $windowSeconds = 60; // 1 minute window

    public function __invoke(Request $request, RequestHandler $handler): Response
    {
        $clientId = $this->getClientIdentifier($request);

        // Clean old requests
        $this->cleanOldRequests($clientId);

        // Check rate limit
        if ($this->isRateLimited($clientId)) {
            $response = new \Slim\Psr7\Response();
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Rate limit exceeded. Please try again later.',
                'retry_after' => $this->windowSeconds
            ]));
            return $response
                ->withHeader('Content-Type', 'application/json')
                ->withHeader('Retry-After', (string)$this->windowSeconds)
                ->withStatus(429);
        }

        // Record this request
        $this->recordRequest($clientId);

        return $handler->handle($request);
    }

    private function getClientIdentifier(Request $request): string
    {
        // Use IP address as client identifier
        $serverParams = $request->getServerParams();
        return $serverParams['REMOTE_ADDR'] ?? 'unknown';
    }

    private function cleanOldRequests(string $clientId): void
    {
        if (!isset($this->requests[$clientId])) {
            return;
        }

        $cutoff = time() - $this->windowSeconds;
        $this->requests[$clientId] = array_filter(
            $this->requests[$clientId],
            fn($timestamp) => $timestamp > $cutoff
        );
    }

    private function isRateLimited(string $clientId): bool
    {
        return isset($this->requests[$clientId]) && count($this->requests[$clientId]) >= $this->maxRequests;
    }

    private function recordRequest(string $clientId): void
    {
        if (!isset($this->requests[$clientId])) {
            $this->requests[$clientId] = [];
        }
        $this->requests[$clientId][] = time();
    }
}
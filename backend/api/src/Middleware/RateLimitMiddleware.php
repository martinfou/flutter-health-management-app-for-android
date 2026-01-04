<?php

declare(strict_types=1);

namespace HealthApp\Middleware;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;

class RateLimitMiddleware implements MiddlewareInterface
{
    private DatabaseService $db;
    private array $config;

    public function __construct(DatabaseService $db, array $config = [])
    {
        $this->db = $db;
        $this->config = array_merge([
            'requests_per_minute' => 100,
            'auth_requests_per_minute' => 5,
            'window_seconds' => 60,
            'block_duration_seconds' => 300, // 5 minutes
        ], $config);
    }

    public function process(Request $request, RequestHandler $handler): Response
    {
        $clientIp = $this->getClientIp($request);
        $route = $request->getUri()->getPath();
        $method = $request->getMethod();

        // Determine rate limit based on route
        $isAuthRoute = $this->isAuthRoute($route);
        $limit = $isAuthRoute ? $this->config['auth_requests_per_minute'] : $this->config['requests_per_minute'];

        // Check if client is currently blocked
        if ($this->isBlocked($clientIp)) {
            return ResponseHelper::rateLimitExceeded(
                new \Slim\Psr7\Response(),
                'Rate limit exceeded. Try again later.'
            );
        }

        // Check current request count
        $currentCount = $this->getRequestCount($clientIp);

        if ($currentCount >= $limit) {
            // Block the client
            $this->blockClient($clientIp);
            return ResponseHelper::rateLimitExceeded(
                new \Slim\Psr7\Response(),
                'Rate limit exceeded. Try again later.'
            );
        }

        // Record the request
        $this->recordRequest($clientIp, $route, $method);

        // Add rate limit headers to response
        $response = $handler->handle($request);
        $remaining = max(0, $limit - $currentCount - 1);

        return $response
            ->withHeader('X-RateLimit-Limit', (string) $limit)
            ->withHeader('X-RateLimit-Remaining', (string) $remaining)
            ->withHeader('X-RateLimit-Reset', (string) (time() + $this->config['window_seconds']));
    }

    private function getClientIp(Request $request): string
    {
        // Check for forwarded IP first (load balancer/proxy)
        $forwarded = $request->getHeaderLine('X-Forwarded-For');
        if (!empty($forwarded)) {
            $ips = explode(',', $forwarded);
            return trim($ips[0]);
        }

        // Check for real IP
        $realIp = $request->getHeaderLine('X-Real-IP');
        if (!empty($realIp)) {
            return $realIp;
        }

        // Fall back to REMOTE_ADDR
        return $request->getServerParams()['REMOTE_ADDR'] ?? '127.0.0.1';
    }

    private function isAuthRoute(string $route): bool
    {
        $authRoutes = [
            '/api/v1/auth/login',
            '/api/v1/auth/register',
            '/api/v1/auth/refresh',
            '/api/v1/auth/verify-google',
        ];

        return in_array($route, $authRoutes);
    }

    private function isBlocked(string $clientIp): bool
    {
        try {
            $result = $this->db->select(
                "SELECT blocked_until FROM rate_limit_blocks WHERE client_ip = ? AND blocked_until > NOW()",
                [$clientIp]
            );

            return !empty($result);
        } catch (\Exception $e) {
            // If database error, allow request to prevent blocking legitimate users
            return false;
        }
    }

    private function getRequestCount(string $clientIp): int
    {
        try {
            $windowStart = date('Y-m-d H:i:s', time() - $this->config['window_seconds']);

            $result = $this->db->select(
                "SELECT COUNT(*) as count FROM rate_limit_requests WHERE client_ip = ? AND created_at >= ?",
                [$clientIp, $windowStart]
            );

            return (int) ($result[0]['count'] ?? 0);
        } catch (\Exception $e) {
            // If database error, allow request but don't track
            return 0;
        }
    }

    private function recordRequest(string $clientIp, string $route, string $method): void
    {
        try {
            $this->db->execute(
                "INSERT INTO rate_limit_requests (client_ip, route, method, created_at) VALUES (?, ?, ?, NOW())",
                [$clientIp, $route, $method]
            );
        } catch (\Exception $e) {
            // If database error, don't block the request
        }
    }

    private function blockClient(string $clientIp): void
    {
        try {
            $blockedUntil = date('Y-m-d H:i:s', time() + $this->config['block_duration_seconds']);

            $this->db->execute(
                "INSERT INTO rate_limit_blocks (client_ip, blocked_until, created_at)
                 VALUES (?, ?, NOW())
                 ON DUPLICATE KEY UPDATE blocked_until = VALUES(blocked_until)",
                [$clientIp, $blockedUntil]
            );
        } catch (\Exception $e) {
            // If database error, don't worry - client will be rate limited by count anyway
        }
    }
}
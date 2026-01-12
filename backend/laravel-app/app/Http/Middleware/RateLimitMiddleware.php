<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Helpers\ResponseHelper;

class RateLimitMiddleware
{
    // Rate limit configuration
    private $generalLimit = 100;      // requests per minute
    private $authLimit = 5;            // requests per minute for auth routes
    private $windowSeconds = 60;
    private $blockDurationSeconds = 300;  // 5 minutes

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        $clientIp = $this->getClientIp($request);
        $route = $request->path();
        $method = $request->getMethod();

        // Determine rate limit based on route
        $isAuthRoute = $this->isAuthRoute($route);
        $limit = $isAuthRoute ? $this->authLimit : $this->generalLimit;

        // Check if client is blocked
        if ($this->isBlocked($clientIp)) {
            return ResponseHelper::rateLimitExceeded('Rate limit exceeded. Try again later.');
        }

        // Check current request count
        $currentCount = $this->getRequestCount($clientIp);

        if ($currentCount >= $limit) {
            // Block the client
            $this->blockClient($clientIp);
            return ResponseHelper::rateLimitExceeded('Rate limit exceeded. Try again later.');
        }

        // Record the request
        $this->recordRequest($clientIp, $route, $method);

        // Process the request
        $response = $next($request);

        // Add rate limit headers
        $remaining = max(0, $limit - $currentCount - 1);
        $resetTime = time() + $this->windowSeconds;

        return $response
            ->header('X-RateLimit-Limit', (string) $limit)
            ->header('X-RateLimit-Remaining', (string) $remaining)
            ->header('X-RateLimit-Reset', (string) $resetTime);
    }

    /**
     * Get client IP address
     */
    private function getClientIp(Request $request): string
    {
        // Check for forwarded IP first (load balancer/proxy)
        $forwarded = $request->header('X-Forwarded-For');
        if (!empty($forwarded)) {
            $ips = explode(',', $forwarded);
            return trim($ips[0]);
        }

        // Check for real IP
        $realIp = $request->header('X-Real-IP');
        if (!empty($realIp)) {
            return $realIp;
        }

        // Fall back to client IP
        return $request->ip() ?? '127.0.0.1';
    }

    /**
     * Check if route is auth route
     */
    private function isAuthRoute(string $route): bool
    {
        $authRoutes = [
            'api/v1/auth/login',
            'api/v1/auth/register',
            'api/v1/auth/refresh',
            'api/v1/auth/verify-google',
        ];

        return in_array($route, $authRoutes);
    }

    /**
     * Check if client is currently blocked
     */
    private function isBlocked(string $clientIp): bool
    {
        try {
            $result = DB::table('rate_limit_blocks')
                ->where('client_ip', $clientIp)
                ->where('blocked_until', '>', now())
                ->exists();

            return $result;
        } catch (\Exception $e) {
            // If database error, allow request to prevent blocking legitimate users
            return false;
        }
    }

    /**
     * Get request count for client in current window
     */
    private function getRequestCount(string $clientIp): int
    {
        try {
            $windowStart = now()->subSeconds($this->windowSeconds);

            $count = DB::table('rate_limit_requests')
                ->where('client_ip', $clientIp)
                ->where('created_at', '>=', $windowStart)
                ->count();

            return $count;
        } catch (\Exception $e) {
            // If database error, allow request but don't track
            return 0;
        }
    }

    /**
     * Record a request
     */
    private function recordRequest(string $clientIp, string $route, string $method): void
    {
        try {
            DB::table('rate_limit_requests')->insert([
                'client_ip' => $clientIp,
                'route' => $route,
                'method' => $method,
                'created_at' => now(),
            ]);
        } catch (\Exception $e) {
            // If database error, don't block the request
        }
    }

    /**
     * Block a client
     */
    private function blockClient(string $clientIp): void
    {
        try {
            $blockedUntil = now()->addSeconds($this->blockDurationSeconds);

            DB::table('rate_limit_blocks')->updateOrInsert(
                ['client_ip' => $clientIp],
                [
                    'blocked_until' => $blockedUntil,
                    'created_at' => now(),
                ]
            );
        } catch (\Exception $e) {
            // If database error, don't worry
        }
    }
}

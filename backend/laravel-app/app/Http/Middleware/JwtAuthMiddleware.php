<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Services\JwtService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class JwtAuthMiddleware
{
    private JwtService $jwtService;

    public function __construct(JwtService $jwtService)
    {
        $this->jwtService = $jwtService;
    }

    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $authHeader = $request->header('Authorization');

        if (!$authHeader) {
            return response()->json([
                'success' => false,
                'message' => 'Authorization header missing',
                'timestamp' => now()->toIso8601String(),
            ], 401);
        }

        if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid authorization header format',
                'timestamp' => now()->toIso8601String(),
            ], 401);
        }

        $token = $matches[1];

        try {
            $payload = $this->jwtService->validateAccessToken($token);
            $userId = $this->jwtService->getUserIdFromToken($payload);

            $user = User::where('id', $userId)->whereNull('deleted_at')->first();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not found or account deactivated',
                    'timestamp' => now()->toIso8601String(),
                ], 401);
            }

            // Add user to request for controllers to access via $request->user
            // Using setUserResolver allows both $request->user() and auth()->user() to work
            $request->setUserResolver(function () use ($user) {
                return $user;
            });

            // Also add to attributes for direct access
            $request->attributes->set('user', $user);
            $request->attributes->set('user_id', $userId);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired token',
                'timestamp' => now()->toIso8601String(),
            ], 401);
        }

        return $next($request);
    }
}

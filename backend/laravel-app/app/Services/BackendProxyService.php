<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;

class BackendProxyService
{
    /**
     * Get the currently active backend
     * Since Slim API is removed, always returns 'laravel'
     */
    public static function getActiveBackend(): string
    {
        return 'laravel';
    }

    /**
     * Route API request - now only routes to Laravel
     * This method is kept for compatibility but Laravel handles routing directly
     */
    public function routeApiRequest($request)
    {
        Log::info("BackendProxy: All requests routed to Laravel backend", [
            'method' => $request->method(),
            'path' => $request->path(),
        ]);

        // Laravel handles its own routing, so this shouldn't be called
        // But if called, we'll indicate Laravel is active
        return response()->json([
            'success' => true,
            'message' => 'Laravel backend is active',
            'timestamp' => now()->toISOString()
        ], 200);
    }

    /**
     * Get backend status information
     * Slim API is no longer available
     */
    public static function getBackendStatus(): array
    {
        return [
            'active_backend' => 'laravel',
            'slim_available' => false,
            'laravel_available' => true,
            'can_switch_to_slim' => false,
            'migration_complete' => true,
            'timestamp' => now()->toISOString()
        ];
    }
}
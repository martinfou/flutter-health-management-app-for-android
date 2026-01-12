<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CorsMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        // Get allowed origins from config
        $allowedOrigins = explode(',', env('CORS_ALLOWED_ORIGINS', '*'));
        $origin = $request->header('Origin');

        // Check if origin is allowed
        $originAllowed = in_array('*', $allowedOrigins) || in_array($origin, $allowedOrigins);

        // Handle preflight OPTIONS requests
        if ($request->isMethod('OPTIONS')) {
            return $this->handlePreflightRequest($request, $originAllowed, $origin);
        }

        // Process the request
        $response = $next($request);

        // Add CORS headers to response
        if ($originAllowed && $origin) {
            // Note: Cannot use '*' with credentials=true, must be explicit origin
            $response->header('Access-Control-Allow-Origin', $origin);
            $response->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
            $response->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
            $response->header('Access-Control-Allow-Credentials', 'true');
            $response->header('Access-Control-Max-Age', '86400');
        }

        return $response;
    }

    /**
     * Handle preflight CORS request
     */
    private function handlePreflightRequest(Request $request, $originAllowed, $origin)
    {
        if (!$originAllowed) {
            return response('', 403);
        }

        return response('', 200)
            ->header('Access-Control-Allow-Origin', $origin ?: '*')
            ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH')
            ->header('Access-Control-Allow-Headers', $request->header('Access-Control-Request-Headers') ?: 'Content-Type, Authorization')
            ->header('Access-Control-Allow-Credentials', 'true')
            ->header('Access-Control-Max-Age', '86400');
    }
}

<?php

namespace App\Http\Middleware;

use App\Services\BackendProxyService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class BackendToggleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $activeBackend = BackendProxyService::getActiveBackend();

        // If Laravel is active, proceed normally
        if ($activeBackend === 'laravel') {
            return $next($request);
        }

        // If Slim is active, proxy the request
        if ($activeBackend === 'slim') {
            $proxyService = new BackendProxyService();
            return $proxyService->routeApiRequest($request);
        }

        // Fallback to Laravel if backend setting is invalid
        return $next($request);
    }
}
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HealthMetricsController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| API v1 routes for Health Management App
| Matches the Slim API structure for Flutter app compatibility
|
*/

Route::prefix('v1')->group(function () {

    // API Info
    Route::get('/', function () {
        return response()->json([
            'success' => true,
            'message' => 'API information retrieved',
            'data' => [
                'name' => 'Health Management App API',
                'version' => '1.0.0',
                'status' => 'development',
            ],
            'timestamp' => now()->toIso8601String(),
        ]);
    });

    // Public Authentication Routes (no auth required)
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
        Route::post('/verify-google', [AuthController::class, 'verifyGoogle']);
    });

    // Protected Routes (require JWT authentication)
    Route::middleware('jwt.auth')->group(function () {

        // Auth & User Profile
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/user/profile', [AuthController::class, 'getProfile']);
        Route::put('/user/profile', [AuthController::class, 'updateProfile']);
        Route::delete('/user/account', [AuthController::class, 'deleteAccount']);

        // Health Metrics
        Route::get('/health-metrics', [HealthMetricsController::class, 'index']);
        Route::post('/health-metrics', [HealthMetricsController::class, 'store']);
        Route::get('/health-metrics/{id}', [HealthMetricsController::class, 'show']);
        Route::put('/health-metrics/{id}', [HealthMetricsController::class, 'update']);
        Route::delete('/health-metrics/{id}', [HealthMetricsController::class, 'destroy']);
        Route::post('/health-metrics/sync', [HealthMetricsController::class, 'sync']);

        // TODO: Add additional endpoints for meals, exercises, medications, meal plans
        // These will be implemented as the Flutter app needs them
    });
});

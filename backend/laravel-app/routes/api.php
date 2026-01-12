<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HealthMetricsController;
use App\Http\Controllers\Api\MealsController;
use App\Http\Controllers\Api\ExercisesController;
use App\Http\Controllers\Api\MedicationsController;
use App\Http\Controllers\Api\MealPlansController;
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

        // Meals
        Route::get('/meals', [MealsController::class, 'index']);
        Route::post('/meals', [MealsController::class, 'store']);
        Route::get('/meals/{id}', [MealsController::class, 'show']);
        Route::put('/meals/{id}', [MealsController::class, 'update']);
        Route::delete('/meals/{id}', [MealsController::class, 'destroy']);
        Route::post('/meals/sync', [MealsController::class, 'sync']);

        // Exercises
        Route::get('/exercises', [ExercisesController::class, 'index']);
        Route::post('/exercises', [ExercisesController::class, 'store']);
        Route::get('/exercises/{id}', [ExercisesController::class, 'show']);
        Route::put('/exercises/{id}', [ExercisesController::class, 'update']);
        Route::delete('/exercises/{id}', [ExercisesController::class, 'destroy']);
        Route::post('/exercises/sync', [ExercisesController::class, 'sync']);

        // Medications
        Route::get('/medications', [MedicationsController::class, 'index']);
        Route::post('/medications', [MedicationsController::class, 'store']);
        Route::get('/medications/{id}', [MedicationsController::class, 'show']);
        Route::put('/medications/{id}', [MedicationsController::class, 'update']);
        Route::delete('/medications/{id}', [MedicationsController::class, 'destroy']);
        Route::post('/medications/sync', [MedicationsController::class, 'sync']);

        // Meal Plans
        Route::get('/meal-plans', [MealPlansController::class, 'index']);
        Route::post('/meal-plans', [MealPlansController::class, 'store']);
        Route::get('/meal-plans/{id}', [MealPlansController::class, 'show']);
        Route::put('/meal-plans/{id}', [MealPlansController::class, 'update']);
        Route::delete('/meal-plans/{id}', [MealPlansController::class, 'destroy']);
        Route::post('/meal-plans/sync', [MealPlansController::class, 'sync']);
    });
});

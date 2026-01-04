<?php

declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';

use Dotenv\Dotenv;
use HealthApp\Middleware\AuthMiddleware;
use HealthApp\Middleware\CorsMiddleware;
use HealthApp\Middleware\ErrorMiddleware;
use HealthApp\Middleware\RateLimitMiddleware;
use Slim\Factory\AppFactory;
use Slim\Routing\RouteCollectorProxy;

// Load environment variables
$dotenv = Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

// Create Slim app
$app = AppFactory::create();

// Add middleware
$app->add(new ErrorMiddleware());
$app->add(new CorsMiddleware());
$app->add(new RateLimitMiddleware());

// Add routes
$app->group('/api/v1', function (RouteCollectorProxy $group) {
    // Health check
    $group->get('/health', \HealthApp\Controllers\HealthController::class . ':check');

    // Authentication routes (no auth required)
    $group->post('/auth/register', \HealthApp\Controllers\AuthController::class . ':register');
    $group->post('/auth/login', \HealthApp\Controllers\AuthController::class . ':login');
    $group->post('/auth/refresh', \HealthApp\Controllers\AuthController::class . ':refresh');
    $group->post('/auth/verify-google', \HealthApp\Controllers\AuthController::class . ':verifyGoogle');

    // Protected routes (require authentication)
    $group->group('', function (RouteCollectorProxy $protected) {
        $protected->add(new AuthMiddleware());

        // User profile
        $protected->get('/auth/profile', \HealthApp\Controllers\AuthController::class . ':getProfile');
        $protected->put('/auth/profile', \HealthApp\Controllers\AuthController::class . ':updateProfile');
        $protected->delete('/auth/account', \HealthApp\Controllers\AuthController::class . ':deleteAccount');
        $protected->post('/auth/logout', \HealthApp\Controllers\AuthController::class . ':logout');

        // Health metrics
        $protected->get('/health-metrics', \HealthApp\Controllers\HealthMetricsController::class . ':getAll');
        $protected->post('/health-metrics', \HealthApp\Controllers\HealthMetricsController::class . ':create');
        $protected->get('/health-metrics/{id}', \HealthApp\Controllers\HealthMetricsController::class . ':getById');
        $protected->put('/health-metrics/{id}', \HealthApp\Controllers\HealthMetricsController::class . ':update');
        $protected->delete('/health-metrics/{id}', \HealthApp\Controllers\HealthMetricsController::class . ':delete');
        $protected->post('/health-metrics/sync', \HealthApp\Controllers\HealthMetricsController::class . ':sync');

        // Medications
        $protected->get('/medications', \HealthApp\Controllers\MedicationsController::class . ':getAll');
        $protected->post('/medications', \HealthApp\Controllers\MedicationsController::class . ':create');
        $protected->get('/medications/{id}', \HealthApp\Controllers\MedicationsController::class . ':getById');
        $protected->put('/medications/{id}', \HealthApp\Controllers\MedicationsController::class . ':update');
        $protected->delete('/medications/{id}', \HealthApp\Controllers\MedicationsController::class . ':delete');
        $protected->post('/medications/sync', \HealthApp\Controllers\MedicationsController::class . ':sync');

        // Meals
        $protected->get('/meals', \HealthApp\Controllers\MealsController::class . ':getAll');
        $protected->post('/meals', \HealthApp\Controllers\MealsController::class . ':create');
        $protected->get('/meals/{id}', \HealthApp\Controllers\MealsController::class . ':getById');
        $protected->put('/meals/{id}', \HealthApp\Controllers\MealsController::class . ':update');
        $protected->delete('/meals/{id}', \HealthApp\Controllers\MealsController::class . ':delete');
        $protected->post('/meals/sync', \HealthApp\Controllers\MealsController::class . ':sync');

        // Exercises
        $protected->get('/exercises', \HealthApp\Controllers\ExercisesController::class . ':getAll');
        $protected->post('/exercises', \HealthApp\Controllers\ExercisesController::class . ':create');
        $protected->get('/exercises/{id}', \HealthApp\Controllers\ExercisesController::class . ':getById');
        $protected->put('/exercises/{id}', \HealthApp\Controllers\ExercisesController::class . ':update');
        $protected->delete('/exercises/{id}', \HealthApp\Controllers\ExercisesController::class . ':delete');
        $protected->post('/exercises/sync', \HealthApp\Controllers\ExercisesController::class . ':sync');

        // Meal Plans
        $protected->get('/meal-plans', \HealthApp\Controllers\MealPlansController::class . ':getAll');
        $protected->post('/meal-plans', \HealthApp\Controllers\MealPlansController::class . ':create');
        $protected->get('/meal-plans/{id}', \HealthApp\Controllers\MealPlansController::class . ':getById');
        $protected->put('/meal-plans/{id}', \HealthApp\Controllers\MealPlansController::class . ':update');
        $protected->delete('/meal-plans/{id}', \HealthApp\Controllers\MealPlansController::class . ':delete');
        $protected->post('/meal-plans/sync', \HealthApp\Controllers\MealPlansController::class . ':sync');

        // Sync
        $protected->post('/sync/bulk', \HealthApp\Controllers\SyncController::class . ':bulkSync');
        $protected->get('/sync/status', \HealthApp\Controllers\SyncController::class . ':getStatus');
        $protected->post('/sync/resolve-conflicts', \HealthApp\Controllers\SyncController::class . ':resolveConflicts');
    });
});

// Run app
$app->run();
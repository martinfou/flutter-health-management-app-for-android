<?php

declare(strict_types=1);

// Load Composer autoloader FIRST
require __DIR__ . '/../vendor/autoload.php';

use DI\Container;
use Slim\Factory\AppFactory;
use Slim\Routing\RouteCollectorProxy;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// Load environment variables
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../');
$dotenv->load();

// Create Container
$container = new Container();

// Set up database service
$container->set('db', function () {
    $dsn = $_ENV['DB_CONNECTION'] === 'sqlite'
        ? "sqlite:{$_ENV['DB_DATABASE']}"
        : "mysql:host={$_ENV['DB_HOST']};dbname={$_ENV['DB_DATABASE']};charset=utf8mb4";

    return new App\Services\DatabaseService(
        $dsn,
        $_ENV['DB_CONNECTION'] === 'mysql' ? $_ENV['DB_USERNAME'] : null,
        $_ENV['DB_CONNECTION'] === 'mysql' ? $_ENV['DB_PASSWORD'] : null
    );
});

// Set up response helper
$container->set('responseHelper', function () {
    return new App\Utils\ResponseHelper();
});

// Set up JWT helper
$container->set('jwtHelper', function () {
    return new App\Utils\JwtHelper($_ENV['JWT_SECRET']);
});

// Set up controllers
$container->set('AuthController', function ($container) {
    return new App\Controllers\AuthController(
        $container->get('db'),
        $container->get('responseHelper'),
        $container->get('jwtHelper')
    );
});

$container->set('HealthMetricsController', function ($container) {
    return new App\Controllers\HealthMetricsController(
        $container->get('db'),
        $container->get('responseHelper')
    );
});

$container->set('MedicationsController', function ($container) {
    return new App\Controllers\MedicationsController(
        $container->get('db'),
        $container->get('responseHelper')
    );
});

$container->set('MealsController', function ($container) {
    return new App\Controllers\MealsController(
        $container->get('db'),
        $container->get('responseHelper')
    );
});

$container->set('ExercisesController', function ($container) {
    return new App\Controllers\ExercisesController(
        $container->get('db'),
        $container->get('responseHelper')
    );
});

$container->set('MealPlansController', function ($container) {
    return new App\Controllers\MealPlansController(
        $container->get('db'),
        $container->get('responseHelper')
    );
});

// Create App
AppFactory::setContainer($container);
$app = AppFactory::create();

// Add middleware
$app->add(new App\Middleware\CorsMiddleware());
$app->add(new App\Middleware\RateLimitMiddleware());
$app->add(new App\Middleware\ValidationMiddleware());
$app->add(new App\Middleware\ErrorMiddleware($container->get('responseHelper')));

// Routes
$app->get('/', function (Request $request, Response $response) {
    $response->getBody()->write(json_encode([
        'name' => 'Health Management API',
        'version' => '1.0.0',
        'status' => 'running',
        'endpoints' => [
            'GET /api/v1/' => 'API information',
            'GET /api/v1/health' => 'Health check',
            'POST /api/v1/auth/register' => 'User registration',
            'POST /api/v1/auth/login' => 'User authentication',
            'POST /api/v1/auth/refresh' => 'Token refresh',
            'GET /api/v1/health-metrics' => 'List health metrics',
            'POST /api/v1/health-metrics' => 'Create health metric',
            'GET /api/v1/medications' => 'List medications',
            'POST /api/v1/medications' => 'Create medication',
            'GET /api/v1/meals' => 'List meals',
            'POST /api/v1/meals' => 'Log meal',
            'GET /api/v1/exercises' => 'List exercises',
            'POST /api/v1/exercises' => 'Log exercise',
            'GET /api/v1/meal-plans' => 'List meal plans',
            'POST /api/v1/meal-plans' => 'Create meal plan',
        ]
    ]));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->get('/api/v1/', function (Request $request, Response $response) {
    $response->getBody()->write(json_encode([
        'success' => true,
        'message' => 'Health Management API v1.0.0',
        'documentation' => '/docs',
        'health_check' => '/api/v1/health'
    ]));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->get('/api/v1/health', function (Request $request, Response $response) use ($container) {
    try {
        $db = $container->get('db');
        $db->getConnection()->query('SELECT 1');

        $response->getBody()->write(json_encode([
            'success' => true,
            'status' => 'healthy',
            'timestamp' => date('c'),
            'database' => 'connected',
            'version' => '1.0.0'
        ]));
    } catch (Exception $e) {
        $response->getBody()->write(json_encode([
            'success' => false,
            'status' => 'unhealthy',
            'error' => 'Database connection failed',
            'timestamp' => date('c')
        ]));
        $response = $response->withStatus(500);
    }

    return $response->withHeader('Content-Type', 'application/json');
});

// Auth routes (public)
$app->group('/api/v1/auth', function (RouteCollectorProxy $group) use ($container) {
    $authController = $container->get('AuthController');

    $group->post('/register', [$authController, 'register']);
    $group->post('/login', [$authController, 'login']);
    $group->post('/refresh', [$authController, 'refresh']);
});

// Protected routes (require authentication)
$app->group('/api/v1', function (RouteCollectorProxy $group) use ($container) {
    // Health Metrics
    $healthMetricsController = $container->get('HealthMetricsController');
    $group->get('/health-metrics', [$healthMetricsController, 'index']);
    $group->post('/health-metrics', [$healthMetricsController, 'create']);
    $group->get('/health-metrics/{id}', [$healthMetricsController, 'show']);
    $group->put('/health-metrics/{id}', [$healthMetricsController, 'update']);
    $group->delete('/health-metrics/{id}', [$healthMetricsController, 'delete']);

    // Medications
    $medicationsController = $container->get('MedicationsController');
    $group->get('/medications', [$medicationsController, 'index']);
    $group->post('/medications', [$medicationsController, 'create']);
    $group->get('/medications/reminders', [$medicationsController, 'getReminders']);
    $group->get('/medications/{id}', [$medicationsController, 'show']);
    $group->put('/medications/{id}', [$medicationsController, 'update']);
    $group->delete('/medications/{id}', [$medicationsController, 'delete']);

    // Meals
    $mealsController = $container->get('MealsController');
    $group->get('/meals', [$mealsController, 'index']);
    $group->post('/meals', [$mealsController, 'create']);
    $group->get('/meals/summary/nutrition', [$mealsController, 'getNutritionSummary']);
    $group->get('/meals/suggestions', [$mealsController, 'getMealSuggestions']);
    $group->get('/meals/{id}', [$mealsController, 'show']);
    $group->put('/meals/{id}', [$mealsController, 'update']);
    $group->delete('/meals/{id}', [$mealsController, 'delete']);

    // Exercises
    $exercisesController = $container->get('ExercisesController');
    $group->get('/exercises', [$exercisesController, 'index']);
    $group->post('/exercises', [$exercisesController, 'create']);
    $group->get('/exercises/statistics', [$exercisesController, 'getStatistics']);
    $group->get('/exercises/suggestions', [$exercisesController, 'getExerciseSuggestions']);
    $group->get('/exercises/history/workouts', [$exercisesController, 'getWorkoutHistory']);
    $group->get('/exercises/{id}', [$exercisesController, 'show']);
    $group->put('/exercises/{id}', [$exercisesController, 'update']);
    $group->delete('/exercises/{id}', [$exercisesController, 'delete']);

    // Meal Plans
    $mealPlansController = $container->get('MealPlansController');
    $group->get('/meal-plans', [$mealPlansController, 'index']);
    $group->post('/meal-plans', [$mealPlansController, 'create']);
    $group->get('/meal-plans/meals/date', [$mealPlansController, 'getMealsForDate']);
    $group->post('/meal-plans/generate', [$mealPlansController, 'generateMealPlan']);
    $group->get('/meal-plans/{id}', [$mealPlansController, 'show']);
    $group->put('/meal-plans/{id}', [$mealPlansController, 'update']);
    $group->delete('/meal-plans/{id}', [$mealPlansController, 'delete']);

})->add(new App\Middleware\AuthMiddleware($container->get('jwtHelper'), $container->get('responseHelper')));

// Run app
$app->run();
<?php

declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';

use Dotenv\Dotenv;
use HealthApp\Middleware\AuthMiddleware;
use HealthApp\Middleware\CorsMiddleware;
use HealthApp\Middleware\ErrorMiddleware;
use HealthApp\Middleware\RateLimitMiddleware;
use HealthApp\Middleware\ValidationMiddleware;
use HealthApp\Services\DatabaseService;
use HealthApp\Utils\JwtHelper;
use Slim\Factory\AppFactory;
use Slim\Routing\RouteCollectorProxy;

// Load environment variables
$dotenv = Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

// Load configuration
$config = require __DIR__ . '/../config/app.php';
$dbConfig = require __DIR__ . '/../config/database.php';

// Create services
$db = new DatabaseService($dbConfig['database']);
$jwtHelper = new JwtHelper(
    $config['jwt']['secret'],
    $config['jwt']['algorithm'],
    $config['jwt']['access_token_ttl'],
    $config['jwt']['refresh_token_ttl']
);

// Create Slim app
$app = AppFactory::create();

// Create middleware instances
$authMiddleware = new AuthMiddleware($jwtHelper, $db);

// Add global middleware
$app->add(new ErrorMiddleware(
    $config['app']['debug'],
    $config['logging']['level'] !== 'NONE'
));
$app->add(new CorsMiddleware($config['cors']));
$app->add(new RateLimitMiddleware($db, $config['api']['rate_limit']));
$app->add(new ValidationMiddleware(
    ValidationMiddleware::createRules()
));

// Add routes
$app->group('/api/v1', function (RouteCollectorProxy $group) {
    // Health check
    $group->get('/health', \HealthApp\Controllers\HealthController::class . ':check');

    // API information
    $group->get('/', function ($request, $response) {
        return \HealthApp\Utils\ResponseHelper::success($response, [
            'name' => 'Health Management App API',
            'version' => '1.0.0',
            'status' => 'development',
            'endpoints' => [
                'health' => 'GET /api/v1/health',
                'auth' => [
                    'register' => 'POST /api/v1/auth/register',
                    'login' => 'POST /api/v1/auth/login',
                    'refresh' => 'POST /api/v1/auth/refresh',
                    'verify_google' => 'POST /api/v1/auth/verify-google'
                ],
                'health_metrics' => [
                    'list' => 'GET /api/v1/health-metrics',
                    'create' => 'POST /api/v1/health-metrics'
                ]
            ]
        ], 'API information retrieved');
    });

    // Authentication routes (no auth required)
    $group->post('/auth/register', \HealthApp\Controllers\AuthController::class . ':register');
    $group->post('/auth/login', \HealthApp\Controllers\AuthController::class . ':login');
    $group->post('/auth/refresh', \HealthApp\Controllers\AuthController::class . ':refresh');
    $group->post('/auth/verify-google', \HealthApp\Controllers\AuthController::class . ':verifyGoogle');

    // Health metrics (temporarily without auth for testing)
    $group->get('/health-metrics', \HealthApp\Controllers\HealthMetricsController::class . ':getAll');
    $group->post('/health-metrics', \HealthApp\Controllers\HealthMetricsController::class . ':create');
});

// Run app
$app->run();
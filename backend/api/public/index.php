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
use HealthApp\Services\EmailService;
use HealthApp\Utils\JwtHelper;
use Slim\Factory\AppFactory;
use Slim\Routing\RouteCollectorProxy;

// Load environment variables
$dotenv = Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

// Load configuration
$config = require __DIR__ . '/../config/app.php';
$dbConfig = require __DIR__ . '/../config/database.php';

// Create Slim app
$app = AppFactory::create();

// Set up dependency injection in Slim's container
$container = $app->getContainer();

// Register services
$container['db'] = function() use ($dbConfig) {
    return new DatabaseService($dbConfig['database']);
};

$container['jwt'] = function() use ($config) {
    return new JwtHelper(
        $config['jwt']['secret'],
        $config['jwt']['algorithm'],
        $config['jwt']['access_token_ttl'],
        $config['jwt']['refresh_token_ttl']
    );
};

// Register controllers
$container['HealthApp\\Controllers\\HealthController'] = function($container) {
    return new \HealthApp\Controllers\HealthController($container['db']);
};

$container['HealthApp\\Controllers\\AuthController'] = function($container) use ($config) {
    return new \HealthApp\Controllers\AuthController(
        $container['db'](),
        $container['jwt'](),
        $config['google_oauth'] ?? [],
        $config['email'] ?? []
    );
};

$container['HealthApp\\Controllers\\HealthMetricsController'] = function($container) {
    return new \HealthApp\Controllers\HealthMetricsController($container['db']);
};

// Create middleware instances (will be used when we add protected routes)
$authMiddlewareFactory = function($container) {
    return new AuthMiddleware($container['jwt'], $container['db']);
};

// Add global middleware
$app->add(new ErrorMiddleware(
    $config['app']['debug'],
    $config['logging']['level'] !== 'NONE'
));
$app->add(new CorsMiddleware($config['cors']));
$app->add(new RateLimitMiddleware($container['db'](), $config['api']['rate_limit']));
$app->add(new ValidationMiddleware(
    ValidationMiddleware::createRules()
));

// Instantiate services
$emailService = new EmailService($config['email']);

// Instantiate controllers with dependencies
$healthController = new \HealthApp\Controllers\HealthController($container['db']());
$authController = new \HealthApp\Controllers\AuthController(
    $container['db'](),
    $container['jwt'](),
    $config['google_oauth'] ?? [],
    $emailService
);
$healthMetricsController = new \HealthApp\Controllers\HealthMetricsController($container['db']());

// Add routes
$app->group('/api/v1', function (RouteCollectorProxy $group) use ($healthController, $authController, $healthMetricsController, $container) {
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

    // Health check
    $group->get('/health', [$healthController, 'check']);

    // Authentication routes (no auth required)
    $group->post('/auth/register', [$authController, 'register']);
    $group->post('/auth/login', [$authController, 'login']);
    $group->post('/auth/refresh', [$authController, 'refresh']);
    $group->post('/auth/verify-google', [$authController, 'verifyGoogle']);

    // Password reset routes (no auth required)
    $group->post('/auth/password-reset/request', [$authController, 'requestPasswordReset']);
    $group->post('/auth/password-reset/verify', [$authController, 'verifyPasswordReset']);

    // Health metrics (temporarily without auth for testing)
    $group->get('/health-metrics', [$healthMetricsController, 'getAll']);
    $group->post('/health-metrics', [$healthMetricsController, 'create']);

    // Protected routes (require authentication)
    $authMiddleware = new AuthMiddleware($container['jwt'](), $container['db']());
    $group->group('', function (RouteCollectorProxy $group) use ($authController, $authMiddleware) {
        $group->get('/user/profile', [$authController, 'getProfile'])
               ->add($authMiddleware);
        $group->put('/user/profile', [$authController, 'updateProfile'])
               ->add($authMiddleware);
        $group->delete('/user/account', [$authController, 'deleteAccount'])
               ->add($authMiddleware);
        $group->post('/auth/logout', [$authController, 'logout'])
               ->add($authMiddleware);
    });
});

// Run app
$app->run();

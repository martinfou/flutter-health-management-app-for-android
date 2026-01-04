<?php

declare(strict_types=1);

return [
    'app' => [
        'name' => 'Health App Backend',
        'version' => '1.0.0',
        'environment' => $_ENV['APP_ENV'] ?? 'production',
        'debug' => filter_var($_ENV['APP_DEBUG'] ?? false, FILTER_VALIDATE_BOOLEAN),
        'timezone' => 'UTC',
    ],

    'api' => [
        'version' => 'v1',
        'base_url' => $_ENV['API_BASE_URL'] ?? 'https://api.healthapp.example.com',
        'rate_limit' => [
            'requests_per_minute' => (int)($_ENV['RATE_LIMIT_REQUESTS'] ?? 100),
            'auth_requests_per_minute' => (int)($_ENV['RATE_LIMIT_AUTH_REQUESTS'] ?? 5),
        ],
    ],

    'cors' => [
        'allowed_origins' => explode(',', $_ENV['CORS_ALLOWED_ORIGINS'] ?? 'https://healthapp.example.com'),
        'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
        'max_age' => 86400, // 24 hours
    ],

    'jwt' => [
        'secret' => $_ENV['JWT_SECRET'] ?? 'your-jwt-secret-key-change-in-production',
        'algorithm' => 'HS256',
        'access_token_ttl' => 86400, // 24 hours
        'refresh_token_ttl' => 2592000, // 30 days
    ],

    'google_oauth' => [
        'client_id' => $_ENV['GOOGLE_CLIENT_ID'] ?? '',
        'client_secret' => $_ENV['GOOGLE_CLIENT_SECRET'] ?? '',
        'redirect_uri' => $_ENV['GOOGLE_REDIRECT_URI'] ?? '',
    ],

    'sync' => [
        'conflict_resolution' => 'last_write_wins', // Options: last_write_wins, manual, merge
        'max_batch_size' => (int)($_ENV['SYNC_MAX_BATCH_SIZE'] ?? 100),
        'sync_window_days' => (int)($_ENV['SYNC_WINDOW_DAYS'] ?? 30),
    ],

    'logging' => [
        'level' => $_ENV['LOG_LEVEL'] ?? 'INFO',
        'file' => $_ENV['LOG_FILE'] ?? __DIR__ . '/../logs/app.log',
        'max_files' => (int)($_ENV['LOG_MAX_FILES'] ?? 30),
    ],
];
<?php

require __DIR__ . '/vendor/autoload.php';

use Dotenv\Dotenv;
use HealthApp\Services\DatabaseService;

// Load environment variables
$dotenv = Dotenv::createImmutable(__DIR__);
$dotenv->load();

// Database configuration
$dbConfig = [
    'driver' => 'mysql',
    'host' => $_ENV['DB_HOST'],
    'port' => $_ENV['DB_PORT'],
    'database' => $_ENV['DB_NAME'],
    'username' => $_ENV['DB_USER'],
    'password' => $_ENV['DB_PASSWORD'],
    'charset' => 'utf8mb4'
];

try {
    $db = new DatabaseService($dbConfig);

    echo "--- USERS ---\n";
    $users = $db->select("SELECT id, email, name, google_id, created_at FROM users");
    print_r($users);

    echo "\n--- HEALTH METRICS ---\n";
    $metrics = $db->select("SELECT id, user_id, date, weight_kg, updated_at FROM health_metrics ORDER BY date DESC LIMIT 20");
    print_r($metrics);

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

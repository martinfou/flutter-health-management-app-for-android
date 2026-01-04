<?php

declare(strict_types=1);

namespace HealthApp\Middleware;

use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Respect\Validation\Validator as v;

class ValidationMiddleware implements MiddlewareInterface
{
    private array $rules;

    public function __construct(array $rules = [])
    {
        $this->rules = $rules;
    }

    public function process(Request $request, RequestHandler $handler): Response
    {
        $route = $request->getUri()->getPath();
        $method = $request->getMethod();

        // Get validation rules for this route
        $routeKey = $method . ' ' . $route;
        $rules = $this->rules[$routeKey] ?? [];

        if (!empty($rules)) {
            // Validate query parameters
            if (isset($rules['query'])) {
                $errors = $this->validateData($request->getQueryParams(), $rules['query']);
                if (!empty($errors)) {
                    return ResponseHelper::validationError(
                        new \Slim\Psr7\Response(),
                        ['query' => $errors],
                        'Query parameter validation failed'
                    );
                }
            }

            // Validate request body for POST/PUT/PATCH
            if (in_array($method, ['POST', 'PUT', 'PATCH']) && isset($rules['body'])) {
                $body = json_decode((string) $request->getBody(), true);

                if (json_last_error() !== JSON_ERROR_NONE) {
                    return ResponseHelper::validationError(
                        new \Slim\Psr7\Response(),
                        ['body' => 'Invalid JSON format'],
                        'Request body must be valid JSON'
                    );
                }

                $errors = $this->validateData($body, $rules['body']);
                if (!empty($errors)) {
                    return ResponseHelper::validationError(
                        new \Slim\Psr7\Response(),
                        ['body' => $errors],
                        'Request body validation failed'
                    );
                }
            }

            // Validate path parameters
            if (isset($rules['params'])) {
                $pathParams = $request->getAttributes();
                // Filter out non-path parameters
                $params = array_filter($pathParams, function($key) {
                    return !in_array($key, ['user', 'user_id', 'request', 'response']);
                }, ARRAY_FILTER_USE_KEY);

                $errors = $this->validateData($params, $rules['params']);
                if (!empty($errors)) {
                    return ResponseHelper::validationError(
                        new \Slim\Psr7\Response(),
                        ['params' => $errors],
                        'Path parameter validation failed'
                    );
                }
            }
        }

        return $handler->handle($request);
    }

    private function validateData(array $data, array $rules): array
    {
        $errors = [];

        foreach ($rules as $field => $rule) {
            $value = $data[$field] ?? null;

            try {
                if (is_callable($rule)) {
                    // Custom validation function
                    $result = $rule($value, $data);
                    if ($result !== true) {
                        $errors[$field] = is_string($result) ? $result : 'Validation failed';
                    }
                } elseif (is_array($rule)) {
                    // Array of validation rules
                    foreach ($rule as $validationRule) {
                        if (is_string($validationRule)) {
                            // Built-in validation rule
                            $this->applyBuiltInRule($validationRule, $field, $value, $errors);
                        } elseif (is_callable($validationRule)) {
                            // Custom function
                            $result = $validationRule($value, $data);
                            if ($result !== true) {
                                $errors[$field] = is_string($result) ? $result : 'Validation failed';
                                break; // Stop on first failure
                            }
                        }
                    }
                }
            } catch (\Exception $e) {
                $errors[$field] = $e->getMessage();
            }
        }

        return $errors;
    }

    private function applyBuiltInRule(string $rule, string $field, $value, array &$errors): void
    {
        switch ($rule) {
            case 'required':
                if ($value === null || $value === '' || (is_array($value) && empty($value))) {
                    $errors[$field] = 'This field is required';
                }
                break;

            case 'string':
                if ($value !== null && !is_string($value)) {
                    $errors[$field] = 'Must be a string';
                }
                break;

            case 'integer':
                if ($value !== null && !is_int($value) && !ctype_digit((string) $value)) {
                    $errors[$field] = 'Must be an integer';
                }
                break;

            case 'numeric':
                if ($value !== null && !is_numeric($value)) {
                    $errors[$field] = 'Must be numeric';
                }
                break;

            case 'boolean':
                if ($value !== null && !is_bool($value) && !in_array($value, ['true', 'false', '1', '0'])) {
                    $errors[$field] = 'Must be a boolean';
                }
                break;

            case 'email':
                if ($value !== null && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $errors[$field] = 'Must be a valid email address';
                }
                break;

            case 'date':
                if ($value !== null && !strtotime($value)) {
                    $errors[$field] = 'Must be a valid date';
                }
                break;

            case 'array':
                if ($value !== null && !is_array($value)) {
                    $errors[$field] = 'Must be an array';
                }
                break;

            default:
                // Unknown rule - ignore
                break;
        }
    }

    /**
     * Helper method to create validation rules for common patterns
     */
    public static function createRules(): array
    {
        return [
            // Authentication routes
            'POST /api/v1/auth/register' => [
                'body' => [
                    'email' => ['required', 'string', 'email'],
                    'password' => ['required', 'string', function($value) {
                        if (strlen($value) < 8) {
                            return 'Password must be at least 8 characters long';
                        }
                        return true;
                    }],
                    'name' => ['string', function($value) {
                        if ($value && strlen($value) > 255) {
                            return 'Name must be less than 255 characters';
                        }
                        return true;
                    }],
                ]
            ],

            'POST /api/v1/auth/login' => [
                'body' => [
                    'email' => ['required', 'string', 'email'],
                    'password' => ['required', 'string'],
                ]
            ],

            'POST /api/v1/auth/refresh' => [
                'body' => [
                    'refresh_token' => ['required', 'string'],
                ]
            ],

            'POST /api/v1/auth/verify-google' => [
                'body' => [
                    'id_token' => ['required', 'string'],
                ]
            ],

            // Health metrics routes
            'POST /api/v1/health-metrics' => [
                'body' => [
                    'date' => ['required', 'string', 'date'],
                    'weight_kg' => ['numeric'],
                    'sleep_hours' => ['numeric'],
                    'sleep_quality' => ['integer'],
                    'energy_level' => ['integer'],
                    'resting_heart_rate' => ['integer'],
                    'blood_pressure_systolic' => ['integer'],
                    'blood_pressure_diastolic' => ['integer'],
                    'steps' => ['integer'],
                    'calories_burned' => ['integer'],
                    'water_intake_ml' => ['integer'],
                    'mood' => [function($value) {
                        if ($value && !in_array($value, ['excellent', 'good', 'neutral', 'poor', 'terrible'])) {
                            return 'Invalid mood value';
                        }
                        return true;
                    }],
                    'stress_level' => ['integer'],
                    'notes' => ['string'],
                ]
            ],

            'PUT /api/v1/health-metrics/{id}' => [
                'params' => [
                    'id' => ['required', 'integer'],
                ],
                'body' => [
                    'weight_kg' => ['numeric'],
                    'sleep_hours' => ['numeric'],
                    'sleep_quality' => ['integer'],
                    'energy_level' => ['integer'],
                    'resting_heart_rate' => ['integer'],
                    'blood_pressure_systolic' => ['integer'],
                    'blood_pressure_diastolic' => ['integer'],
                    'steps' => ['integer'],
                    'calories_burned' => ['integer'],
                    'water_intake_ml' => ['integer'],
                    'mood' => [function($value) {
                        if ($value && !in_array($value, ['excellent', 'good', 'neutral', 'poor', 'terrible'])) {
                            return 'Invalid mood value';
                        }
                        return true;
                    }],
                    'stress_level' => ['integer'],
                    'notes' => ['string'],
                ]
            ],

            // Add more route validations as needed...
        ];
    }
}
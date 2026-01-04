<?php

declare(strict_types=1);

namespace HealthApp\Controllers;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\JwtHelper;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Respect\Validation\Validator as v;

class AuthController
{
    private DatabaseService $db;
    private JwtHelper $jwtHelper;
    private array $googleConfig;

    public function __construct(DatabaseService $db, JwtHelper $jwtHelper, array $googleConfig)
    {
        $this->db = $db;
        $this->jwtHelper = $jwtHelper;
        $this->googleConfig = $googleConfig;
    }

    /**
     * User registration
     */
    public function register(Request $request, Response $response): Response
    {
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        $validation = $this->validateRegistrationData($data);
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Check if user already exists
            $existingUser = $this->db->select(
                "SELECT id FROM users WHERE email = ? AND deleted_at IS NULL",
                [$data['email']]
            );

            if (!empty($existingUser)) {
                return ResponseHelper::error($response, 'Email already registered', 409);
            }

            // Hash password
            $passwordHash = password_hash($data['password'], PASSWORD_DEFAULT);

            // Insert user
            $result = $this->db->execute(
                "INSERT INTO users (email, password_hash, name, created_at, updated_at) VALUES (?, ?, ?, datetime('now'), datetime('now'))",
                [$data['email'], $passwordHash, $data['name'] ?? null]
            );

            if ($result === false) {
                throw new \Exception('Database insert failed');
            }

            $userId = (int) $this->db->lastInsertId();

            if ($userId === 0) {
                throw new \Exception('Failed to get inserted user ID');
            }

            // Generate tokens
            $tokenPayload = ['user_id' => $userId, 'email' => $data['email']];
            $accessToken = $this->jwtHelper->generateAccessToken($tokenPayload);
            $refreshToken = $this->jwtHelper->generateRefreshToken($tokenPayload);

            return ResponseHelper::success($response, [
                'user' => [
                    'id' => $userId,
                    'email' => $data['email'],
                    'name' => $data['name'] ?? null,
                ],
                'access_token' => $accessToken,
                'refresh_token' => $refreshToken,
                'token_type' => 'Bearer',
            ], 'User registered successfully', 201);

        } catch (\Exception $e) {
            // Log the actual error for debugging
            error_log('Registration error: ' . $e->getMessage());
            return ResponseHelper::serverError($response, 'Registration failed: ' . $e->getMessage());
        }
    }

    /**
     * User login
     */
    public function login(Request $request, Response $response): Response
    {
        $data = json_decode((string) $request->getBody(), true);

        // Validate input
        if (empty($data['email']) || empty($data['password'])) {
            return ResponseHelper::validationError($response, [
                'email' => 'Email is required',
                'password' => 'Password is required'
            ]);
        }

        try {
            // Find user
            $users = $this->db->select(
                "SELECT id, email, password_hash, name FROM users WHERE email = ? AND deleted_at IS NULL",
                [$data['email']]
            );

            if (empty($users)) {
                return ResponseHelper::error($response, 'Invalid credentials', 401);
            }

            $user = $users[0];

            // Verify password
            if (!password_verify($data['password'], $user['password_hash'])) {
                return ResponseHelper::error($response, 'Invalid credentials', 401);
            }

            // Update last login
            $this->db->execute(
                "UPDATE users SET last_login_at = datetime('now'), updated_at = datetime('now') WHERE id = ?",
                [$user['id']]
            );

            // Generate tokens
            $tokenPayload = ['user_id' => $user['id'], 'email' => $user['email']];
            $accessToken = $this->jwtHelper->generateAccessToken($tokenPayload);
            $refreshToken = $this->jwtHelper->generateRefreshToken($tokenPayload);

            return ResponseHelper::success($response, [
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'name' => $user['name'],
                ],
                'access_token' => $accessToken,
                'refresh_token' => $refreshToken,
                'token_type' => 'Bearer',
            ], 'Login successful');

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Login failed');
        }
    }

    /**
     * Refresh access token
     */
    public function refresh(Request $request, Response $response): Response
    {
        $data = json_decode((string) $request->getBody(), true);

        if (empty($data['refresh_token'])) {
            return ResponseHelper::validationError($response, [
                'refresh_token' => 'Refresh token is required'
            ]);
        }

        try {
            // Validate refresh token
            $payload = $this->jwtHelper->validateRefreshToken($data['refresh_token']);
            $userId = $this->jwtHelper->getUserIdFromToken($payload);

            // Verify user still exists
            $users = $this->db->select(
                "SELECT id, email, name FROM users WHERE id = ? AND deleted_at IS NULL",
                [$userId]
            );

            if (empty($users)) {
                return ResponseHelper::unauthorized($response, 'User not found');
            }

            $user = $users[0];

            // Generate new tokens
            $tokenPayload = ['user_id' => $user['id'], 'email' => $user['email']];
            $accessToken = $this->jwtHelper->generateAccessToken($tokenPayload);
            $refreshToken = $this->jwtHelper->generateRefreshToken($tokenPayload);

            return ResponseHelper::success($response, [
                'access_token' => $accessToken,
                'refresh_token' => $refreshToken,
                'token_type' => 'Bearer',
            ], 'Token refreshed successfully');

        } catch (\Exception $e) {
            return ResponseHelper::unauthorized($response, 'Invalid refresh token');
        }
    }

    /**
     * Verify Google OAuth token
     */
    public function verifyGoogle(Request $request, Response $response): Response
    {
        $data = json_decode((string) $request->getBody(), true);

        if (empty($data['id_token'])) {
            return ResponseHelper::validationError($response, [
                'id_token' => 'Google ID token is required'
            ]);
        }

        try {
            // Verify Google OAuth token
            $client = new \Google\Client();
            $client->setClientId($this->googleConfig['client_id']);

            $payload = $client->verifyIdToken($data['id_token']);

            if (!$payload) {
                return ResponseHelper::unauthorized($response, 'Invalid Google token');
            }

            $googleId = $payload['sub'];
            $email = $payload['email'];
            $name = $payload['name'] ?? null;

            // Check if user exists
            $existingUser = $this->db->select(
                "SELECT id, email, name, google_id FROM users WHERE google_id = ? AND deleted_at IS NULL",
                [$googleId]
            );

            if (!empty($existingUser)) {
                // Existing Google user - login
                $user = $existingUser[0];
            } else {
                // Check if email exists with different auth method
                $emailUser = $this->db->select(
                    "SELECT id FROM users WHERE email = ? AND deleted_at IS NULL",
                    [$email]
                );

                if (!empty($emailUser)) {
                    return ResponseHelper::error(
                        $response,
                        'Email already registered with different authentication method',
                        409
                    );
                }

                // Create new Google user
                $this->db->execute(
                    "INSERT INTO users (email, google_id, name, email_verified_at, created_at, updated_at) VALUES (?, ?, ?, datetime('now'), datetime('now'), datetime('now'))",
                    [$email, $googleId, $name]
                );

                $userId = (int) $this->db->lastInsertId();

                $user = [
                    'id' => $userId,
                    'email' => $email,
                    'name' => $name,
                    'google_id' => $googleId,
                ];
            }

            // Update last login
            $this->db->execute(
                "UPDATE users SET last_login_at = datetime('now'), updated_at = datetime('now') WHERE id = ?",
                [$user['id']]
            );

            // Generate tokens
            $tokenPayload = ['user_id' => $user['id'], 'email' => $user['email']];
            $accessToken = $this->jwtHelper->generateAccessToken($tokenPayload);
            $refreshToken = $this->jwtHelper->generateRefreshToken($tokenPayload);

            return ResponseHelper::success($response, [
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'name' => $user['name'],
                ],
                'access_token' => $accessToken,
                'refresh_token' => $refreshToken,
                'token_type' => 'Bearer',
            ], 'Google authentication successful');

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Google authentication failed');
        }
    }

    /**
     * Get user profile
     */
    public function getProfile(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');

        // Get full user profile
        $profile = $this->db->select(
            "SELECT id, email, name, date_of_birth, gender, height_cm, weight_kg,
                    activity_level, fitness_goals, dietary_approach, dislikes, allergies,
                    health_conditions, preferences, email_verified_at, created_at
             FROM users WHERE id = ? AND deleted_at IS NULL",
            [$user['id']]
        );

        if (empty($profile)) {
            return ResponseHelper::notFound($response, 'User not found');
        }

        return ResponseHelper::success($response, [
            'user' => $profile[0]
        ], 'Profile retrieved successfully');
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');
        $data = json_decode((string) $request->getBody(), true);

        // Validate update data
        $validation = $this->validateProfileUpdateData($data);
        if (!$validation['valid']) {
            return ResponseHelper::validationError($response, $validation['errors']);
        }

        try {
            // Build update query
            $updateFields = [];
            $params = [];

            $allowedFields = [
                'name', 'date_of_birth', 'gender', 'height_cm', 'weight_kg',
                'activity_level', 'dietary_approach', 'dislikes', 'allergies',
                'health_conditions', 'preferences'
            ];

            foreach ($allowedFields as $field) {
                if (isset($data[$field])) {
                    if (is_array($data[$field])) {
                        $updateFields[] = "$field = ?";
                        $params[] = json_encode($data[$field]);
                    } else {
                        $updateFields[] = "$field = ?";
                        $params[] = $data[$field];
                    }
                }
            }

            if (empty($updateFields)) {
                return ResponseHelper::validationError($response, [
                    'data' => 'No valid fields to update'
                ]);
            }

            $updateFields[] = "updated_at = datetime('now')";
            $params[] = $user['id'];

            $query = "UPDATE users SET " . implode(', ', $updateFields) . " WHERE id = ?";
            $this->db->execute($query, $params);

            // Return updated profile
            return $this->getProfile($request, $response);

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Profile update failed');
        }
    }

    /**
     * Delete user account (GDPR compliance)
     */
    public function deleteAccount(Request $request, Response $response): Response
    {
        $user = $request->getAttribute('user');

        try {
            // Soft delete user account
            $this->db->execute(
                "UPDATE users SET deleted_at = datetime('now'), updated_at = datetime('now') WHERE id = ?",
                [$user['id']]
            );

            return ResponseHelper::success($response, [], 'Account deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError($response, 'Account deletion failed');
        }
    }

    /**
     * Logout user
     */
    public function logout(Request $request, Response $response): Response
    {
        // For stateless JWT, logout is handled client-side
        // In a future iteration, we could implement token blacklisting
        return ResponseHelper::success($response, [], 'Logged out successfully');
    }

    /**
     * Validate registration data
     */
    private function validateRegistrationData(array $data): array
    {
        $errors = [];

        if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = 'Valid email is required';
        }

        if (empty($data['password']) || strlen($data['password']) < 8) {
            $errors['password'] = 'Password must be at least 8 characters long';
        }

        if (isset($data['name']) && strlen($data['name']) > 255) {
            $errors['name'] = 'Name must be less than 255 characters';
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }

    /**
     * Validate profile update data
     */
    private function validateProfileUpdateData(array $data): array
    {
        $errors = [];

        $allowedFields = [
            'name', 'date_of_birth', 'gender', 'height_cm', 'weight_kg',
            'activity_level', 'dietary_approach', 'dislikes', 'allergies',
            'health_conditions', 'preferences'
        ];

        foreach ($data as $field => $value) {
            if (!in_array($field, $allowedFields)) {
                $errors[$field] = 'Field not allowed for update';
                continue;
            }

            switch ($field) {
                case 'name':
                    if (strlen($value) > 255) {
                        $errors[$field] = 'Name must be less than 255 characters';
                    }
                    break;
                case 'height_cm':
                case 'weight_kg':
                    if (!is_numeric($value) || $value < 0) {
                        $errors[$field] = 'Must be a positive number';
                    }
                    break;
                case 'gender':
                    $validGenders = ['male', 'female', 'other', 'prefer_not_to_say'];
                    if (!in_array($value, $validGenders)) {
                        $errors[$field] = 'Invalid gender value';
                    }
                    break;
                case 'activity_level':
                    $validLevels = ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'];
                    if (!in_array($value, $validLevels)) {
                        $errors[$field] = 'Invalid activity level';
                    }
                    break;
            }
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }
}
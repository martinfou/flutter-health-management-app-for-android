<?php

declare(strict_types=1);

namespace App\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use App\Services\DatabaseService;
use App\Utils\ResponseHelper;
use App\Utils\JwtHelper;

class AuthController
{
    private DatabaseService $db;
    private ResponseHelper $responseHelper;
    private JwtHelper $jwtHelper;

    public function __construct(DatabaseService $db, ResponseHelper $responseHelper, JwtHelper $jwtHelper)
    {
        $this->db = $db;
        $this->responseHelper = $responseHelper;
        $this->jwtHelper = $jwtHelper;
    }

    public function register(Request $request, Response $response): Response
    {
        try {
            $data = $request->getParsedBody();

            // Validate required fields
            $requiredFields = ['email', 'password', 'name'];
            foreach ($requiredFields as $field) {
                if (!isset($data[$field]) || empty(trim($data[$field]))) {
                    return $this->responseHelper->errorResponse(
                        $response,
                        "Field '{$field}' is required",
                        400
                    );
                }
            }

            $email = trim($data['email']);
            $password = $data['password'];
            $name = trim($data['name']);

            // Validate email format
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Invalid email format',
                    400
                );
            }

            // Validate password strength
            if (strlen($password) < 8) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Password must be at least 8 characters long',
                    400
                );
            }

            // Validate name length
            if (strlen($name) < 2 || strlen($name) > 100) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Name must be between 2 and 100 characters',
                    400
                );
            }

            // Check if user already exists
            $stmt = $this->db->prepare("SELECT id FROM users WHERE email = ?");
            $stmt->execute([$email]);
            if ($stmt->fetch()) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'User with this email already exists',
                    409
                );
            }

            // Hash password
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

            // Create user
            $stmt = $this->db->prepare("
                INSERT INTO users (email, password_hash, name, created_at, updated_at)
                VALUES (?, ?, ?, datetime('now'), datetime('now'))
            ");
            $stmt->execute([$email, $hashedPassword, $name]);

            $userId = $this->db->lastInsertId();

            return $this->responseHelper->jsonResponse($response, [
                'success' => true,
                'message' => 'User registered successfully',
                'data' => [
                    'user' => [
                        'id' => $userId,
                        'email' => $email,
                        'name' => $name
                    ]
                ]
            ], 201);
        } catch (\Exception $e) {
            return $this->responseHelper->errorResponse(
                $response,
                'Failed to register user',
                500
            );
        }
    }

    public function login(Request $request, Response $response): Response
    {
        try {
            $data = $request->getParsedBody();

            // Validate required fields
            if (!isset($data['email']) || !isset($data['password'])) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Email and password are required',
                    400
                );
            }

            $email = trim($data['email']);
            $password = $data['password'];

            // Validate email format
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Invalid email format',
                    400
                );
            }

            // Get user by email
            $stmt = $this->db->prepare("SELECT id, email, password_hash, name FROM users WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch();

            if (!$user) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Invalid credentials',
                    401
                );
            }

            // Verify password
            if (!password_verify($password, $user['password_hash'])) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Invalid credentials',
                    401
                );
            }

            // Generate tokens
            $accessToken = $this->jwtHelper->generateAccessToken((int)$user['id']);
            $refreshToken = $this->jwtHelper->generateRefreshToken((int)$user['id']);

            // Store refresh token
            $this->storeRefreshToken((int)$user['id'], $refreshToken);

            return $this->responseHelper->jsonResponse($response, [
                'success' => true,
                'message' => 'Login successful',
                'data' => [
                    'user' => [
                        'id' => $user['id'],
                        'email' => $user['email'],
                        'name' => $user['name']
                    ],
                    'access_token' => $accessToken,
                    'refresh_token' => $refreshToken,
                    'token_type' => 'Bearer',
                    'expires_in' => 3600 // 1 hour
                ]
            ]);
        } catch (\Exception $e) {
            return $this->responseHelper->errorResponse(
                $response,
                'Login failed',
                500
            );
        }
    }

    public function refresh(Request $request, Response $response): Response
    {
        try {
            $data = $request->getParsedBody();

            if (!isset($data['refresh_token'])) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Refresh token is required',
                    400
                );
            }

            // Validate refresh token
            $payload = $this->jwtHelper->validateRefreshToken($data['refresh_token']);
            if (!$payload) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Invalid refresh token',
                    401
                );
            }

            $userId = $payload['user_id'];

            // Check if refresh token exists in database and is not expired
            $stmt = $this->db->prepare("
                SELECT id FROM refresh_tokens
                WHERE user_id = ? AND token = ? AND expires_at > datetime('now')
            ");
            $stmt->execute([$userId, $data['refresh_token']]);
            if (!$stmt->fetch()) {
                return $this->responseHelper->errorResponse(
                    $response,
                    'Refresh token expired or invalid',
                    401
                );
            }

            // Generate new tokens
            $accessToken = $this->jwtHelper->generateAccessToken($userId);
            $refreshToken = $this->jwtHelper->generateRefreshToken($userId);

            // Update refresh token in database
            $this->storeRefreshToken($userId, $refreshToken);

            return $this->responseHelper->jsonResponse($response, [
                'success' => true,
                'message' => 'Token refreshed successfully',
                'data' => [
                    'access_token' => $accessToken,
                    'refresh_token' => $refreshToken,
                    'token_type' => 'Bearer',
                    'expires_in' => 3600 // 1 hour
                ]
            ]);
        } catch (\Exception $e) {
            return $this->responseHelper->errorResponse(
                $response,
                'Token refresh failed',
                500
            );
        }
    }

    /**
     * Store refresh token in database
     */
    private function storeRefreshToken(int $userId, string $refreshToken): void
    {
        // Remove old refresh tokens for this user
        $stmt = $this->db->prepare("DELETE FROM refresh_tokens WHERE user_id = ?");
        $stmt->execute([$userId]);

        // Store new refresh token
        $stmt = $this->db->prepare("
            INSERT INTO refresh_tokens (user_id, token, expires_at, created_at)
            VALUES (?, ?, datetime('now', '+30 days'), datetime('now'))
        ");
        $stmt->execute([$userId, $refreshToken]);
    }
}
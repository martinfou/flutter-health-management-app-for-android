<?php

declare(strict_types=1);

namespace App\Utils;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtHelper
{
    private string $secret;
    private int $accessTokenExpire;
    private int $refreshTokenExpire;

    public function __construct(string $secret)
    {
        $this->secret = $secret;
        $this->accessTokenExpire = (int)($_ENV['JWT_ACCESS_TOKEN_EXPIRE'] ?? 3600); // 1 hour
        $this->refreshTokenExpire = (int)($_ENV['JWT_REFRESH_TOKEN_EXPIRE'] ?? 2592000); // 30 days
    }

    /**
     * Generate an access token
     */
    public function generateAccessToken(int $userId): string
    {
        $issuedAt = time();
        $expireAt = $issuedAt + $this->accessTokenExpire;

        $payload = [
            'iss' => 'health-management-api',
            'aud' => 'health-management-app',
            'iat' => $issuedAt,
            'exp' => $expireAt,
            'user_id' => $userId,
            'type' => 'access'
        ];

        return JWT::encode($payload, $this->secret, 'HS256');
    }

    /**
     * Generate a refresh token
     */
    public function generateRefreshToken(int $userId): string
    {
        $issuedAt = time();
        $expireAt = $issuedAt + $this->refreshTokenExpire;

        $payload = [
            'iss' => 'health-management-api',
            'aud' => 'health-management-app',
            'iat' => $issuedAt,
            'exp' => $expireAt,
            'user_id' => $userId,
            'type' => 'refresh'
        ];

        return JWT::encode($payload, $this->secret, 'HS256');
    }

    /**
     * Validate an access token
     */
    public function validateAccessToken(string $token): ?array
    {
        try {
            $decoded = JWT::decode($token, new Key($this->secret, 'HS256'));

            // Check if it's an access token
            if (($decoded->type ?? null) !== 'access') {
                return null;
            }

            return (array) $decoded;
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Validate a refresh token
     */
    public function validateRefreshToken(string $token): ?array
    {
        try {
            $decoded = JWT::decode($token, new Key($this->secret, 'HS256'));

            // Check if it's a refresh token
            if (($decoded->type ?? null) !== 'refresh') {
                return null;
            }

            return (array) $decoded;
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Extract user ID from token
     */
    public function getUserIdFromToken(string $token): ?int
    {
        $payload = $this->validateAccessToken($token);
        return $payload['user_id'] ?? null;
    }

    /**
     * Check if token is expired
     */
    public function isTokenExpired(string $token): bool
    {
        try {
            $decoded = JWT::decode($token, new Key($this->secret, 'HS256'));
            return $decoded->exp < time();
        } catch (\Exception $e) {
            return true;
        }
    }
}
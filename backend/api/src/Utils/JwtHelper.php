<?php

declare(strict_types=1);

namespace HealthApp\Utils;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Exception;

class JwtHelper
{
    private string $secret;
    private string $algorithm;
    private int $accessTokenTtl;
    private int $refreshTokenTtl;

    public function __construct(
        string $secret,
        string $algorithm = 'HS256',
        int $accessTokenTtl = 86400,
        int $refreshTokenTtl = 2592000
    ) {
        $this->secret = $secret;
        $this->algorithm = $algorithm;
        $this->accessTokenTtl = $accessTokenTtl;
        $this->refreshTokenTtl = $refreshTokenTtl;
    }

    /**
     * Generate access token
     */
    public function generateAccessToken(array $payload): string
    {
        $payload['iat'] = time();
        $payload['exp'] = time() + $this->accessTokenTtl;
        $payload['type'] = 'access';

        return JWT::encode($payload, $this->secret, $this->algorithm);
    }

    /**
     * Generate refresh token
     */
    public function generateRefreshToken(array $payload): string
    {
        $payload['iat'] = time();
        $payload['exp'] = time() + $this->refreshTokenTtl;
        $payload['type'] = 'refresh';

        return JWT::encode($payload, $this->secret, $this->algorithm);
    }

    /**
     * Decode and verify JWT token
     */
    public function decodeToken(string $token): array
    {
        try {
            return (array) JWT::decode($token, new Key($this->secret, $this->algorithm));
        } catch (Exception $e) {
            throw new Exception('Invalid token: ' . $e->getMessage());
        }
    }

    /**
     * Validate access token and return payload
     */
    public function validateAccessToken(string $token): array
    {
        $payload = $this->decodeToken($token);

        if (($payload['type'] ?? '') !== 'access') {
            throw new Exception('Invalid token type');
        }

        return $payload;
    }

    /**
     * Validate refresh token and return payload
     */
    public function validateRefreshToken(string $token): array
    {
        $payload = $this->decodeToken($token);

        if (($payload['type'] ?? '') !== 'refresh') {
            throw new Exception('Invalid token type');
        }

        return $payload;
    }

    /**
     * Check if token is expired
     */
    public function isTokenExpired(array $payload): bool
    {
        return ($payload['exp'] ?? 0) < time();
    }

    /**
     * Get user ID from token payload
     */
    public function getUserIdFromToken(array $payload): int
    {
        return $payload['user_id'] ?? 0;
    }
}
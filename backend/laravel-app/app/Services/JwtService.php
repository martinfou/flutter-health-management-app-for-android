<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Exception;

class JwtService
{
    private string $secret;
    private string $algorithm;
    private int $accessTokenTtl;
    private int $refreshTokenTtl;

    public function __construct()
    {
        $this->secret = config('jwt.secret');
        $this->algorithm = config('jwt.algorithm', 'HS256');
        $this->accessTokenTtl = config('jwt.access_ttl', 86400);
        $this->refreshTokenTtl = config('jwt.refresh_ttl', 2592000);
    }

    /**
     * Generate access token (matching Slim format)
     *
     * @param array $payload
     * @return string
     */
    public function generateAccessToken(array $payload): string
    {
        $payload['iat'] = time();
        $payload['exp'] = time() + $this->accessTokenTtl;
        $payload['type'] = 'access';

        return JWT::encode($payload, $this->secret, $this->algorithm);
    }

    /**
     * Generate refresh token (matching Slim format)
     *
     * @param array $payload
     * @return string
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
     *
     * @param string $token
     * @return array
     * @throws Exception
     */
    public function decodeToken(string $token): array
    {
        try {
            $decoded = JWT::decode($token, new Key($this->secret, $this->algorithm));
            return (array) $decoded;
        } catch (\Exception $e) {
            throw new Exception('Invalid token: ' . $e->getMessage());
        }
    }

    /**
     * Validate access token and return payload
     *
     * @param string $token
     * @return array
     * @throws Exception
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
     *
     * @param string $token
     * @return array
     * @throws Exception
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
     * Get user ID from token payload
     *
     * @param array $payload
     * @return int
     */
    public function getUserIdFromToken(array $payload): int
    {
        return $payload['user_id'] ?? 0;
    }

    /**
     * Get email from token payload
     *
     * @param array $payload
     * @return string|null
     */
    public function getEmailFromToken(array $payload): ?string
    {
        return $payload['email'] ?? null;
    }
}

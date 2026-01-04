<?php

declare(strict_types=1);

namespace HealthApp\Middleware;

use HealthApp\Services\DatabaseService;
use HealthApp\Utils\JwtHelper;
use HealthApp\Utils\ResponseHelper;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;

class AuthMiddleware implements MiddlewareInterface
{
    private JwtHelper $jwtHelper;
    private DatabaseService $db;

    public function __construct(JwtHelper $jwtHelper, DatabaseService $db)
    {
        $this->jwtHelper = $jwtHelper;
        $this->db = $db;
    }

    public function process(Request $request, RequestHandler $handler): Response
    {
        $authHeader = $request->getHeaderLine('Authorization');

        if (empty($authHeader)) {
            return ResponseHelper::unauthorized(
                new \Slim\Psr7\Response(),
                'Authorization header missing'
            );
        }

        if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return ResponseHelper::unauthorized(
                new \Slim\Psr7\Response(),
                'Invalid authorization header format'
            );
        }

        $token = $matches[1];

        try {
            $payload = $this->jwtHelper->validateAccessToken($token);
            $userId = $this->jwtHelper->getUserIdFromToken($payload);

            // Verify user exists and is not deleted
            $user = $this->db->select(
                "SELECT id, email, deleted_at FROM users WHERE id = ? AND deleted_at IS NULL",
                [$userId]
            );

            if (empty($user)) {
                return ResponseHelper::unauthorized(
                    new \Slim\Psr7\Response(),
                    'User not found or account deactivated'
                );
            }

            // Add user to request attributes
            $request = $request->withAttribute('user', $user[0]);
            $request = $request->withAttribute('user_id', $userId);

        } catch (\Exception $e) {
            return ResponseHelper::unauthorized(
                new \Slim\Psr7\Response(),
                'Invalid or expired token'
            );
        }

        return $handler->handle($request);
    }
}
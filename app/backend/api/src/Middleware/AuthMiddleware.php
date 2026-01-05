<?php

declare(strict_types=1);

namespace App\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Psr\Http\Message\ResponseInterface as Response;

class AuthMiddleware
{
    private $jwtHelper;
    private $responseHelper;

    public function __construct($jwtHelper, $responseHelper)
    {
        $this->jwtHelper = $jwtHelper;
        $this->responseHelper = $responseHelper;
    }

    public function __invoke(Request $request, RequestHandler $handler): Response
    {
        $authHeader = $request->getHeaderLine('Authorization');

        if (empty($authHeader)) {
            return $this->responseHelper->unauthorizedResponse(
                new \Slim\Psr7\Response(),
                'Authorization header is required'
            );
        }

        if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return $this->responseHelper->unauthorizedResponse(
                new \Slim\Psr7\Response(),
                'Authorization header must be in format: Bearer <token>'
            );
        }

        $token = $matches[1];

        try {
            $payload = $this->jwtHelper->validateAccessToken($token);

            if (!$payload) {
                return $this->responseHelper->unauthorizedResponse(
                    new \Slim\Psr7\Response(),
                    'Invalid or expired access token'
                );
            }

            // Add user_id to request attributes
            $request = $request->withAttribute('user_id', $payload['user_id']);
            $request = $request->withAttribute('token_payload', $payload);

        } catch (\Exception $e) {
            return $this->responseHelper->unauthorizedResponse(
                new \Slim\Psr7\Response(),
                'Token validation failed'
            );
        }

        return $handler->handle($request);
    }
}
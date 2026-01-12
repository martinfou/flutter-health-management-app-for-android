<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiTestCase extends TestCase
{
    use RefreshDatabase;

    protected ?User $user = null;
    protected ?string $token = null;

    /**
     * Set up test user and authentication
     */
    protected function authenticateUser(): void
    {
        $this->user = User::factory()->create([
            'email' => 'test@example.com',
            'password_hash' => bcrypt('password123'),
        ]);

        // Get JWT token
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123',
        ]);

        $this->token = $response->json('data.access_token');
    }

    /**
     * Make authenticated request
     */
    protected function authenticatedGet(string $uri, array $headers = [])
    {
        return $this->getJson($uri, array_merge([
            'Authorization' => 'Bearer ' . $this->token,
        ], $headers));
    }

    /**
     * Make authenticated POST request
     */
    protected function authenticatedPost(string $uri, array $data = [], array $headers = [])
    {
        return $this->postJson($uri, $data, array_merge([
            'Authorization' => 'Bearer ' . $this->token,
        ], $headers));
    }

    /**
     * Make authenticated PUT request
     */
    protected function authenticatedPut(string $uri, array $data = [], array $headers = [])
    {
        return $this->putJson($uri, $data, array_merge([
            'Authorization' => 'Bearer ' . $this->token,
        ], $headers));
    }

    /**
     * Make authenticated DELETE request
     */
    protected function authenticatedDelete(string $uri, array $headers = [])
    {
        return $this->deleteJson($uri, [], array_merge([
            'Authorization' => 'Bearer ' . $this->token,
        ], $headers));
    }
}

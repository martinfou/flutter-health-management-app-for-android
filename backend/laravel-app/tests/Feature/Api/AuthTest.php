<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class AuthTest extends ApiTestCase
{
    /**
     * Test user registration
     */
    public function test_user_can_register(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'email' => 'newuser@example.com',
            'password' => 'password123',
            'name' => 'New User',
        ]);

        $response->assertStatus(201);
        $response->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'user' => ['id', 'email', 'name'],
                'access_token',
                'refresh_token',
                'token_type',
            ],
            'timestamp',
        ]);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.user.email', 'newuser@example.com');
    }

    /**
     * Test registration with existing email
     */
    public function test_registration_fails_with_existing_email(): void
    {
        User::factory()->create(['email' => 'existing@example.com']);

        $response = $this->postJson('/api/v1/auth/register', [
            'email' => 'existing@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(422);
        $response->assertJsonPath('success', false);
    }

    /**
     * Test user login
     */
    public function test_user_can_login(): void
    {
        User::factory()->create([
            'email' => 'test@example.com',
            'password_hash' => bcrypt('password123'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.user.email', 'test@example.com');
        $response->assertJsonStructure([
            'data' => ['access_token', 'refresh_token', 'token_type'],
        ]);
    }

    /**
     * Test login with invalid credentials
     */
    public function test_login_fails_with_invalid_credentials(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401);
        $response->assertJsonPath('success', false);
    }

    /**
     * Test token refresh
     */
    public function test_can_refresh_token(): void
    {
        $this->authenticateUser();

        $response = $this->postJson('/api/v1/auth/refresh', [
            'refresh_token' => $this->token,
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonStructure([
            'data' => ['access_token', 'refresh_token', 'token_type'],
        ]);
    }

    /**
     * Test getting user profile
     */
    public function test_can_get_user_profile(): void
    {
        $this->authenticateUser();

        $response = $this->authenticatedGet('/api/v1/user/profile');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonStructure([
            'data' => [
                'user' => ['id', 'email', 'name', 'created_at'],
            ],
        ]);
    }

    /**
     * Test updating user profile
     */
    public function test_can_update_user_profile(): void
    {
        $this->authenticateUser();

        $response = $this->authenticatedPut('/api/v1/user/profile', [
            'name' => 'Updated Name',
            'height_cm' => 180,
            'weight_kg' => 75,
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
        $response->assertJsonPath('data.user.name', 'Updated Name');
    }

    /**
     * Test logout
     */
    public function test_user_can_logout(): void
    {
        $this->authenticateUser();

        $response = $this->authenticatedPost('/api/v1/auth/logout');

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);
    }

    /**
     * Test protected endpoint requires authentication
     */
    public function test_protected_endpoint_requires_auth(): void
    {
        $response = $this->getJson('/api/v1/user/profile');

        $response->assertStatus(401);
    }
}

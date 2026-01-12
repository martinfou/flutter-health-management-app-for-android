<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseHelper;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\JwtService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    private JwtService $jwtService;

    public function __construct(JwtService $jwtService)
    {
        $this->jwtService = $jwtService;
    }

    /**
     * Register new user
     * POST /api/v1/auth/register
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:8',
            'name' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return ResponseHelper::validationError($validator->errors());
        }

        try {
            $user = User::create([
                'email' => $request->email,
                'password_hash' => Hash::make($request->password),
                'name' => $request->name,
            ]);

            $tokenPayload = ['user_id' => $user->id, 'email' => $user->email];
            $accessToken = $this->jwtService->generateAccessToken($tokenPayload);
            $refreshToken = $this->jwtService->generateRefreshToken($tokenPayload);

            return ResponseHelper::success(
                [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                        'name' => $user->name,
                    ],
                    'access_token' => $accessToken,
                    'refresh_token' => $refreshToken,
                    'token_type' => 'Bearer',
                ],
                'User registered successfully',
                201
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Registration failed: ' . $e->getMessage());
        }
    }

    /**
     * Login user
     * POST /api/v1/auth/login
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return ResponseHelper::validationError($validator->errors());
        }

        $user = User::where('email', $request->email)->whereNull('deleted_at')->first();

        if (!$user || !Hash::check($request->password, $user->password_hash ?? '')) {
            return ResponseHelper::unauthorized('Invalid credentials');
        }

        if (!$user->password_hash) {
            return ResponseHelper::unauthorized('This account was created with Google Sign-In. Please use Google to login.');
        }

        $user->last_login_at = now();
        $user->save();

        $tokenPayload = ['user_id' => $user->id, 'email' => $user->email];
        $accessToken = $this->jwtService->generateAccessToken($tokenPayload);
        $refreshToken = $this->jwtService->generateRefreshToken($tokenPayload);

        return ResponseHelper::success(
            [
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'name' => $user->name,
                ],
                'access_token' => $accessToken,
                'refresh_token' => $refreshToken,
                'token_type' => 'Bearer',
            ],
            'Login successful'
        );
    }

    /**
     * Verify Google OAuth token
     * POST /api/v1/auth/verify-google
     */
    public function verifyGoogle(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return ResponseHelper::validationError($validator->errors());
        }

        try {
            $client = new \Google\Client();
            $serverClientId = config('services.google.client_id');
            $androidClientId = '741266813874-6j2lqr66e3nq68kusvdhhe69b8alsss6.apps.googleusercontent.com';

            // Try server client ID first
            $payload = $client->verifyIdToken($request->id_token);

            // If that fails, try Android client ID
            if (!$payload) {
                $client->setClientId($androidClientId);
                $payload = $client->verifyIdToken($request->id_token);
            }

            if (!$payload) {
                return ResponseHelper::unauthorized('Invalid Google token');
            }

            $googleId = $payload['sub'];
            $email = $payload['email'];
            $name = $payload['name'] ?? null;

            $user = User::where('google_id', $googleId)
                ->whereNull('deleted_at')
                ->first();

            if (!$user) {
                // Check if email exists
                $emailUser = User::where('email', $email)
                    ->whereNull('deleted_at')
                    ->first();

                if ($emailUser) {
                    return ResponseHelper::error(
                        'Email already registered with different authentication method',
                        409
                    );
                }

                // Create new user
                $user = User::create([
                    'email' => $email,
                    'google_id' => $googleId,
                    'name' => $name,
                    'email_verified_at' => now(),
                ]);
            }

            $user->last_login_at = now();
            $user->save();

            $tokenPayload = ['user_id' => $user->id, 'email' => $user->email];
            $accessToken = $this->jwtService->generateAccessToken($tokenPayload);
            $refreshToken = $this->jwtService->generateRefreshToken($tokenPayload);

            return ResponseHelper::success(
                [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                        'name' => $user->name,
                    ],
                    'access_token' => $accessToken,
                    'refresh_token' => $refreshToken,
                    'token_type' => 'Bearer',
                ],
                'Google authentication successful'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Google authentication failed: ' . $e->getMessage());
        }
    }

    /**
     * Refresh access token
     * POST /api/v1/auth/refresh
     */
    public function refresh(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'refresh_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return ResponseHelper::validationError($validator->errors());
        }

        try {
            $payload = $this->jwtService->validateRefreshToken($request->refresh_token);
            $userId = $this->jwtService->getUserIdFromToken($payload);

            $user = User::where('id', $userId)->whereNull('deleted_at')->first();

            if (!$user) {
                return ResponseHelper::unauthorized('User not found');
            }

            $tokenPayload = ['user_id' => $user->id, 'email' => $user->email];
            $accessToken = $this->jwtService->generateAccessToken($tokenPayload);
            $refreshToken = $this->jwtService->generateRefreshToken($tokenPayload);

            return ResponseHelper::success(
                [
                    'access_token' => $accessToken,
                    'refresh_token' => $refreshToken,
                    'token_type' => 'Bearer',
                ],
                'Token refreshed successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::unauthorized('Invalid refresh token');
        }
    }

    /**
     * Logout user
     * POST /api/v1/auth/logout
     */
    public function logout(Request $request)
    {
        return ResponseHelper::success([], 'Logged out successfully');
    }

    /**
     * Get user profile
     * GET /api/v1/user/profile
     */
    public function getProfile(Request $request)
    {
        $user = $request->attributes->get('user');

        return ResponseHelper::success(
            [
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'name' => $user->name,
                    'date_of_birth' => $user->date_of_birth?->format('Y-m-d'),
                    'gender' => $user->gender,
                    'height_cm' => $user->height_cm,
                    'weight_kg' => $user->weight_kg,
                    'activity_level' => $user->activity_level,
                    'fitness_goals' => $user->fitness_goals,
                    'dietary_approach' => $user->dietary_approach,
                    'dislikes' => $user->dislikes,
                    'allergies' => $user->allergies,
                    'health_conditions' => $user->health_conditions,
                    'preferences' => $user->preferences,
                    'created_at' => $user->created_at->toIso8601String(),
                ],
            ],
            'Profile retrieved successfully'
        );
    }

    /**
     * Update user profile
     * PUT /api/v1/user/profile
     */
    public function updateProfile(Request $request)
    {
        $user = $request->attributes->get('user');

        $validator = Validator::make($request->all(), [
            'name' => 'nullable|string|max:255',
            'date_of_birth' => 'nullable|date',
            'gender' => 'nullable|in:male,female,other,prefer_not_to_say',
            'height_cm' => 'nullable|numeric|min:0|max:300',
            'weight_kg' => 'nullable|numeric|min:0|max:500',
            'activity_level' => 'nullable|in:sedentary,lightly_active,moderately_active,very_active,extremely_active',
            'fitness_goals' => 'nullable|array',
            'dietary_approach' => 'nullable|string|max:100',
            'dislikes' => 'nullable|array',
            'allergies' => 'nullable|array',
            'health_conditions' => 'nullable|array',
            'preferences' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return ResponseHelper::validationError($validator->errors());
        }

        try {
            $user->fill($request->only([
                'name', 'date_of_birth', 'gender', 'height_cm', 'weight_kg',
                'activity_level', 'fitness_goals', 'dietary_approach', 'dislikes',
                'allergies', 'health_conditions', 'preferences',
            ]));
            $user->save();

            return ResponseHelper::success(
                [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                        'name' => $user->name,
                        'date_of_birth' => $user->date_of_birth?->format('Y-m-d'),
                        'gender' => $user->gender,
                        'height_cm' => $user->height_cm,
                        'weight_kg' => $user->weight_kg,
                        'activity_level' => $user->activity_level,
                    ],
                ],
                'Profile updated successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to update profile');
        }
    }

    /**
     * Delete user account (soft delete)
     * DELETE /api/v1/user/account
     */
    public function deleteAccount(Request $request)
    {
        $user = $request->attributes->get('user');

        try {
            $user->delete(); // Soft delete

            return ResponseHelper::success([], 'Account deleted successfully');

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to delete account');
        }
    }
}

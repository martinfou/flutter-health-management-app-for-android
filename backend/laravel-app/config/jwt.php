<?php

return [

    /*
    |--------------------------------------------------------------------------
    | JWT Secret Key
    |--------------------------------------------------------------------------
    |
    | This is the secret key used to sign and verify JWT tokens.
    | IMPORTANT: This must match the Slim API's JWT secret for compatibility.
    |
    */

    'secret' => env('JWT_SECRET', 'your-jwt-secret-key-change-in-production'),

    /*
    |--------------------------------------------------------------------------
    | JWT Algorithm
    |--------------------------------------------------------------------------
    |
    | The algorithm used to sign JWT tokens. Must match Slim API.
    | Common algorithms: HS256, HS384, HS512, RS256
    |
    */

    'algorithm' => env('JWT_ALGO', 'HS256'),

    /*
    |--------------------------------------------------------------------------
    | Access Token Time-To-Live (TTL)
    |--------------------------------------------------------------------------
    |
    | The time in seconds that the access token is valid for.
    | Default: 86400 seconds (24 hours) - must match Slim API
    |
    */

    'access_ttl' => env('JWT_ACCESS_TTL', 86400),

    /*
    |--------------------------------------------------------------------------
    | Refresh Token Time-To-Live (TTL)
    |--------------------------------------------------------------------------
    |
    | The time in seconds that the refresh token is valid for.
    | Default: 2592000 seconds (30 days) - must match Slim API
    |
    */

    'refresh_ttl' => env('JWT_REFRESH_TTL', 2592000),

];

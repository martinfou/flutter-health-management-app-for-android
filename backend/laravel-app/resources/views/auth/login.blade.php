<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" data-theme="dark">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="color-scheme" content="dark">

    <title>Sign In - Obsidian Pro</title>

    <!-- Font Awesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <!-- Google Fonts: Outfit + JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Outfit:wght@400;500;600;700;800&display=swap"
        rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            font-size: 16px;
            color-scheme: dark;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background-color: #0a0a0f;
            background-image:
                linear-gradient(rgba(255, 255, 255, 0.02) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.02) 1px, transparent 1px);
            background-size: 40px 40px;
            color: #ffffff;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem;
        }

        .login-container {
            width: 100%;
            max-width: 400px;
        }

        .login-card {
            background: #15151e;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 8px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
            padding: 2rem;
        }

        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .logo {
            font-size: 1.75rem;
            font-weight: 700;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
            text-decoration: none;
        }

        .logo i {
            color: #22d3ee;
            text-shadow: 0 0 10px rgba(34, 211, 238, 0.5);
        }

        .login-header h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 1.5rem;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 0.5rem;
        }

        .login-header p {
            color: #a1a1aa;
            font-size: 0.875rem;
        }

        .form-group {
            margin-bottom: 1.25rem;
        }

        label {
            display: block;
            font-weight: 600;
            color: #a1a1aa;
            margin-bottom: 0.5rem;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 6px;
            font-size: 0.875rem;
            font-family: inherit;
            background: #1a1a25;
            color: #ffffff;
            transition: all 0.2s ease;
        }

        input[type="email"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: rgba(34, 211, 238, 0.5);
            box-shadow: 0 0 0 3px rgba(34, 211, 238, 0.1), 0 0 20px rgba(34, 211, 238, 0.2);
        }

        input[type="email"]::placeholder,
        input[type="password"]::placeholder {
            color: #71717a;
        }

        .error-message {
            color: #f43f5e;
            font-size: 0.75rem;
            margin-top: 0.375rem;
            display: block;
        }

        .alert {
            background: rgba(244, 63, 94, 0.1);
            border: 1px solid rgba(244, 63, 94, 0.3);
            border-radius: 6px;
            padding: 0.875rem;
            margin-bottom: 1.25rem;
            color: #fda4af;
            font-size: 0.875rem;
        }

        .btn-sign-in {
            width: 100%;
            padding: 0.75rem;
            background: transparent;
            color: #22d3ee;
            border: 1px solid #22d3ee;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.875rem;
            cursor: pointer;
            transition: all 0.2s ease;
            margin-bottom: 1.25rem;
        }

        .btn-sign-in:hover {
            background: rgba(34, 211, 238, 0.1);
            box-shadow: 0 0 20px rgba(34, 211, 238, 0.3), 0 0 40px rgba(34, 211, 238, 0.1);
            text-shadow: 0 0 10px rgba(34, 211, 238, 0.5);
        }

        .divider {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin: 1.25rem 0;
            color: #71717a;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: rgba(255, 255, 255, 0.08);
        }

        .btn-google {
            width: 100%;
            padding: 0.75rem;
            background: #1a1a25;
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.875rem;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.75rem;
            text-decoration: none;
        }

        .btn-google:hover {
            background: #22222e;
            border-color: rgba(255, 255, 255, 0.15);
        }

        .btn-google i {
            font-size: 1rem;
        }

        .login-footer {
            text-align: center;
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            color: #71717a;
            font-size: 0.875rem;
        }

        .login-footer a {
            color: #22d3ee;
            text-decoration: none;
            font-weight: 600;
        }

        .login-footer a:hover {
            text-shadow: 0 0 10px rgba(34, 211, 238, 0.5);
        }

        /* Responsive */
        @media (max-width: 480px) {
            .login-card {
                padding: 1.5rem;
            }

            .login-header h1 {
                font-size: 1.25rem;
            }
        }
    </style>
</head>

<body>
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <a href="/" class="logo">
                    <i class="fas fa-heartbeat"></i>
                </a>
                <h1>Welcome Back</h1>
                <p>Sign in to your health dashboard</p>
            </div>

            @if (session('error'))
                <div class="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>
                    {{ session('error') }}
                </div>
            @endif

            <!-- Email/Password Login Form -->
            <form method="POST" action="{{ route('login') }}">
                @csrf

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" value="{{ old('email') }}" required autofocus
                        autocomplete="email" placeholder="name@example.com">
                    @error('email')
                        <span class="error-message">
                            <i class="fas fa-times-circle"></i> {{ $message }}
                        </span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required autocomplete="current-password"
                        placeholder="Enter your password">
                    @error('password')
                        <span class="error-message">
                            <i class="fas fa-times-circle"></i> {{ $message }}
                        </span>
                    @enderror
                </div>

                <button type="submit" class="btn-sign-in">
                    <i class="fas fa-sign-in-alt"></i> Sign In
                </button>
            </form>

            <div class="divider">or continue with</div>

            <!-- Google Sign-In Button -->
            <a href="{{ route('google.login') }}" class="btn-google">
                <i class="fab fa-google"></i>
                Sign in with Google
            </a>

            <!-- Footer -->
            <div class="login-footer">
                Don't have an account? <a href="{{ route('register') }}">Create one</a>
            </div>
        </div>
    </div>

    <script>
        // Initialize theme on page load
        document.addEventListener('DOMContentLoaded', function () {
            const savedTheme = localStorage.getItem('theme');
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            const theme = savedTheme || (prefersDark ? 'dark' : 'light');

            document.documentElement.setAttribute('data-theme', theme);
        });
    </script>
</body>

</html>
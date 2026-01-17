<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="color-scheme" content="light dark">

    <title>Create Account - HealthPro</title>

    <!-- Font Awesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Manrope:wght@700;800&display=swap" rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            font-size: 16px;
        }

        html[data-theme="dark"] {
            color-scheme: dark;
        }

        html[data-theme="light"] {
            color-scheme: light;
        }

        @media (prefers-color-scheme: dark) {
            html:not([data-theme="light"]) {
                color-scheme: dark;
            }
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            color: #1e293b;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem;
        }

        [data-theme="dark"] body {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: #cbd5e1;
        }

        .register-container {
            width: 100%;
            max-width: 480px;
        }

        .register-card {
            background: #ffffff;
            border-radius: 0.75rem;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            padding: 2.5rem;
        }

        [data-theme="dark"] .register-card {
            background: #1e293b;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }

        .register-header {
            text-align: center;
            margin-bottom: 2.5rem;
        }

        .logo {
            font-size: 2rem;
            font-weight: 700;
            color: #1e293b;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
            text-decoration: none;
        }

        [data-theme="dark"] .logo {
            color: #ffffff;
        }

        .logo i {
            color: #3b82f6;
        }

        .register-header h1 {
            font-family: 'Manrope', sans-serif;
            font-size: 1.875rem;
            font-weight: 800;
            color: #1e293b;
            margin-bottom: 0.5rem;
        }

        [data-theme="dark"] .register-header h1 {
            color: #ffffff;
        }

        .register-header p {
            color: #64748b;
            font-size: 0.9375rem;
        }

        [data-theme="dark"] .register-header p {
            color: #cbd5e1;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        label {
            display: block;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 0.5rem;
            font-size: 0.9375rem;
        }

        [data-theme="dark"] label {
            color: #ffffff;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid #e2e8f0;
            border-radius: 0.5rem;
            font-size: 0.9375rem;
            font-family: inherit;
            background: #ffffff;
            color: #1e293b;
            transition: all 0.15s;
        }

        [data-theme="dark"] input[type="text"],
        [data-theme="dark"] input[type="email"],
        [data-theme="dark"] input[type="password"] {
            background: #334155;
            border-color: #475569;
            color: #ffffff;
        }

        input[type="text"]:focus,
        input[type="email"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        [data-theme="dark"] input[type="text"]:focus,
        [data-theme="dark"] input[type="email"]:focus,
        [data-theme="dark"] input[type="password"]:focus {
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
        }

        input[type="text"]:invalid,
        input[type="email"]:invalid,
        input[type="password"]:invalid {
            border-color: #ef4444;
        }

        .error-message {
            color: #ef4444;
            font-size: 0.8125rem;
            margin-top: 0.375rem;
            display: block;
        }

        .alert {
            background: #fee2e2;
            border: 1px solid #fecaca;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1.5rem;
            color: #991b1b;
            font-size: 0.9375rem;
        }

        [data-theme="dark"] .alert {
            background: rgba(239, 68, 68, 0.1);
            border-color: rgba(239, 68, 68, 0.2);
            color: #fca5a5;
        }

        .btn-register {
            width: 100%;
            padding: 0.875rem;
            background: #3b82f6;
            color: #ffffff;
            border: none;
            border-radius: 0.5rem;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.15s;
            margin-bottom: 1.5rem;
        }

        .btn-register:hover {
            background: #2563eb;
        }

        .btn-register:active {
            background: #1d4ed8;
        }

        .divider {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin: 1.5rem 0;
            color: #94a3b8;
            font-size: 0.875rem;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e2e8f0;
        }

        [data-theme="dark"] .divider::before,
        [data-theme="dark"] .divider::after {
            background: #334155;
        }

        .btn-google {
            width: 100%;
            padding: 0.875rem;
            background: #ffffff;
            color: #1e293b;
            border: 1px solid #e2e8f0;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.15s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.75rem;
            text-decoration: none;
        }

        [data-theme="dark"] .btn-google {
            background: #334155;
            border-color: #475569;
            color: #ffffff;
        }

        .btn-google:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
        }

        [data-theme="dark"] .btn-google:hover {
            background: #475569;
        }

        .btn-google i {
            font-size: 1.125rem;
        }

        .register-footer {
            text-align: center;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #e2e8f0;
            color: #64748b;
            font-size: 0.9375rem;
        }

        [data-theme="dark"] .register-footer {
            border-top-color: #334155;
            color: #cbd5e1;
        }

        .register-footer a {
            color: #3b82f6;
            text-decoration: none;
            font-weight: 600;
        }

        .register-footer a:hover {
            text-decoration: underline;
        }

        /* Responsive */
        @media (max-width: 480px) {
            .register-card {
                padding: 1.5rem;
            }

            .register-header h1 {
                font-size: 1.5rem;
            }

            .form-group {
                margin-bottom: 1.25rem;
            }
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-card">
            <div class="register-header">
                <a href="/" class="logo">
                    <i class="fas fa-heartbeat"></i>
                </a>
                <h1>Create Account</h1>
                <p>Start tracking your health today</p>
            </div>

            <!-- Registration Form -->
            <form method="POST" action="{{ route('register') }}">
                @csrf

                <div class="form-group">
                    <label for="name">Full Name</label>
                    <input
                        type="text"
                        id="name"
                        name="name"
                        value="{{ old('name') }}"
                        required
                        autofocus
                        autocomplete="name"
                        placeholder="John Doe"
                    >
                    @error('name')
                        <span class="error-message">
                            <i class="fas fa-times-circle"></i> {{ $message }}
                        </span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        value="{{ old('email') }}"
                        required
                        autocomplete="email"
                        placeholder="name@example.com"
                    >
                    @error('email')
                        <span class="error-message">
                            <i class="fas fa-times-circle"></i> {{ $message }}
                        </span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        required
                        autocomplete="new-password"
                        placeholder="Minimum 8 characters"
                    >
                    @error('password')
                        <span class="error-message">
                            <i class="fas fa-times-circle"></i> {{ $message }}
                        </span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="password-confirm">Confirm Password</label>
                    <input
                        type="password"
                        id="password-confirm"
                        name="password_confirmation"
                        required
                        autocomplete="new-password"
                        placeholder="Re-enter your password"
                    >
                    @error('password_confirmation')
                        <span class="error-message">
                            <i class="fas fa-times-circle"></i> {{ $message }}
                        </span>
                    @enderror
                </div>

                <button type="submit" class="btn-register">
                    <i class="fas fa-user-plus"></i> Create Account
                </button>
            </form>

            <div class="divider">or sign up with</div>

            <!-- Google Sign-Up Button -->
            <a href="{{ route('google.login') }}" class="btn-google">
                <i class="fab fa-google"></i>
                Sign up with Google
            </a>

            <!-- Footer -->
            <div class="register-footer">
                Already have an account? <a href="{{ route('login') }}">Sign in</a>
            </div>
        </div>
    </div>

    <script>
        // Initialize theme on page load
        document.addEventListener('DOMContentLoaded', function() {
            const savedTheme = localStorage.getItem('theme');
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            const theme = savedTheme || (prefersDark ? 'dark' : 'light');

            document.documentElement.setAttribute('data-theme', theme);
        });
    </script>
</body>
</html>

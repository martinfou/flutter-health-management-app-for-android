<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="color-scheme" content="light dark">

    <title>Health Management App - Track Your Wellness</title>

    <!-- Font Awesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <!-- Vite Assets -->
    @if (file_exists(public_path('build/manifest.json')) || file_exists(public_path('hot')))
        @vite(['resources/sass/app.scss', 'resources/js/app.js'])
    @endif

    <style>
        /* Critical inline styles to prevent FOUC */
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

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            color: #1e293b;
            background-color: #ffffff;
            line-height: 1.6;
        }

        [data-theme="dark"] body {
            color: #cbd5e1;
            background-color: #0f172a;
        }

        /* Header / Navigation */
        header {
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            padding: 1.5rem 2rem;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        [data-theme="dark"] header {
            background: #1e293b;
            border-bottom-color: #334155;
        }

        .header-container {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 2rem;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e293b;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        [data-theme="dark"] .logo {
            color: #ffffff;
        }

        .logo i {
            color: #3b82f6;
            font-size: 1.75rem;
        }

        nav {
            display: flex;
            gap: 2rem;
            align-items: center;
        }

        nav a {
            color: #64748b;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.15s;
        }

        [data-theme="dark"] nav a {
            color: #cbd5e1;
        }

        nav a:hover {
            color: #3b82f6;
        }

        .nav-buttons {
            display: flex;
            gap: 1rem;
            align-items: center;
        }

        .btn {
            padding: 0.625rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.15s;
            border: none;
            cursor: pointer;
            font-size: 0.9375rem;
        }

        .btn-primary {
            background: #3b82f6;
            color: #ffffff;
        }

        .btn-primary:hover {
            background: #2563eb;
        }

        .btn-outline {
            border: 1px solid #e2e8f0;
            color: #1e293b;
            background: transparent;
        }

        [data-theme="dark"] .btn-outline {
            border-color: #334155;
            color: #ffffff;
        }

        .btn-outline:hover {
            background: #f8fafc;
        }

        [data-theme="dark"] .btn-outline:hover {
            background: #334155;
        }

        /* Theme Toggle */
        .theme-toggle {
            background: none;
            border: none;
            font-size: 1.25rem;
            cursor: pointer;
            color: #64748b;
            display: flex;
            align-items: center;
        }

        [data-theme="dark"] .theme-toggle {
            color: #cbd5e1;
        }

        /* Main Content */
        main {
            max-width: 1400px;
            margin: 0 auto;
            padding: 3rem 2rem;
        }

        /* Hero Section */
        .hero {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
            margin-bottom: 6rem;
        }

        .hero-content h1 {
            font-family: 'Manrope', sans-serif;
            font-size: 3.5rem;
            font-weight: 800;
            color: #1e293b;
            margin-bottom: 1rem;
            line-height: 1.2;
        }

        [data-theme="dark"] .hero-content h1 {
            color: #ffffff;
        }

        .hero-content p {
            font-size: 1.25rem;
            color: #64748b;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        [data-theme="dark"] .hero-content p {
            color: #cbd5e1;
        }

        .hero-buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .hero-image {
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            border-radius: 1rem;
            padding: 3rem;
            color: #ffffff;
            text-align: center;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 400px;
        }

        [data-theme="dark"] .hero-image {
            background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
        }

        .hero-image i {
            font-size: 6rem;
            margin-bottom: 2rem;
            opacity: 0.8;
        }

        .hero-image h2 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        /* Features Section */
        .features {
            margin-bottom: 6rem;
        }

        .section-header {
            text-align: center;
            margin-bottom: 4rem;
        }

        .section-header h2 {
            font-family: 'Manrope', sans-serif;
            font-size: 2.5rem;
            font-weight: 800;
            color: #1e293b;
            margin-bottom: 1rem;
        }

        [data-theme="dark"] .section-header h2 {
            color: #ffffff;
        }

        .section-header p {
            font-size: 1.125rem;
            color: #64748b;
            max-width: 600px;
            margin: 0 auto;
        }

        [data-theme="dark"] .section-header p {
            color: #cbd5e1;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 2rem;
        }

        .feature-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 0.75rem;
            padding: 2rem;
            transition: all 0.15s;
        }

        [data-theme="dark"] .feature-card {
            background: #1e293b;
            border-color: #334155;
        }

        .feature-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            transform: translateY(-2px);
        }

        [data-theme="dark"] .feature-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }

        .feature-icon {
            width: 3rem;
            height: 3rem;
            background: #eff6ff;
            border-radius: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: #3b82f6;
            margin-bottom: 1rem;
        }

        [data-theme="dark"] .feature-icon {
            background: #334155;
        }

        .feature-card h3 {
            font-family: 'Manrope', sans-serif;
            font-size: 1.25rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 0.75rem;
        }

        [data-theme="dark"] .feature-card h3 {
            color: #ffffff;
        }

        .feature-card p {
            color: #64748b;
            font-size: 0.9375rem;
            line-height: 1.6;
        }

        [data-theme="dark"] .feature-card p {
            color: #cbd5e1;
        }

        /* CTA Section */
        .cta-section {
            background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
            border-radius: 1rem;
            padding: 4rem 2rem;
            text-align: center;
            color: #ffffff;
            margin-bottom: 3rem;
        }

        .cta-section h2 {
            font-family: 'Manrope', sans-serif;
            font-size: 2rem;
            font-weight: 800;
            margin-bottom: 1rem;
        }

        .cta-section p {
            font-size: 1.125rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }

        .cta-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .cta-btn {
            padding: 0.875rem 2rem;
            border-radius: 0.5rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s;
            border: none;
            cursor: pointer;
            font-size: 1rem;
        }

        .cta-btn-primary {
            background: #3b82f6;
            color: #ffffff;
        }

        .cta-btn-primary:hover {
            background: #2563eb;
        }

        .cta-btn-secondary {
            background: transparent;
            color: #ffffff;
            border: 2px solid #ffffff;
        }

        .cta-btn-secondary:hover {
            background: #ffffff;
            color: #1e293b;
        }

        /* Footer */
        footer {
            background: #f8fafc;
            border-top: 1px solid #e2e8f0;
            padding: 3rem 2rem;
            text-align: center;
            color: #64748b;
        }

        [data-theme="dark"] footer {
            background: #1e293b;
            border-top-color: #334155;
            color: #94a3b8;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .hero {
                grid-template-columns: 1fr;
                gap: 2rem;
            }

            .hero-content h1 {
                font-size: 2.25rem;
            }

            .hero-content p {
                font-size: 1rem;
            }

            .hero-buttons {
                flex-direction: column;
            }

            .hero-buttons .btn {
                width: 100%;
                text-align: center;
            }

            nav {
                flex-wrap: wrap;
                gap: 1rem;
            }

            .section-header h2 {
                font-size: 1.875rem;
            }

            .cta-section {
                padding: 2rem 1rem;
            }

            .cta-section h2 {
                font-size: 1.5rem;
            }

            .cta-buttons {
                flex-direction: column;
            }

            .cta-buttons .cta-btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <div class="header-container">
            <a href="/" class="logo">
                <i class="fas fa-heartbeat"></i>
                HealthPro
            </a>

            <nav>
                <a href="#features">Features</a>
                <a href="#about">About</a>
            </nav>

            <div class="nav-buttons">
                <button class="theme-toggle" onclick="toggleTheme()">
                    <i class="fas fa-moon"></i>
                </button>
                @auth
                    <a href="{{ url('/dashboard') }}" class="btn btn-primary">Dashboard</a>
                @else
                    <a href="{{ route('login') }}" class="btn btn-outline">Sign In</a>
                    @if (Route::has('register'))
                        <a href="{{ route('register') }}" class="btn btn-primary">Get Started</a>
                    @endif
                @endauth
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main>
        <!-- Hero Section -->
        <section class="hero">
            <div class="hero-content">
                <h1>Take Control of Your Health</h1>
                <p>Track your nutrition, exercise, and vital health metrics in one beautiful, intuitive dashboard. Get insights that help you achieve your wellness goals.</p>
                <div class="hero-buttons">
                    @auth
                        <a href="{{ url('/dashboard') }}" class="btn btn-primary">Go to Dashboard</a>
                    @else
                        <a href="{{ route('register') }}" class="btn btn-primary">Start Free</a>
                        <a href="{{ route('login') }}" class="btn btn-outline">Sign In</a>
                    @endauth
                </div>
            </div>

            <div class="hero-image">
                <i class="fas fa-chart-line"></i>
                <h2>Monitor Your Progress</h2>
                <p style="margin-top: 1rem; opacity: 0.9; font-size: 1rem;">Real-time insights into your health metrics</p>
            </div>
        </section>

        <!-- Features Section -->
        <section id="features" class="features">
            <div class="section-header">
                <h2>Powerful Health Tracking Features</h2>
                <p>Everything you need to understand and improve your health in one place</p>
            </div>

            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-utensils"></i>
                    </div>
                    <h3>Nutrition Tracking</h3>
                    <p>Log meals and track calories, protein, carbs, and fat intake. Monitor your macros to meet your goals.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-dumbbell"></i>
                    </div>
                    <h3>Exercise Logging</h3>
                    <p>Record workouts and track intensity levels, duration, and calories burned during activities.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-heartbeat"></i>
                    </div>
                    <h3>Health Metrics</h3>
                    <p>Monitor weight, sleep, heart rate, steps, and more. See trends over time with visual charts.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-chart-bar"></i>
                    </div>
                    <h3>Analytics Dashboard</h3>
                    <p>Beautiful visualizations of your health data. Compare metrics and identify patterns.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-moon"></i>
                    </div>
                    <h3>Dark Mode</h3>
                    <p>Easy on the eyes with full dark mode support. Switch anytime with a single click.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-mobile-alt"></i>
                    </div>
                    <h3>Responsive Design</h3>
                    <p>Access your health data anywhere. Perfect experience on desktop, tablet, and mobile.</p>
                </div>
            </div>
        </section>

        <!-- CTA Section -->
        <section class="cta-section">
            <h2>Ready to Transform Your Health?</h2>
            <p>Join thousands of users tracking their wellness journey every day</p>
            <div class="cta-buttons">
                @auth
                    <a href="{{ url('/dashboard') }}" class="cta-btn cta-btn-primary">View Dashboard</a>
                @else
                    <a href="{{ route('register') }}" class="cta-btn cta-btn-primary">Create Free Account</a>
                    <a href="{{ route('login') }}" class="cta-btn cta-btn-secondary">Sign In</a>
                @endauth
            </div>
        </section>
    </main>

    <!-- Footer -->
    <footer>
        <p>&copy; {{ date('Y') }} HealthPro. All rights reserved. Built with care for your wellness.</p>
    </footer>

    <script>
        function toggleTheme() {
            const html = document.documentElement;
            const currentTheme = html.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

            html.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);

            // Update icon
            const icon = document.querySelector('.theme-toggle i');
            icon.classList.remove(currentTheme === 'dark' ? 'fa-moon' : 'fa-sun');
            icon.classList.add(newTheme === 'dark' ? 'fa-moon' : 'fa-sun');
        }

        // Initialize theme on page load
        document.addEventListener('DOMContentLoaded', function() {
            const savedTheme = localStorage.getItem('theme');
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            const theme = savedTheme || (prefersDark ? 'dark' : 'light');

            document.documentElement.setAttribute('data-theme', theme);

            // Set icon
            const icon = document.querySelector('.theme-toggle i');
            if (theme === 'dark') {
                icon.classList.remove('fa-moon');
                icon.classList.add('fa-sun');
            }
        });
    </script>
</body>
</html>

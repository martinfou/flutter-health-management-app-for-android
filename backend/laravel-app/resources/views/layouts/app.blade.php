<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="color-scheme" content="light dark">
    <title>{{ config('app.name', 'Health Management') }}</title>

    <!-- Font Awesome Icons (via CDN for quick access) -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <!-- Vite - Compiles SCSS and JavaScript -->
    @vite(['resources/sass/app.scss', 'resources/js/app.js'])

    <style>
        /* Critical inline styles to prevent flash of unstyled content (FOUC) */
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
    </style>
</head>
<body>
    @auth
        <!-- Clinical Pro Navbar -->
        @component('components.clinical-navbar', ['title' => $page_title ?? 'Dashboard'])
        @endcomponent

        <!-- Clinical Pro Sidebar -->
        @component('components.clinical-sidebar')
        @endcomponent

        <!-- Main Content Area -->
        <main class="clinical-main-content">
            <div class="container-fluid">
                <!-- Breadcrumbs (if provided) -->
                @if(isset($breadcrumbs))
                    @component('components.clinical-breadcrumbs', ['items' => $breadcrumbs])
                    @endcomponent
                @endif

                <!-- Page Content -->
                @yield('content')
            </div>
        </main>
    @else
        <!-- Guest Layout (for auth pages) -->
        <main>
            @yield('content')
        </main>
    @endauth

    <!-- Additional Scripts -->
    @stack('scripts')

    <script>
        // Ensure Clinical Pro modules are available
        console.log('Clinical Pro loaded:', window.ClinicalPro);
    </script>
</body>
</html>

<style>
/* Main Content Area Adjustments for sidebar + navbar layout */
.clinical-main-content {
    margin-left: 250px;
    margin-top: 64px;
    min-height: calc(100vh - 64px);
    padding: 2rem 0;
}

/* Mobile Responsive */
@media (max-width: 768px) {
    .clinical-main-content {
        margin-left: 0;
        padding: 1rem 0;
    }
}

/* Dark Mode Support */
@media (prefers-color-scheme: dark) {
    :root {
        color-scheme: dark;
    }
}
</style>

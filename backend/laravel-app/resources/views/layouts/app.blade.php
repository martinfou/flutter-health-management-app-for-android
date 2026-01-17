<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" data-theme="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="color-scheme" content="dark">
    <title>{{ config('app.name', 'Health Management') }}</title>

    <!-- Google Fonts: Outfit + JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Outfit:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <!-- Font Awesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <!-- Vite - Compiles SCSS and JavaScript -->
    @vite(['resources/sass/app.scss', 'resources/js/app.js'])
</head>
<body>
    @auth
        <!-- Obsidian Sidebar (Collapsible) -->
        @component('components.clinical-sidebar')
        @endcomponent

        <!-- Obsidian Navbar -->
        @component('components.clinical-navbar', ['title' => $page_title ?? 'Dashboard'])
        @endcomponent

        <!-- Main Content Area -->
        <main class="obsidian-main">
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
        // Obsidian sidebar hover expand
        const sidebar = document.querySelector('.obsidian-sidebar');
        if (sidebar) {
            // Mobile toggle
            document.querySelectorAll('[data-sidebar-toggle]').forEach(btn => {
                btn.addEventListener('click', () => {
                    sidebar.classList.toggle('open');
                    document.querySelector('.obsidian-overlay')?.classList.toggle('visible');
                });
            });
        }
    </script>
</body>
</html>


<!-- Obsidian Sidebar Component (Collapsible) -->
<aside class="obsidian-sidebar" data-sidebar>
    <!-- Sidebar Brand -->
    <div class="sidebar-brand">
        <a href="{{ route('dashboard') }}" class="brand-icon" title="Dashboard">
            <i class="fas fa-heartbeat"></i>
        </a>
        <span class="brand-text">OBSIDIAN</span>
    </div>

    <!-- Sidebar Navigation -->
    <nav class="sidebar-nav">
        <!-- Dashboard -->
        <a href="{{ route('dashboard') }}" class="nav-item {{ request()->routeIs('dashboard') ? 'active' : '' }}"
            title="Dashboard">
            <i class="fas fa-tachometer-alt nav-icon"></i>
            <span class="nav-label">Dashboard</span>
        </a>

        <!-- Health Metrics -->
        <a href="{{ route('health-metrics') }}"
            class="nav-item {{ request()->routeIs('health-metrics') ? 'active' : '' }}" title="Health Metrics">
            <i class="fas fa-heart nav-icon"></i>
            <span class="nav-label">Health Metrics</span>
        </a>

        <!-- Meals -->
        <a href="{{ route('meals') }}" class="nav-item {{ request()->routeIs('meals') ? 'active' : '' }}" title="Meals">
            <i class="fas fa-utensils nav-icon"></i>
            <span class="nav-label">Meals</span>
        </a>

        <!-- Exercises -->
        <a href="{{ route('exercises') }}" class="nav-item {{ request()->routeIs('exercises') ? 'active' : '' }}"
            title="Exercises">
            <i class="fas fa-dumbbell nav-icon"></i>
            <span class="nav-label">Exercises</span>
        </a>

        <!-- Profile -->
        <a href="{{ route('profile') }}" class="nav-item {{ request()->routeIs('profile') ? 'active' : '' }}"
            title="Profile">
            <i class="fas fa-user nav-icon"></i>
            <span class="nav-label">Profile</span>
        </a>
    </nav>

    <!-- Sidebar Footer -->
    <div class="sidebar-footer">
        <small>PRO ANALYTICS v2.1</small>
    </div>
</aside>

<!-- Mobile Overlay -->
<div class="obsidian-overlay" data-sidebar-overlay></div>

<style>
    /* Obsidian overlay for mobile */
    .obsidian-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.7);
        z-index: 99;
        display: none;
        backdrop-filter: blur(4px);
    }

    .obsidian-overlay.visible {
        display: block;
    }
</style>
<!-- Clinical Pro Sidebar Component -->
<aside class="clinical-sidebar" data-sidebar>
    <!-- Sidebar Header -->
    <div class="sidebar-header">
        <a href="{{ route('dashboard') }}" class="brand-logo" title="Clinical Dashboard">
            <i class="fas fa-heartbeat"></i>
            <span class="brand-text">Clinical</span>
        </a>
        <button class="sidebar-toggle-mobile d-md-none" data-sidebar-toggle aria-label="Toggle sidebar">
            <i class="fas fa-times"></i>
        </button>
    </div>

    <!-- Sidebar Navigation -->
    <nav class="sidebar-nav">
        <!-- Dashboard -->
        <a href="{{ route('dashboard') }}"
           class="nav-item {{ request()->routeIs('dashboard') ? 'active' : '' }}"
           title="Dashboard">
            <i class="fas fa-tachometer-alt"></i>
            <span class="nav-label">Dashboard</span>
        </a>

        <!-- Health Metrics -->
        <a href="{{ route('health-metrics') }}"
           class="nav-item {{ request()->routeIs('health-metrics') ? 'active' : '' }}"
           title="Health Metrics">
            <i class="fas fa-heart"></i>
            <span class="nav-label">Health Metrics</span>
        </a>

        <!-- Meals -->
        <a href="{{ route('meals') }}"
           class="nav-item {{ request()->routeIs('meals') ? 'active' : '' }}"
           title="Meals">
            <i class="fas fa-utensils"></i>
            <span class="nav-label">Meals</span>
        </a>

        <!-- Exercises -->
        <a href="{{ route('exercises') }}"
           class="nav-item {{ request()->routeIs('exercises') ? 'active' : '' }}"
           title="Exercises">
            <i class="fas fa-dumbbell"></i>
            <span class="nav-label">Exercises</span>
        </a>

        <!-- Profile -->
        <a href="{{ route('profile') }}"
           class="nav-item {{ request()->routeIs('profile') ? 'active' : '' }}"
           title="Profile">
            <i class="fas fa-user"></i>
            <span class="nav-label">Profile</span>
        </a>
    </nav>

    <!-- Sidebar Footer -->
    <div class="sidebar-footer">
        <div class="sidebar-version">
            <small class="text-muted">v1.0.0</small>
        </div>
    </div>
</aside>

<!-- Sidebar Overlay (for mobile) -->
<div class="sidebar-overlay" data-sidebar-overlay></div>

<style>
/* Clinical Pro Sidebar Styles (inline for now, will move to SCSS) */
.clinical-sidebar {
    position: fixed;
    left: 0;
    top: 0;
    width: 250px;
    height: 100vh;
    background: var(--bs-body-bg);
    border-right: 1px solid var(--bs-border-color);
    display: flex;
    flex-direction: column;
    z-index: 99;
    transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    margin-top: 64px; /* Account for navbar */
}

.sidebar-header {
    padding: 1.5rem 1rem;
    border-bottom: 1px solid var(--bs-border-color);
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.brand-logo {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    color: #1e293b;
    text-decoration: none;
    font-weight: 700;
    font-size: 1.125rem;
}

.brand-logo i {
    font-size: 1.5rem;
}

.sidebar-toggle-mobile {
    background: none;
    border: none;
    font-size: 1.25rem;
    cursor: pointer;
    color: #1e293b;
    padding: 0.25rem;
}

.sidebar-nav {
    flex: 1;
    overflow-y: auto;
    padding: 1rem 0;
}

.nav-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1rem;
    color: #64748b;
    text-decoration: none;
    transition: all 0.15ms cubic-bezier(0.4, 0, 0.2, 1);
    border-left: 3px solid transparent;
}

.nav-item:hover {
    background-color: #f1f5f9;
    color: #1e293b;
}

.nav-item.active {
    background-color: #e2e8f0;
    color: #1e293b;
    border-left-color: #3b82f6;
    font-weight: 600;
}

.nav-item i {
    width: 1.5rem;
    text-align: center;
}

.nav-label {
    font-size: 0.9375rem;
}

.sidebar-footer {
    padding: 1rem;
    border-top: 1px solid var(--bs-border-color);
}

.sidebar-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    z-index: 98;
    display: none;
}

.sidebar-overlay.visible {
    display: block;
}

/* Mobile Responsive */
@media (max-width: 768px) {
    .clinical-sidebar {
        transform: translateX(-100%);
        width: 280px;
    }

    .clinical-sidebar.sidebar-open {
        transform: translateX(0);
    }

    .sidebar-overlay.visible {
        display: block;
    }
}

/* Dark Mode */
@media (prefers-color-scheme: dark),
[data-theme="dark"] {
    .clinical-sidebar {
        background: #1e293b;
        border-right-color: #334155;
    }

    .brand-logo {
        color: #ffffff;
    }

    .sidebar-toggle-mobile {
        color: #ffffff;
    }

    .nav-item {
        color: #cbd5e1;
    }

    .nav-item:hover {
        background-color: #334155;
        color: #ffffff;
    }

    .nav-item.active {
        background-color: #0f172a;
        color: #ffffff;
        border-left-color: #60a5fa;
    }

    .sidebar-footer {
        border-top-color: #334155;
    }
}
</style>

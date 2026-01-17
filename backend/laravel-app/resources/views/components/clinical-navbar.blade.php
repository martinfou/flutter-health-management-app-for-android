<!-- Clinical Pro Navbar Component -->
<nav class="clinical-navbar navbar navbar-expand-lg navbar-light bg-light border-bottom sticky-top">
    <div class="container-fluid">
        <!-- Navbar Brand / Sidebar Toggle -->
        <button class="navbar-toggler d-md-none me-2" type="button" data-sidebar-toggle aria-label="Toggle sidebar">
            <i class="fas fa-bars"></i>
        </button>

        <!-- Navbar Center (Title / Breadcrumbs) -->
        <div class="navbar-title me-auto">
            <span class="navbar-text">{{ $title ?? 'Dashboard' }}</span>
        </div>

        <!-- Navbar Right (Actions) -->
        <div class="navbar-actions ms-auto d-flex align-items-center gap-2">
            <!-- Dark Mode Toggle -->
            <button class="btn btn-icon"
                    data-dark-mode-toggle
                    x-data="darkModeComponent()"
                    @click="toggle()"
                    :aria-pressed="isDark"
                    title="Toggle dark mode">
                <i class="fas fa-moon"></i>
            </button>

            <!-- Notifications (placeholder) -->
            <button class="btn btn-icon" title="Notifications">
                <i class="fas fa-bell"></i>
                <span class="badge badge-danger">0</span>
            </button>

            <!-- User Menu -->
            <div class="dropdown">
                <button class="btn btn-icon dropdown-toggle" type="button" data-bs-toggle="dropdown">
                    <i class="fas fa-user-circle"></i>
                </button>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li>
                        <a class="dropdown-item" href="{{ route('profile') }}">
                            <i class="fas fa-user me-2"></i> Profile
                        </a>
                    </li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <form method="POST" action="{{ route('logout') }}" class="d-inline">
                            @csrf
                            <button type="submit" class="dropdown-item">
                                <i class="fas fa-sign-out-alt me-2"></i> Logout
                            </button>
                        </form>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</nav>

<style>
/* Clinical Pro Navbar Styles (inline for now, will move to SCSS) */
.clinical-navbar {
    background-color: var(--bs-body-bg);
    border-bottom: 1px solid var(--bs-border-color);
    padding: 0.75rem 0;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 20;
    box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

.navbar-title {
    font-size: 1.125rem;
    font-weight: 600;
    color: #1e293b;
}

.navbar-actions {
    display: flex;
    align-items: center;
    gap: 1rem;
}

.btn-icon {
    background: none;
    border: none;
    color: #64748b;
    font-size: 1.125rem;
    cursor: pointer;
    padding: 0.5rem;
    border-radius: 0.5rem;
    transition: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
}

.btn-icon:hover {
    background-color: #f1f5f9;
    color: #1e293b;
}

.btn-icon:active {
    background-color: #e2e8f0;
}

.btn-icon .badge {
    position: absolute;
    top: 0;
    right: 0;
    font-size: 0.625rem;
    padding: 0.25rem 0.5rem;
}

.badge-danger {
    background-color: #ef4444;
    color: #ffffff;
    border-radius: 9999px;
}

.dropdown-menu {
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.dropdown-item {
    padding: 0.5rem 1rem;
    font-size: 0.9375rem;
}

.dropdown-item:hover {
    background-color: #f1f5f9;
}

/* Main Content Adjustment */
body {
    padding-top: 64px; /* Height of navbar */
    padding-left: 250px; /* Width of sidebar */
}

/* Mobile Responsive */
@media (max-width: 768px) {
    body {
        padding-left: 0;
    }

    .navbar-toggler {
        display: block;
    }
}

/* Dark Mode */
@media (prefers-color-scheme: dark),
[data-theme="dark"] {
    .clinical-navbar {
        background-color: #1e293b;
        border-bottom-color: #334155;
    }

    .navbar-title {
        color: #ffffff;
    }

    .btn-icon {
        color: #cbd5e1;
    }

    .btn-icon:hover {
        background-color: #334155;
        color: #ffffff;
    }

    .btn-icon:active {
        background-color: #475569;
    }

    .dropdown-menu {
        background-color: #1e293b;
        border-color: #334155;
    }

    .dropdown-item {
        color: #cbd5e1;
    }

    .dropdown-item:hover {
        background-color: #334155;
    }
}
</style>

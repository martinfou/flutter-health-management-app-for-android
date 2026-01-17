<!-- Obsidian Navbar Component -->
<nav class="obsidian-navbar">
    <!-- Mobile Menu Toggle -->
    <button class="navbar-icon-btn d-md-none me-2" data-sidebar-toggle aria-label="Toggle sidebar">
        <i class="fas fa-bars"></i>
    </button>

    <!-- Page Title -->
    <div class="navbar-title">{{ $title ?? 'Overview' }}</div>

    <!-- Navbar Actions -->
    <div class="navbar-actions">
        <!-- Notifications -->
        <button class="navbar-icon-btn" title="Notifications">
            <i class="fas fa-bell"></i>
        </button>

        <!-- Settings -->
        <button class="navbar-icon-btn" title="Settings">
            <i class="fas fa-cog"></i>
        </button>

        <!-- User Menu -->
        <div class="dropdown">
            <button class="navbar-icon-btn dropdown-toggle" type="button" data-bs-toggle="dropdown"
                aria-label="User menu">
                <i class="fas fa-user-circle"></i>
            </button>
            <ul class="dropdown-menu dropdown-menu-end obsidian-dropdown">
                <li>
                    <a class="dropdown-item" href="{{ route('profile') }}">
                        <i class="fas fa-user me-2"></i> Profile
                    </a>
                </li>
                <li>
                    <hr class="dropdown-divider">
                </li>
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
</nav>

<style>
    /* Obsidian Dropdown Menu */
    .obsidian-dropdown {
        background: var(--obsidian-bg-card, #15151e);
        border: 1px solid var(--obsidian-border, rgba(255, 255, 255, 0.08));
        border-radius: 6px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
        padding: 0.5rem 0;
    }

    .obsidian-dropdown .dropdown-item {
        color: var(--obsidian-text-secondary, #a1a1aa);
        padding: 0.5rem 1rem;
        font-size: 0.875rem;
        transition: all 0.15s ease;
    }

    .obsidian-dropdown .dropdown-item:hover {
        background: var(--obsidian-bg-hover, #22222e);
        color: var(--obsidian-accent, #22d3ee);
    }

    .obsidian-dropdown .dropdown-divider {
        border-color: var(--obsidian-border, rgba(255, 255, 255, 0.08));
        margin: 0.25rem 0;
    }

    /* Dropdown toggle without caret */
    .navbar-icon-btn.dropdown-toggle::after {
        display: none;
    }
</style>
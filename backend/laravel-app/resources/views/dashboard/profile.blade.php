@extends('layouts.app')

@section('content')
<div class="profile-container">
    <!-- Page Header -->
    <div class="page-header mb-4">
        <div class="header-content">
            <h1 class="page-title">
                <i class="fas fa-user me-2"></i>User Profile
            </h1>
            <p class="page-subtitle">Manage your account and health information</p>
        </div>
        <div class="header-actions">
            <a href="{{ route('dashboard') }}" class="btn btn-primary">
                <i class="fas fa-arrow-left me-1"></i> Back to Dashboard
            </a>
        </div>
    </div>

    <!-- Account Information Card -->
    <div class="profile-card mb-4">
        <div class="card-header">
            <i class="fas fa-cog me-2"></i>
            <h2>Account Information</h2>
        </div>
        <div class="card-body">
            <div class="info-grid">
                <div class="info-item">
                    <label class="info-label">Name</label>
                    <div class="info-value">{{ $user->name ?? 'Not set' }}</div>
                </div>
                <div class="info-item">
                    <label class="info-label">Email</label>
                    <div class="info-value">{{ $user->email }}</div>
                </div>
                <div class="info-item">
                    <label class="info-label">Authentication Method</label>
                    <div class="info-value">
                        @if($user->google_id)
                            <span class="badge bg-danger">Google OAuth</span>
                        @else
                            <span class="badge bg-primary">Email/Password</span>
                        @endif
                    </div>
                </div>
                <div class="info-item">
                    <label class="info-label">Member Since</label>
                    <div class="info-value">{{ $user->created_at->format('M d, Y') }}</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Health Profile Card -->
    <div class="profile-card">
        <div class="card-header">
            <i class="fas fa-heartbeat me-2"></i>
            <h2>Health Profile</h2>
        </div>
        <div class="card-body">
            <div class="info-grid">
                <div class="info-item">
                    <label class="info-label">Height</label>
                    <div class="info-value">
                        @if($user->height_cm)
                            <code class="metric-value">{{ $user->height_cm }} cm</code>
                        @else
                            <span class="text-muted">Not set</span>
                        @endif
                    </div>
                </div>
                <div class="info-item">
                    <label class="info-label">Weight</label>
                    <div class="info-value">
                        @if($user->weight_kg)
                            <code class="metric-value">{{ $user->weight_kg }} kg</code>
                        @else
                            <span class="text-muted">Not set</span>
                        @endif
                    </div>
                </div>
                <div class="info-item">
                    <label class="info-label">Activity Level</label>
                    <div class="info-value">
                        @if($user->activity_level)
                            <span class="badge bg-info">{{ ucfirst($user->activity_level) }}</span>
                        @else
                            <span class="text-muted">Not set</span>
                        @endif
                    </div>
                </div>
                <div class="info-item">
                    <label class="info-label">Health Goal</label>
                    <div class="info-value">
                        @if($user->health_goal)
                            <span>{{ ucfirst($user->health_goal) }}</span>
                        @else
                            <span class="text-muted">Not set</span>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* Profile Container */
.profile-container {
    padding: 2rem;
}

/* Page Header */
.page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 2rem;
    margin-bottom: 2rem;
}

.header-content {
    flex: 1;
}

.page-title {
    font-size: 2rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 0.5rem;
    display: flex;
    align-items: center;
}

.page-subtitle {
    font-size: 1rem;
    color: #64748b;
    margin: 0;
}

/* Profile Card */
.profile-card {
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    overflow: hidden;
}

.card-header {
    padding: 1.5rem;
    border-bottom: 1px solid var(--bs-border-color);
    background: #f8fafc;
    display: flex;
    align-items: center;
    gap: 1rem;
}

.card-header h2 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 700;
    color: #1e293b;
}

.card-header i {
    font-size: 1.25rem;
    color: #3b82f6;
}

.card-body {
    padding: 1.5rem;
}

/* Info Grid */
.info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
}

.info-item {
    display: flex;
    flex-direction: column;
}

.info-label {
    font-size: 0.875rem;
    font-weight: 600;
    color: #1e293b;
    text-transform: uppercase;
    letter-spacing: 0.025em;
    margin-bottom: 0.5rem;
}

.info-value {
    font-size: 0.9375rem;
    color: #64748b;
    word-break: break-word;
}

/* Metric Value (monospace) */
.metric-value {
    padding: 0.25rem 0.5rem;
    background: #f1f5f9;
    border-radius: 0.25rem;
    font-family: 'JetBrains Mono', monospace;
    font-weight: 600;
    color: #1e293b;
}

/* Badges */
.badge {
    display: inline-block;
    padding: 0.375rem 0.75rem;
    border-radius: 0.375rem;
    font-size: 0.75rem;
    font-weight: 600;
}

.bg-info {
    background-color: #3b82f6;
    color: #ffffff;
}

.bg-primary {
    background-color: #1e293b;
    color: #ffffff;
}

.bg-danger {
    background-color: #ef4444;
    color: #ffffff;
}

/* Responsive */
@media (max-width: 768px) {
    .profile-container {
        padding: 1rem;
    }

    .page-header {
        flex-direction: column;
        align-items: stretch;
    }

    .page-title {
        font-size: 1.5rem;
    }

    .info-grid {
        grid-template-columns: 1fr;
    }
}

/* Dark Mode */
@media (prefers-color-scheme: dark),
[data-theme="dark"] {
    .page-title {
        color: #ffffff;
    }

    .page-subtitle {
        color: #cbd5e1;
    }

    .profile-card {
        background: #1e293b;
        border-color: #334155;
    }

    .card-header {
        background: #0f172a;
        border-bottom-color: #334155;
    }

    .card-header h2 {
        color: #ffffff;
    }

    .info-label {
        color: #ffffff;
    }

    .info-value {
        color: #cbd5e1;
    }

    .metric-value {
        background: #0f172a;
        color: #93c5fd;
    }
}
</style>
@endsection

@extends('layouts.app')

@section('content')
    <div class="obsidian-main animate-fade-in">
        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h1 class="display-4 fw-bold mb-1 obsidian-glow-text">
                    <i class="fas fa-user-circle me-3 text-cyan"></i>User Profile
                </h1>
                <p class="text-muted lead mb-0">Manage your account and health telemetry settings</p>
            </div>
            <div class="d-flex gap-2">
                <a href="{{ route('dashboard') }}" class="obsidian-btn obsidian-btn-cyan">
                    <i class="fas fa-arrow-left me-2"></i> Dashboard
                </a>
            </div>
        </div>

        <div class="row g-4">
            <!-- Account Information Card -->
            <div class="col-md-6">
                <div class="obsidian-card h-100">
                    <div class="obsidian-card-header">
                        <h5 class="mb-0 fw-bold">
                            <i class="fas fa-shield-alt me-2 text-cyan"></i> Account Security
                        </h5>
                    </div>
                    <div class="p-4">
                        <div class="mb-4">
                            <label class="obsidian-stat-label d-block mb-1">NAME</label>
                            <div class="text-white fs-5 fw-bold">{{ $user->name ?? 'Not set' }}</div>
                        </div>
                        <div class="mb-4">
                            <label class="obsidian-stat-label d-block mb-1">EMAIL ADDRESS</label>
                            <div class="text-cyan fs-6 monospace">{{ $user->email }}</div>
                        </div>
                        <div class="mb-4">
                            <label class="obsidian-stat-label d-block mb-1">AUTHENTICATION METHOD</label>
                            <div>
                                @if($user->google_id)
                                    <span class="badge obsidian-badge-auth-google">
                                        <i class="fab fa-google me-1"></i> Google OAuth
                                    </span>
                                @else
                                    <span class="badge obsidian-badge-auth-email">
                                        <i class="fas fa-envelope me-1"></i> Email / Password
                                    </span>
                                @endif
                            </div>
                        </div>
                        <div>
                            <label class="obsidian-stat-label d-block mb-1">MEMBER SINCE</label>
                            <div class="text-muted small">{{ $user->created_at->format('M d, Y') }}</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Health Profile Card -->
            <div class="col-md-6">
                <div class="obsidian-card h-100">
                    <div class="obsidian-card-header">
                        <h5 class="mb-0 fw-bold">
                            <i class="fas fa-vial me-2 text-cyan"></i> Health Telemetry
                        </h5>
                    </div>
                    <div class="p-4">
                        <div class="row mb-4">
                            <div class="col-6">
                                <label class="obsidian-stat-label d-block mb-1">HEIGHT</label>
                                @if($user->height_cm)
                                    <div class="text-white">
                                        <span class="obsidian-stat-value text-primary fs-4">{{ $user->height_cm }}</span>
                                        <small class="text-muted ms-1">cm</small>
                                    </div>
                                @else
                                    <div class="text-muted">Not set</div>
                                @endif
                            </div>
                            <div class="col-6">
                                <label class="obsidian-stat-label d-block mb-1">CURRENT WEIGHT</label>
                                @if($user->weight_kg)
                                    <div class="text-white">
                                        <span class="obsidian-stat-value text-cyan fs-4">{{ $user->weight_kg }}</span>
                                        <small class="text-muted ms-1">kg</small>
                                    </div>
                                @else
                                    <div class="text-muted">Not set</div>
                                @endif
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="obsidian-stat-label d-block mb-1">ACTIVITY LEVEL</label>
                            @if($user->activity_level)
                                <span class="badge obsidian-badge-activity">
                                    {{ ucfirst($user->activity_level) }}
                                </span>
                            @else
                                <div class="text-muted small italic">Awaiting data...</div>
                            @endif
                        </div>

                        <div>
                            <label class="obsidian-stat-label d-block mb-1">PRIMARY HEALTH GOAL</label>
                            @if($user->health_goal)
                                <div class="obsidian-goal-display">
                                    <i class="fas fa-bullseye me-2 text-cyan"></i>
                                    <span class="text-white fw-bold">{{ ucfirst($user->health_goal) }}</span>
                                </div>
                            @else
                                <div class="text-muted small italic">Goal not established.</div>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        .obsidian-badge-auth-google {
            background: rgba(239, 68, 68, 0.1);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        .obsidian-badge-auth-email {
            background: rgba(34, 211, 238, 0.1);
            color: #22d3ee;
            border: 1px solid rgba(34, 211, 238, 0.2);
        }

        .obsidian-badge-activity {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .obsidian-goal-display {
            background: rgba(34, 211, 238, 0.05);
            padding: 12px 20px;
            border-radius: 8px;
            border-left: 3px solid var(--obsidian-cyan);
        }

        .monospace {
            font-family: 'JetBrains Mono', monospace;
        }
    </style>
@endsection
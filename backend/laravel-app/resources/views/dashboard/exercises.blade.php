@extends('layouts.app')

@section('content')
    <div class="obsidian-main animate-fade-in">
        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h1 class="display-4 fw-bold mb-1 obsidian-glow-text">
                    <i class="fas fa-dumbbell me-3 text-cyan"></i>Exercises
                </h1>
                <p class="text-muted lead mb-0">Track your workouts and fitness activities</p>
            </div>
            <div class="d-flex gap-2">
                <a href="{{ route('exercises') }}" class="obsidian-btn obsidian-btn-outline">
                    <i class="fas fa-sync-alt"></i>
                </a>
                <a href="{{ route('dashboard') }}" class="obsidian-btn obsidian-btn-cyan">
                    <i class="fas fa-arrow-left me-2"></i> Dashboard
                </a>
            </div>
        </div>

        <!-- Exercises Card -->
        <div class="obsidian-card">
            <div class="obsidian-card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0 fw-bold">
                    <i class="fas fa-running me-2 text-cyan"></i> Activity Log
                </h5>
                <span class="obsidian-stat-label">{{ $exercises->total() }} Workouts</span>
            </div>
            <div class="p-0">
                @if($exercises->count() > 0)
                    <div class="table-responsive">
                        <table class="table obsidian-table mb-0" id="exercisesTable">
                            <thead>
                                <tr>
                                    <th>DATE</th>
                                    <th>EXERCISE NAME</th>
                                    <th>TYPE</th>
                                    <th>DURATION</th>
                                    <th>CALORIES</th>
                                    <th>INTENSITY</th>
                                    <th>NOTES</th>
                                    <th class="text-end">ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($exercises as $exercise)
                                    <tr>
                                        <td class="fw-bold text-white">
                                            {{ $exercise->date ? $exercise->date->format('M d, Y') : '-' }}
                                        </td>
                                        <td>
                                            <span class="text-white fw-bold">{{ $exercise->name }}</span>
                                        </td>
                                        <td>
                                            <span class="badge obsidian-badge-type-exercise">
                                                {{ ucfirst($exercise->type ?? 'Other') }}
                                            </span>
                                        </td>
                                        <td>
                                            @if($exercise->duration_minutes)
                                                <span
                                                    class="obsidian-stat-value text-primary fs-6">{{ $exercise->duration_minutes }}</span>
                                                <small class="text-muted ms-1">min</small>
                                            @else
                                                <span class="text-muted">-</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($exercise->calories_burned)
                                                <span
                                                    class="obsidian-stat-value text-warning fs-6">{{ $exercise->calories_burned }}</span>
                                                <small class="text-muted ms-1">cal</small>
                                            @else
                                                <span class="text-muted">-</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($exercise->intensity ?? null)
                                                <span class="badge obsidian-badge-intensity-{{ strtolower($exercise->intensity) }}">
                                                    {{ ucfirst($exercise->intensity) }}
                                                </span>
                                            @else
                                                <span class="text-muted">-</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($exercise->notes)
                                                <span class="text-muted small" title="{{ $exercise->notes }}">
                                                    {{ Str::limit($exercise->notes, 30) }}
                                                </span>
                                            @else
                                                <span class="text-muted">-</span>
                                            @endif
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-2">
                                                <button class="obsidian-icon-btn text-cyan" title="View Details">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button class="obsidian-icon-btn text-muted" title="Edit">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="p-4 border-top border-white-5">
                        {{ $exercises->links('pagination::bootstrap-5') }}
                    </div>
                @else
                    <div class="text-center py-5">
                        <div class="obsidian-icon-glow mx-auto mb-4">
                            <i class="fas fa-dumbbell fa-3x text-cyan"></i>
                        </div>
                        <h3 class="fw-bold text-white">No exercises logged yet</h3>
                        <p class="text-muted mb-4">Start tracking your fitness by logging your first workout</p>
                        <a href="{{ route('dashboard') }}" class="obsidian-btn obsidian-btn-cyan px-4">
                            <i class="fas fa-plus me-2"></i> Log First Workout
                        </a>
                    </div>
                @endif
            </div>
        </div>
    </div>

    <style>
        .obsidian-badge-type-exercise {
            background: rgba(59, 130, 246, 0.1);
            color: #3b82f6;
            border: 1px solid rgba(59, 130, 246, 0.2);
        }

        .obsidian-badge-intensity-low {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .obsidian-badge-intensity-medium {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
            border: 1px solid rgba(245, 158, 11, 0.2);
        }

        .obsidian-badge-intensity-high {
            background: rgba(239, 68, 68, 0.1);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        .obsidian-icon-glow {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: rgba(34, 211, 238, 0.05);
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 0 20px rgba(34, 211, 238, 0.1);
            border: 1px solid rgba(34, 211, 238, 0.2);
        }

        .border-white-5 {
            border-color: rgba(255, 255, 255, 0.05) !important;
        }

        /* Override pagination styles for Obsidian theme */
        .pagination {
            margin-bottom: 0;
            gap: 5px;
        }

        .page-link {
            background: var(--obsidian-bg-lighter);
            border: 1px solid var(--obsidian-border);
            color: var(--obsidian-text-muted);
            border-radius: 4px !important;
            padding: 8px 16px;
        }

        .page-link:hover {
            background: var(--obsidian-bg-card);
            color: var(--obsidian-cyan);
            border-color: var(--obsidian-cyan);
        }

        .page-item.active .page-link {
            background: var(--obsidian-cyan);
            border-color: var(--obsidian-cyan);
            color: var(--obsidian-bg-dark);
            box-shadow: 0 0 15px rgba(34, 211, 238, 0.3);
        }
    </style>

    @push('scripts')
        <script type="module">
            import { initDataTables } from '{{ asset("js/modules/tables.js") }}';

            document.addEventListener('DOMContentLoaded', () => {
                if (document.getElementById('exercisesTable')) {
                    // initDataTables('#exercisesTable');
                }
            });
        </script>
    @endpush
@endsection

@endsection
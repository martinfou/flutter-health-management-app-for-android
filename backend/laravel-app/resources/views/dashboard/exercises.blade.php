@extends('layouts.app')

@section('content')
<div class="exercises-container">
    <!-- Page Header -->
    <div class="page-header mb-4">
        <div class="header-content">
            <h1 class="page-title">
                <i class="fas fa-dumbbell me-2"></i>Exercises
            </h1>
            <p class="page-subtitle">Track your workouts and activities</p>
        </div>
        <div class="header-actions">
            <a href="{{ route('exercises') }}" class="btn btn-outline-primary me-2">
                <i class="fas fa-sync-alt"></i> Refresh
            </a>
            <a href="{{ route('dashboard') }}" class="btn btn-primary">
                <i class="fas fa-arrow-left me-1"></i> Back to Dashboard
            </a>
        </div>
    </div>

    <!-- Exercises Card -->
    <div class="exercises-card">
        <div class="card-header">
            <h2>All Exercises</h2>
            <span class="badge badge-info">{{ $exercises->total() }} total</span>
        </div>

        @if($exercises->count() > 0)
            <div class="table-responsive">
                <table class="table table-hover data-table" id="exercisesTable">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Exercise Name</th>
                            <th>Type</th>
                            <th>Duration (min)</th>
                            <th>Calories Burned</th>
                            <th>Intensity</th>
                            <th>Notes</th>
                            <th class="no-sort">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($exercises as $exercise)
                        <tr>
                            <td>
                                <strong>{{ $exercise->date ? $exercise->date->format('M d, Y') : '-' }}</strong>
                            </td>
                            <td>
                                {{ $exercise->name }}
                            </td>
                            <td>
                                <span class="badge bg-info">{{ ucfirst($exercise->type ?? 'Other') }}</span>
                            </td>
                            <td>
                                @if($exercise->duration_minutes)
                                    <code class="metric-value">{{ $exercise->duration_minutes }} min</code>
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                @if($exercise->calories_burned)
                                    <span class="badge bg-warning">{{ $exercise->calories_burned }} cal</span>
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                @if($exercise->intensity ?? null)
                                    <span class="intensity-badge intensity-{{ strtolower($exercise->intensity) }}">
                                        {{ ucfirst($exercise->intensity) }}
                                    </span>
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                @if($exercise->notes)
                                    <small class="text-muted" title="{{ $exercise->notes }}">
                                        {{ Str::limit($exercise->notes, 40) }}
                                    </small>
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="#" class="btn-icon" title="View Details">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <a href="#" class="btn-icon" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div class="pagination-wrapper">
                {{ $exercises->links() }}
            </div>
        @else
            <div class="empty-state">
                <i class="fas fa-dumbbell"></i>
                <h3>No exercises logged yet</h3>
                <p>Start tracking your fitness by logging your first exercise</p>
                <a href="{{ route('dashboard') }}" class="btn btn-primary">
                    <i class="fas fa-plus me-1"></i> Log Exercise
                </a>
            </div>
        @endif
    </div>
</div>

@push('scripts')
<script type="module">
    import { initDataTables } from '{{ asset("js/modules/tables.js") }}';

    document.addEventListener('DOMContentLoaded', () => {
        if (document.getElementById('exercisesTable')) {
            initDataTables('#exercisesTable');
        }
    });
</script>
@endpush

<style>
/* Exercises Container */
.exercises-container {
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

.header-actions {
    display: flex;
    gap: 0.5rem;
}

/* Exercises Card */
.exercises-card {
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    overflow: hidden;
}

.card-header {
    padding: 1.5rem;
    border-bottom: 1px solid var(--bs-border-color);
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #f8fafc;
}

.card-header h2 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 700;
    color: #1e293b;
}

.badge-info {
    background-color: #3b82f6;
    color: #ffffff;
    padding: 0.5rem 1rem;
    border-radius: 9999px;
    font-size: 0.875rem;
}

/* Table */
.table-responsive {
    overflow-x: auto;
}

.table {
    margin-bottom: 0;
    font-size: 0.9375rem;
}

.table thead {
    background: #f1f5f9;
    font-weight: 600;
}

.table th {
    color: #1e293b;
    border-color: var(--bs-border-color);
    padding: 1rem;
    vertical-align: middle;
}

.table td {
    padding: 1rem;
    border-color: var(--bs-border-color);
    vertical-align: middle;
}

.table tbody tr:hover {
    background: #f8fafc;
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
    padding: 0.5rem 0.75rem;
    border-radius: 0.375rem;
    font-size: 0.75rem;
    font-weight: 600;
}

.bg-info {
    background-color: #3b82f6;
}

.bg-warning {
    background-color: #f59e0b;
}

/* Intensity Badge */
.intensity-badge {
    display: inline-block;
    padding: 0.375rem 0.75rem;
    border-radius: 0.375rem;
    font-size: 0.75rem;
    font-weight: 600;
}

.intensity-low {
    background: #d1fae5;
    color: #065f46;
}

.intensity-medium {
    background: #fef3c7;
    color: #92400e;
}

.intensity-high {
    background: #fee2e2;
    color: #7f1d1d;
}

/* Action Buttons */
.action-buttons {
    display: flex;
    gap: 0.5rem;
}

.btn-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    background: none;
    border: none;
    color: #3b82f6;
    cursor: pointer;
    border-radius: 0.375rem;
    transition: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
    text-decoration: none;
}

.btn-icon:hover {
    background: #eff6ff;
    color: #2563eb;
}

.btn-icon:active {
    background: #dbeafe;
}

/* Pagination */
.pagination-wrapper {
    padding: 1.5rem;
    border-top: 1px solid var(--bs-border-color);
    background: #f8fafc;
}

/* Empty State */
.empty-state {
    padding: 3rem 1.5rem;
    text-align: center;
    color: #64748b;
}

.empty-state i {
    font-size: 3rem;
    color: #cbd5e1;
    margin-bottom: 1rem;
    display: block;
}

.empty-state h3 {
    color: #1e293b;
    margin-bottom: 0.5rem;
}

.empty-state p {
    margin-bottom: 1.5rem;
}

/* Responsive */
@media (max-width: 768px) {
    .exercises-container {
        padding: 1rem;
    }

    .page-header {
        flex-direction: column;
        align-items: stretch;
    }

    .header-actions {
        width: 100%;
    }

    .header-actions .btn {
        flex: 1;
    }

    .page-title {
        font-size: 1.5rem;
    }

    .card-header {
        flex-direction: column;
        gap: 1rem;
    }

    .table {
        font-size: 0.875rem;
    }

    .table th,
    .table td {
        padding: 0.75rem;
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

    .card-header {
        background: #0f172a;
    }

    .card-header h2 {
        color: #ffffff;
    }

    .table thead {
        background: #1e293b;
    }

    .table th {
        color: #ffffff;
    }

    .table tbody tr:hover {
        background: #1e293b;
    }

    .metric-value {
        background: #0f172a;
        color: #93c5fd;
    }

    .pagination-wrapper {
        background: #0f172a;
        border-top-color: #334155;
    }

    .empty-state {
        color: #94a3b8;
    }

    .empty-state h3 {
        color: #ffffff;
    }

    .empty-state i {
        color: #475569;
    }
}
</style>
@endsection

@extends('layouts.app')

@section('content')
<div class="dashboard-container">
    <!-- Page Header -->
    <div class="page-header mb-4">
        <h1 class="page-title">Dashboard</h1>
        <p class="page-subtitle">Welcome back, <strong>{{ Auth::user()->name ?? Auth::user()->email }}</strong></p>
    </div>

    <!-- KPI Bar -->
    @component('components.clinical-kpi-bar', [
        'metrics' => [
            [
                'icon' => 'heart',
                'label' => 'Health Metrics',
                'value' => $metricsCount ?? 0,
                'unit' => 'entries',
                'trend' => 5,
                'sparkline' => '0,25,10,15,30,20,25'
            ],
            [
                'icon' => 'utensils',
                'label' => 'Meals Logged',
                'value' => $mealsCount ?? 0,
                'unit' => 'meals',
                'trend' => 2,
                'sparkline' => '0,20,15,25,18,22,28'
            ],
            [
                'icon' => 'dumbbell',
                'label' => 'Workouts',
                'value' => $exercisesCount ?? 0,
                'unit' => 'exercises',
                'trend' => -3,
                'sparkline' => '30,25,20,18,15,22,25'
            ],
            [
                'icon' => 'calendar-check',
                'label' => 'Days Active',
                'value' => $daysActive ?? 0,
                'unit' => 'days',
                'sparkline' => '5,10,8,15,12,18,20'
            ]
        ]
    ])
    @endcomponent

    <!-- Charts Grid -->
    <div class="charts-grid mb-4">
        <!-- Weight Trend Chart -->
        @component('components.clinical-chart-card', [
            'title' => 'Weight Trend',
            'subtitle' => 'Last 30 days',
            'chart_id' => 'weight-trend-chart',
            'chart_config' => $weightChartConfig ?? []
        ])
        @endcomponent

        <!-- Activity Distribution Chart -->
        @component('components.clinical-chart-card', [
            'title' => 'Activity Distribution',
            'subtitle' => 'By type',
            'chart_id' => 'activity-chart',
            'chart_config' => $activityChartConfig ?? []
        ])
        @endcomponent
    </div>

    <!-- User Profile Card -->
    <div class="profile-card mb-4">
        <div class="card-content">
            <div class="profile-header">
                <h3>User Profile</h3>
            </div>
            <div class="profile-info">
                <div class="info-row">
                    <span class="info-label">Name:</span>
                    <span class="info-value">{{ Auth::user()->name ?? 'Not set' }}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Email:</span>
                    <span class="info-value">{{ Auth::user()->email }}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Account Type:</span>
                    <span class="info-value">
                        @if(Auth::user()->google_id)
                            <span class="badge bg-danger">Google OAuth</span>
                        @else
                            <span class="badge bg-primary">Email</span>
                        @endif
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Member Since:</span>
                    <span class="info-value">{{ Auth::user()->created_at->format('M d, Y') }}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Metrics Table -->
    <div class="recent-metrics-card">
        <div class="card-header">
            <h3>Recent Health Metrics</h3>
            <a href="{{ route('health-metrics') }}" class="btn btn-sm btn-primary">
                <i class="fas fa-plus me-1"></i> View All
            </a>
        </div>

        @if($recentMetrics && count($recentMetrics) > 0)
            <div class="table-responsive">
                <table class="table table-sm table-hover data-table" id="recentMetricsTable">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Weight (kg)</th>
                            <th>Sleep (hrs)</th>
                            <th>Steps</th>
                            <th>Notes</th>
                            <th class="no-sort">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($recentMetrics as $metric)
                        <tr>
                            <td><strong>{{ $metric->date->format('M d, Y') }}</strong></td>
                            <td><code class="metric-value">{{ $metric->weight_kg ?? '-' }}</code></td>
                            <td>{{ $metric->sleep_hours ?? '-' }}</td>
                            <td>{{ $metric->steps ? number_format($metric->steps) : '-' }}</td>
                            <td><small class="text-muted">{{ Str::limit($metric->notes ?? '', 50) }}</small></td>
                            <td>
                                <a href="{{ route('health-metrics') }}" class="btn btn-icon-sm" title="View">
                                    <i class="fas fa-eye"></i>
                                </a>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @else
            <div class="empty-state">
                <i class="fas fa-chart-line"></i>
                <p>No health metrics yet. Start tracking your health!</p>
                <a href="{{ route('health-metrics') }}" class="btn btn-primary">
                    <i class="fas fa-plus me-2"></i> Add Your First Metric
                </a>
            </div>
        @endif
    </div>
</div>

@push('scripts')
<script type="module">
    import { initCharts } from '{{ asset("js/modules/charts.js") }}';
    import { initDataTables } from '{{ asset("js/modules/tables.js") }}';

    document.addEventListener('DOMContentLoaded', () => {
        // Initialize charts
        if (document.getElementById('weight-trend-chart') || document.getElementById('activity-chart')) {
            initCharts();
        }

        // Initialize data table
        if (document.getElementById('recentMetricsTable')) {
            initDataTables('#recentMetricsTable');
        }
    });
</script>
@endpush

<style>
/* Dashboard Container */
.dashboard-container {
    padding: 2rem;
}

/* Page Header */
.page-header {
    margin-bottom: 2rem;
}

.page-title {
    font-size: 2rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 0.5rem;
}

.page-subtitle {
    font-size: 1rem;
    color: #64748b;
    margin: 0;
}

/* Charts Grid */
.charts-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 1.5rem;
}

/* Profile Card */
.profile-card {
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    overflow: hidden;
}

.card-content {
    padding: 1.5rem;
}

.profile-header {
    border-bottom: 1px solid var(--bs-border-color);
    padding-bottom: 1rem;
    margin-bottom: 1rem;
}

.profile-header h3 {
    margin: 0;
    font-size: 1.125rem;
    font-weight: 700;
    color: #1e293b;
}

.profile-info {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1rem;
}

.info-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem 0;
    border-bottom: 1px solid #f1f5f9;
}

.info-row:last-child {
    border-bottom: none;
}

.info-label {
    font-weight: 600;
    color: #1e293b;
    font-size: 0.9375rem;
}

.info-value {
    color: #64748b;
    font-size: 0.9375rem;
}

/* Recent Metrics Card */
.recent-metrics-card {
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
}

.card-header h3 {
    margin: 0;
    font-size: 1.125rem;
    font-weight: 700;
    color: #1e293b;
}

.table-responsive {
    overflow-x: auto;
}

.table {
    margin-bottom: 0;
    font-size: 0.9375rem;
}

.table thead {
    background: #f8fafc;
    font-weight: 600;
}

.table th {
    color: #1e293b;
    border-color: var(--bs-border-color);
    padding: 1rem;
}

.table td {
    padding: 1rem;
    border-color: var(--bs-border-color);
}

.table tbody tr:hover {
    background: #f8fafc;
}

.metric-value {
    padding: 0.25rem 0.5rem;
    background: #f1f5f9;
    border-radius: 0.25rem;
    font-family: 'JetBrains Mono', monospace;
    font-weight: 600;
}

.btn-icon-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
    background: none;
    border: none;
    color: #3b82f6;
    cursor: pointer;
}

.btn-icon-sm:hover {
    color: #2563eb;
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

/* Responsive */
@media (max-width: 768px) {
    .dashboard-container {
        padding: 1rem;
    }

    .page-title {
        font-size: 1.5rem;
    }

    .charts-grid {
        grid-template-columns: 1fr;
    }

    .profile-info {
        grid-template-columns: 1fr;
    }

    .card-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 1rem;
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

    .profile-header h3,
    .card-header h3 {
        color: #ffffff;
    }

    .info-label {
        color: #ffffff;
    }

    .info-value {
        color: #cbd5e1;
    }

    .table thead {
        background: #0f172a;
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

    .empty-state {
        color: #94a3b8;
    }

    .empty-state i {
        color: #475569;
    }
}
</style>
@endsection

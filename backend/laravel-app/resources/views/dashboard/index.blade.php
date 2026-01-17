@extends('layouts.app')

@section('content')
    <div class="obsidian-dashboard">
        <!-- KPI Row -->
        <div class="kpi-row">
            <div class="obsidian-kpi">
                <div class="kpi-header">
                    <span class="kpi-label">Health Metrics</span>
                    <i class="fas fa-heart kpi-icon"></i>
                </div>
                <div class="kpi-value">{{ $metricsCount ?? 0 }}</div>
                <div class="kpi-subtext">
                    <span class="positive">+5%</span> vs last week
                </div>
            </div>

            <div class="obsidian-kpi">
                <div class="kpi-header">
                    <span class="kpi-label">Meals Logged</span>
                    <i class="fas fa-utensils kpi-icon"></i>
                </div>
                <div class="kpi-value">{{ $mealsCount ?? 0 }}</div>
                <div class="kpi-subtext">
                    <span class="positive">+2%</span> vs last week
                </div>
            </div>

            <div class="obsidian-kpi">
                <div class="kpi-header">
                    <span class="kpi-label">Workouts</span>
                    <i class="fas fa-dumbbell kpi-icon"></i>
                </div>
                <div class="kpi-value">{{ $exercisesCount ?? 0 }}</div>
                <div class="kpi-subtext">
                    <span class="negative">-3%</span> vs last week
                </div>
            </div>

            <div class="obsidian-kpi">
                <div class="kpi-header">
                    <span class="kpi-label">Days Active</span>
                    <i class="fas fa-calendar-check kpi-icon"></i>
                </div>
                <div class="kpi-value">{{ $daysActive ?? 0 }}</div>
                <div class="kpi-subtext">
                    Current streak
                </div>
            </div>
        </div>

        <!-- Charts Row -->
        <div class="charts-row">
            <div class="obsidian-chart-card">
                <div class="chart-header">
                    <span class="chart-title">Weight Trend</span>
                    <span class="chart-period">Last 30 days</span>
                </div>
                <div class="chart-container" id="weight-trend-chart">
                    <!-- Chart will be rendered here -->
                    <div class="chart-placeholder">
                        <i class="fas fa-chart-line"></i>
                        <span>Weight data visualization</span>
                    </div>
                </div>
            </div>

            <div class="obsidian-chart-card">
                <div class="chart-header">
                    <span class="chart-title">Activity Breakdown</span>
                    <span class="chart-period">Weekly</span>
                </div>
                <div class="chart-container" id="activity-chart">
                    <!-- Chart will be rendered here -->
                    <div class="chart-placeholder">
                        <i class="fas fa-chart-bar"></i>
                        <span>Activity distribution</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Data Table -->
        <div class="obsidian-card">
            <div class="obsidian-card-header">
                <h3>Recent Data</h3>
                <a href="{{ route('health-metrics') }}" class="obsidian-btn obsidian-btn-sm">
                    View All
                </a>
            </div>

            @if($recentMetrics && count($recentMetrics) > 0)
                <table class="obsidian-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Activity</th>
                            <th>Duration</th>
                            <th>Calories</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($recentMetrics as $metric)
                            <tr>
                                <td>{{ $metric->date->format('Y-m-d') }}</td>
                                <td>{{ $metric->notes ?? 'Health Check' }}</td>
                                <td class="data-value">{{ $metric->sleep_hours ?? '-' }} hrs</td>
                                <td class="data-value">{{ $metric->steps ? number_format($metric->steps) : '-' }}</td>
                                <td><span class="status-complete">Completed</span></td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @else
                <div class="empty-state">
                    <i class="fas fa-chart-line"></i>
                    <p>No recent data available</p>
                    <a href="{{ route('health-metrics') }}" class="obsidian-btn">
                        Add Your First Entry
                    </a>
                </div>
            @endif
        </div>
    </div>

    <style>
        /* Obsidian Dashboard Layout */
        .obsidian-dashboard {
            padding: 0.5rem;
        }

        /* KPI Row */
        .kpi-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        @media (max-width: 1200px) {
            .kpi-row {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 576px) {
            .kpi-row {
                grid-template-columns: 1fr;
            }
        }

        /* Charts Row */
        .charts-row {
            display: grid;
            grid-template-columns: 1.5fr 1fr;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        @media (max-width: 992px) {
            .charts-row {
                grid-template-columns: 1fr;
            }
        }

        /* Chart Placeholder */
        .chart-placeholder {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: var(--obsidian-text-muted);
            gap: 0.5rem;

            i {
                font-size: 2rem;
                color: var(--obsidian-accent);
                opacity: 0.5;
            }

            span {
                font-size: 0.75rem;
            }
        }

        /* Empty State */
        .empty-state {
            padding: 3rem;
            text-align: center;
            color: var(--obsidian-text-muted);

            i {
                font-size: 2.5rem;
                color: var(--obsidian-accent);
                opacity: 0.5;
                margin-bottom: 1rem;
            }

            p {
                margin-bottom: 1rem;
            }
        }

        /* Override chart container height */
        .obsidian-chart-card .chart-container {
            height: 180px;
        }
    </style>
@endsection
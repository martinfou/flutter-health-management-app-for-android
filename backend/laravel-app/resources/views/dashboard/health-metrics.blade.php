@extends('layouts.app')

@section('content')
    <div class="obsidian-main animate-fade-in">
        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h1 class="display-4 fw-bold mb-1 obsidian-glow-text">
                    <i class="fas fa-heartbeat me-3"></i>Health Metrics
                </h1>
                <p class="text-muted lead mb-0">Track and manage your vital health data</p>
            </div>
            <div class="d-flex gap-2">
                <a href="{{ route('health-metrics') }}" class="obsidian-btn obsidian-btn-outline">
                    <i class="fas fa-sync-alt"></i>
                </a>
                <a href="{{ route('dashboard') }}" class="obsidian-btn obsidian-btn-cyan">
                    <i class="fas fa-arrow-left me-2"></i> Dashboard
                </a>
            </div>
        </div>

        <!-- Metrics Card -->
        <div class="obsidian-card">
            <div class="obsidian-card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0 fw-bold">
                    <i class="fas fa-list me-2 text-cyan"></i> All Health History
                </h5>
                <span class="obsidian-stat-label">{{ $metrics->total() }} Records</span>
            </div>
            <div class="p-0">
                @if($metrics->count() > 0)
                    <div class="table-responsive">
                        <table class="table obsidian-table mb-0" id="healthMetricsTable">
                            <thead>
                                <tr>
                                    <th>DATE</th>
                                    <th>WEIGHT</th>
                                    <th>SLEEP</th>
                                    <th>STEPS</th>
                                    <th>HEART RATE</th>
                                    <th>MOOD</th>
                                    <th>NOTES</th>
                                    <th class="text-end">ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($metrics as $metric)
                                    <tr>
                                        <td class="fw-bold text-white">
                                            {{ $metric->date->format('M d, Y') }}
                                        </td>
                                        <td>
                                            <span class="obsidian-stat-value text-cyan fs-6">{{ $metric->weight_kg ?? '-' }}</span>
                                            <small class="text-muted ms-1">kg</small>
                                        </td>
                                        <td>
                                            @if($metric->sleep_hours)
                                                <span class="obsidian-stat-value text-primary fs-6">{{ $metric->sleep_hours }}</span>
                                                <small class="text-muted ms-1">hrs</small>
                                            @else
                                                <span class="text-muted">-</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($metric->steps)
                                                <span
                                                    class="obsidian-stat-value text-success fs-6">{{ number_format($metric->steps) }}</span>
                                                <small class="text-muted ms-1">steps</small>
                                            @else
                                                <span class="text-muted">-</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($metric->heart_rate)
                                                <span class="obsidian-stat-value text-danger fs-6">{{ $metric->heart_rate }}</span>
                                                <small class="text-muted ms-1">bpm</small>
                                            @else
                                                <span class="text-muted">-</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($metric->mood)
                                                <span class="badge obsidian-badge-mood-{{ strtolower($metric->mood) }}">
                                                    {{ ucfirst($metric->mood) }}
                                                </span>
                                            @else
                                                <span class="text-muted">-</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($metric->notes)
                                                <span class="text-muted small" title="{{ $metric->notes }}">
                                                    {{ Str::limit($metric->notes, 30) }}
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
                        {{ $metrics->links('pagination::bootstrap-5') }}
                    </div>
                @else
                    <div class="text-center py-5">
                        <div class="obsidian-icon-glow mx-auto mb-4">
                            <i class="fas fa-chart-line fa-3x text-cyan"></i>
                        </div>
                        <h3 class="fw-bold text-white">No health metrics yet</h3>
                        <p class="text-muted mb-4">Start tracking your health by adding your first metric</p>
                        <a href="{{ route('dashboard') }}" class="obsidian-btn obsidian-btn-cyan px-4">
                            <i class="fas fa-plus me-2"></i> Add First Metric
                        </a>
                    </div>
                @endif
            </div>
        </div>
    </div>

    <style>
        .obsidian-badge-mood-good {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .obsidian-badge-mood-neutral {
            background: rgba(59, 130, 246, 0.1);
            color: #3b82f6;
            border: 1px solid rgba(59, 130, 246, 0.2);
        }

        .obsidian-badge-mood-bad {
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

        .page-item.disabled .page-link {
            background: var(--obsidian-bg-dark);
            border-color: var(--obsidian-border);
            opacity: 0.5;
        }
    </style>

    @push('scripts')
        <script type="module">
            import { initDataTables } from '{{ asset("js/modules/tables.js") }}';

            document.addEventListener('DOMContentLoaded', () => {
                if (document.getElementById('healthMetricsTable')) {
                    // initDataTables('#healthMetricsTable');
                }
            });
        </script>
    @endpush
@endsection
@extends('layouts.app')

@section('content')
    <div class="obsidian-main animate-fade-in">
        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h1 class="display-4 fw-bold mb-1 obsidian-glow-text">
                    <i class="fas fa-utensils me-3 text-cyan"></i>Meals
                </h1>
                <p class="text-muted lead mb-0">Track your nutrition and daily meals</p>
            </div>
            <div class="d-flex gap-2">
                <a href="{{ route('meals') }}" class="obsidian-btn obsidian-btn-outline">
                    <i class="fas fa-sync-alt"></i>
                </a>
                <a href="{{ route('dashboard') }}" class="obsidian-btn obsidian-btn-cyan">
                    <i class="fas fa-arrow-left me-2"></i> Dashboard
                </a>
            </div>
        </div>

        <!-- Meals Card -->
        <div class="obsidian-card">
            <div class="obsidian-card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0 fw-bold">
                    <i class="fas fa-history me-2 text-cyan"></i> Nutrition History
                </h5>
                <span class="obsidian-stat-label">{{ $meals->total() }} Meals Logged</span>
            </div>
            <div class="p-0">
                @if($meals->count() > 0)
                    <div class="table-responsive">
                        <table class="table obsidian-table mb-0" id="mealsTable">
                            <thead>
                                <tr>
                                    <th>DATE</th>
                                    <th>MEAL NAME</th>
                                    <th>TYPE</th>
                                    <th>CALORIES</th>
                                    <th>PROTEIN</th>
                                    <th>CARBS</th>
                                    <th>FAT</th>
                                    <th class="text-end">ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($meals as $meal)
                                    <tr>
                                        <td class="fw-bold text-white">
                                            {{ $meal->date->format('M d, Y') }}
                                        </td>
                                        <td>
                                            <span class="text-white fw-bold">{{ $meal->name }}</span>
                                        </td>
                                        <td>
                                            @php
                                                $mealTypeClass = match (strtolower($meal->meal_type ?? 'other')) {
                                                    'breakfast' => 'obsidian-badge-type-breakfast',
                                                    'lunch' => 'obsidian-badge-type-lunch',
                                                    'dinner' => 'obsidian-badge-type-dinner',
                                                    'snack' => 'obsidian-badge-type-snack',
                                                    default => 'obsidian-badge-type-other'
                                                };
                                            @endphp
                                            <span class="badge {{ $mealTypeClass }}">
                                                {{ ucfirst($meal->meal_type ?? 'Other') }}
                                            </span>
                                        </td>
                                        <td>
                                            <span class="obsidian-stat-value text-cyan fs-6">{{ $meal->calories ?? '-' }}</span>
                                            <small class="text-muted ms-1">cal</small>
                                        </td>
                                        <td>
                                            <span class="text-primary fs-6 fw-bold">{{ $meal->protein_g ?? '-' }}</span>
                                            <small class="text-muted ms-1">g</small>
                                        </td>
                                        <td>
                                            <span class="text-warning fs-6 fw-bold">{{ $meal->carbs_g ?? '-' }}</span>
                                            <small class="text-muted ms-1">g</small>
                                        </td>
                                        <td>
                                            <span class="text-danger fs-6 fw-bold">{{ $meal->fat_g ?? '-' }}</span>
                                            <small class="text-muted ms-1">g</small>
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
                        {{ $meals->links('pagination::bootstrap-5') }}
                    </div>
                @else
                    <div class="text-center py-5">
                        <div class="obsidian-icon-glow mx-auto mb-4">
                            <i class="fas fa-utensils fa-3x text-cyan"></i>
                        </div>
                        <h3 class="fw-bold text-white">No meals logged yet</h3>
                        <p class="text-muted mb-4">Start tracking your nutrition by logging your first meal</p>
                        <a href="{{ route('dashboard') }}" class="obsidian-btn obsidian-btn-cyan px-4">
                            <i class="fas fa-plus me-2"></i> Log First Meal
                        </a>
                    </div>
                @endif
            </div>
        </div>
    </div>

    <style>
        .obsidian-badge-type-breakfast {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
            border: 1px solid rgba(245, 158, 11, 0.2);
        }

        .obsidian-badge-type-lunch {
            background: rgba(59, 130, 246, 0.1);
            color: #3b82f6;
            border: 1px solid rgba(59, 130, 246, 0.2);
        }

        .obsidian-badge-type-dinner {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .obsidian-badge-type-snack {
            background: rgba(139, 92, 246, 0.1);
            color: #8b5cf6;
            border: 1px solid rgba(139, 92, 246, 0.2);
        }

        .obsidian-badge-type-other {
            background: rgba(100, 116, 139, 0.1);
            color: #64748b;
            border: 1px solid rgba(100, 116, 139, 0.2);
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
                if (document.getElementById('mealsTable')) {
                    // initDataTables('#mealsTable');
                }
            });
        </script>
    @endpush
@endsection

@endsection
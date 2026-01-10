@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row">
        <!-- Sidebar Navigation -->
        <div class="col-md-3 mb-4">
            <div class="list-group">
                <a href="{{ route('dashboard') }}" class="list-group-item list-group-item-action active">
                    <i class="fas fa-tachometer-alt me-2"></i> Dashboard
                </a>
                <a href="{{ route('health-metrics') }}" class="list-group-item list-group-item-action">
                    <i class="fas fa-chart-line me-2"></i> Health Metrics
                </a>
                <a href="{{ route('meals') }}" class="list-group-item list-group-item-action">
                    <i class="fas fa-utensils me-2"></i> Meals
                </a>
                <a href="{{ route('exercises') }}" class="list-group-item list-group-item-action">
                    <i class="fas fa-dumbbell me-2"></i> Exercises
                </a>
                <a href="{{ route('profile') }}" class="list-group-item list-group-item-action">
                    <i class="fas fa-user me-2"></i> Profile
                </a>
            </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-9">
            <!-- User Profile Card -->
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="card-title">
                        <i class="fas fa-user-circle me-2"></i> Profile
                    </h5>
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Name:</strong> {{ Auth::user()->name ?? 'Not set' }}</p>
                            <p><strong>Email:</strong> {{ Auth::user()->email }}</p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Account Type:</strong>
                                @if(Auth::user()->google_id)
                                    <span class="badge bg-danger">Google</span>
                                @else
                                    <span class="badge bg-primary">Email</span>
                                @endif
                            </p>
                            <p><strong>Member Since:</strong> {{ Auth::user()->created_at->format('M d, Y') }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="card text-white bg-primary">
                        <div class="card-body">
                            <h6 class="card-title">
                                <i class="fas fa-chart-line me-2"></i> Health Metrics
                            </h6>
                            <h2>{{ $metricsCount ?? 0 }}</h2>
                            <p class="mb-0">Total entries</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-white bg-success">
                        <div class="card-body">
                            <h6 class="card-title">
                                <i class="fas fa-utensils me-2"></i> Meals Logged
                            </h6>
                            <h2>{{ $mealsCount ?? 0 }}</h2>
                            <p class="mb-0">Total meals</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-white bg-warning">
                        <div class="card-body">
                            <h6 class="card-title">
                                <i class="fas fa-dumbbell me-2"></i> Workouts
                            </h6>
                            <h2>{{ $exercisesCount ?? 0 }}</h2>
                            <p class="mb-0">Total exercises</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Activity -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">
                        <i class="fas fa-history me-2"></i> Recent Activity
                    </h5>
                    <a href="{{ route('health-metrics') }}" class="btn btn-sm btn-primary">
                        View All
                    </a>
                </div>
                <div class="card-body">
                    @if($recentMetrics && count($recentMetrics) > 0)
                        <div class="list-group list-group-flush">
                            @foreach($recentMetrics as $metric)
                            <div class="list-group-item">
                                <div class="d-flex w-100 justify-content-between">
                                    <h6 class="mb-1">
                                        <i class="fas fa-calendar-alt text-muted me-2"></i>
                                        {{ $metric->date->format('M d, Y') }}
                                    </h6>
                                    <small class="text-muted">
                                        {{ $metric->created_at->diffForHumans() }}
                                    </small>
                                </div>
                                <p class="mb-1">
                                    @if($metric->weight_kg)
                                        <span class="badge bg-info me-2">Weight: {{ $metric->weight_kg }} kg</span>
                                    @endif
                                    @if($metric->sleep_hours)
                                        <span class="badge bg-secondary me-2">Sleep: {{ $metric->sleep_hours }} hrs</span>
                                    @endif
                                    @if($metric->steps)
                                        <span class="badge bg-success me-2">Steps: {{ number_format($metric->steps) }}</span>
                                    @endif
                                </p>
                                @if($metric->notes)
                                    <small class="text-muted">"{{ Str::limit($metric->notes, 100) }}"</small>
                                @endif
                            </div>
                            @endforeach
                        </div>
                    @else
                        <div class="text-center py-5 text-muted">
                            <i class="fas fa-chart-line fa-3x mb-3"></i>
                            <p>No health metrics yet. Start tracking your health!</p>
                            <a href="{{ route('health-metrics') }}" class="btn btn-primary">
                                <i class="fas fa-plus me-2"></i> Add Your First Metric
                            </a>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

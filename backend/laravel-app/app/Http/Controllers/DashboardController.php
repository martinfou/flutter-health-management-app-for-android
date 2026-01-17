<?php

namespace App\Http\Controllers;

use App\Models\Exercise;
use App\Models\HealthMetric;
use App\Models\Meal;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    /**
     * Dashboard home
     */
    public function index()
    {
        $user = Auth::user();

        // Get counts
        $metricsCount = HealthMetric::where('user_id', $user->id)->count();
        $mealsCount = Meal::where('user_id', $user->id)->count();
        $exercisesCount = Exercise::where('user_id', $user->id)->where('is_template', false)->count();

        // Get recent metrics (last 30 days for charts)
        $recentMetrics = HealthMetric::where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->limit(5)
            ->get();

        $last30Days = HealthMetric::where('user_id', $user->id)
            ->where('date', '>=', now()->subDays(30))
            ->orderBy('date', 'asc')
            ->get();

        // Count days active
        $daysActive = HealthMetric::where('user_id', $user->id)
            ->distinct('date')
            ->count('date');

        // Prepare chart configurations
        $weightChartConfig = $this->getWeightChartConfig($last30Days);
        $activityChartConfig = $this->getActivityChartConfig($last30Days);

        return view('dashboard.index', [
            'metricsCount' => $metricsCount,
            'mealsCount' => $mealsCount,
            'exercisesCount' => $exercisesCount,
            'daysActive' => $daysActive,
            'recentMetrics' => $recentMetrics,
            'weightChartConfig' => $weightChartConfig,
            'activityChartConfig' => $activityChartConfig,
        ]);
    }

    /**
     * Get weight trend chart configuration
     */
    private function getWeightChartConfig($metrics)
    {
        $dates = $metrics->pluck('date')->map(fn($d) => $d->format('M d'));
        $weights = $metrics->pluck('weight_kg');

        return [
            'type' => 'line',
            'data' => [
                'labels' => $dates->values()->toArray(),
                'datasets' => [
                    [
                        'label' => 'Weight (kg)',
                        'data' => $weights->values()->toArray(),
                        'borderColor' => '#3b82f6',
                        'backgroundColor' => 'rgba(59, 130, 246, 0.1)',
                        'tension' => 0.4,
                        'fill' => true,
                        'pointRadius' => 4,
                        'pointHoverRadius' => 6,
                    ]
                ]
            ],
            'options' => [
                'responsive' => true,
                'maintainAspectRatio' => false,
                'plugins' => [
                    'legend' => ['display' => true],
                    'title' => ['text' => 'Weight Trend (30 days)']
                ]
            ]
        ];
    }

    /**
     * Get activity distribution chart configuration
     */
    private function getActivityChartConfig($metrics)
    {
        $totalSteps = $metrics->sum('steps') ?? 0;
        $totalSleep = $metrics->sum('sleep_hours') ?? 0;
        $metricsCount = $metrics->count();

        return [
            'type' => 'bar',
            'data' => [
                'labels' => ['Steps', 'Sleep Hours', 'Entries'],
                'datasets' => [
                    [
                        'label' => 'Activity',
                        'data' => [
                            round($totalSteps / max($metricsCount, 1)),
                            round($totalSleep / max($metricsCount, 1), 1),
                            $metricsCount
                        ],
                        'backgroundColor' => [
                            '#10b981',
                            '#f59e0b',
                            '#3b82f6'
                        ],
                        'borderRadius' => 4,
                    ]
                ]
            ],
            'options' => [
                'responsive' => true,
                'maintainAspectRatio' => false,
                'plugins' => [
                    'legend' => ['display' => true],
                    'title' => ['text' => 'Activity Distribution']
                ]
            ]
        ];
    }

    /**
     * Health metrics page
     */
    public function healthMetrics()
    {
        $user = Auth::user();
        $metrics = HealthMetric::where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->paginate(20);

        return view('dashboard.health-metrics', compact('metrics'));
    }

    /**
     * Meals page
     */
    public function meals()
    {
        $user = Auth::user();
        $meals = Meal::where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->paginate(20);

        return view('dashboard.meals', compact('meals'));
    }

    /**
     * Exercises page
     */
    public function exercises()
    {
        $user = Auth::user();
        $exercises = Exercise::where('user_id', $user->id)
            ->where('is_template', false)
            ->orderBy('date', 'desc')
            ->paginate(20);

        return view('dashboard.exercises', compact('exercises'));
    }

    /**
     * Profile page
     */
    public function profile()
    {
        return view('dashboard.profile', ['user' => Auth::user()]);
    }
}

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

        return view('dashboard.index', [
            'metricsCount' => HealthMetric::where('user_id', $user->id)->count(),
            'mealsCount' => Meal::where('user_id', $user->id)->count(),
            'exercisesCount' => Exercise::where('user_id', $user->id)->where('is_template', false)->count(),
            'recentMetrics' => HealthMetric::where('user_id', $user->id)
                ->orderBy('date', 'desc')
                ->limit(5)
                ->get(),
        ]);
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

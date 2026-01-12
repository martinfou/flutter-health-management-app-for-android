<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\HealthMetric>
 */
class HealthMetricFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => null,
            'date' => fake()->dateTimeBetween('-30 days', 'now')->format('Y-m-d'),
            'weight_kg' => fake()->optional(0.8)->randomFloat(2, 50, 150),
            'height_cm' => fake()->optional(0.5)->randomFloat(2, 140, 200),
            'sleep_hours' => fake()->optional(0.8)->numberBetween(4, 12),
            'mood' => fake()->optional(0.7)->randomElement(['poor', 'fair', 'good', 'excellent']),
            'notes' => fake()->optional(0.4)->sentence(),
            'blood_pressure_systolic' => fake()->optional(0.5)->numberBetween(100, 160),
            'blood_pressure_diastolic' => fake()->optional(0.5)->numberBetween(60, 100),
            'heart_rate_bpm' => fake()->optional(0.6)->numberBetween(50, 100),
            'blood_glucose_mg_dl' => fake()->optional(0.3)->randomFloat(2, 70, 200),
        ];
    }
}

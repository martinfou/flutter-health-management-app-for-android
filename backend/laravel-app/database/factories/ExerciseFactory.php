<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Exercise>
 */
class ExerciseFactory extends Factory
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
            'type' => fake()->randomElement(['strength', 'cardio', 'flexibility', 'sports']),
            'name' => fake()->word(),
            'description' => fake()->optional(0.5)->sentence(),
            'duration_minutes' => fake()->optional(0.8)->numberBetween(10, 120),
            'calories_burned' => fake()->optional(0.8)->numberBetween(50, 800),
            'intensity' => fake()->optional(0.7)->randomElement(['low', 'medium', 'high']),
            'distance_km' => fake()->optional(0.3)->randomFloat(2, 1, 50),
            'sets' => fake()->optional(0.4)->numberBetween(2, 5),
            'reps' => fake()->optional(0.4)->numberBetween(5, 20),
            'weight_kg' => fake()->optional(0.4)->randomFloat(1, 10, 100),
            'notes' => fake()->optional(0.4)->sentence(),
            'is_template' => false,
        ];
    }
}

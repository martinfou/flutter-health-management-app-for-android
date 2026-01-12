<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\MealPlan>
 */
class MealPlanFactory extends Factory
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
            'name' => fake()->word(),
            'description' => fake()->optional(0.6)->sentence(),
            'start_date' => fake()->dateTimeBetween('-3 months', 'now')->format('Y-m-d'),
            'end_date' => fake()->optional(0.4)->dateTimeBetween('now', '+3 months')->format('Y-m-d'),
            'daily_calorie_target' => fake()->randomElement([1500, 1800, 2000, 2200, 2500, 3000]),
            'daily_protein_target' => fake()->optional(0.8)->numberBetween(50, 200),
            'daily_fats_target' => fake()->optional(0.8)->numberBetween(40, 100),
            'daily_carbs_target' => fake()->optional(0.8)->numberBetween(150, 350),
            'active' => false,
        ];
    }
}

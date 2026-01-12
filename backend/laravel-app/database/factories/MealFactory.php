<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Meal>
 */
class MealFactory extends Factory
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
            'meal_type' => fake()->randomElement(['breakfast', 'lunch', 'dinner', 'snack']),
            'name' => fake()->word(),
            'description' => fake()->optional(0.5)->sentence(),
            'calories' => fake()->optional(0.8)->randomFloat(2, 100, 1000),
            'protein_g' => fake()->optional(0.8)->randomFloat(2, 1, 50),
            'fats_g' => fake()->optional(0.8)->randomFloat(2, 1, 50),
            'carbs_g' => fake()->optional(0.8)->randomFloat(2, 1, 150),
            'fiber_g' => fake()->optional(0.6)->randomFloat(2, 0, 20),
            'sugar_g' => fake()->optional(0.6)->randomFloat(2, 0, 40),
            'sodium_mg' => fake()->optional(0.6)->randomFloat(2, 0, 2000),
            'hunger_before' => fake()->optional(0.7)->numberBetween(1, 10),
            'hunger_after' => fake()->optional(0.7)->numberBetween(1, 10),
            'satisfaction' => fake()->optional(0.7)->numberBetween(1, 10),
            'notes' => fake()->optional(0.4)->sentence(),
        ];
    }
}

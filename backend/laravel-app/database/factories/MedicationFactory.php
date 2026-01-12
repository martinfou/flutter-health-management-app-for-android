<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Medication>
 */
class MedicationFactory extends Factory
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
            'dosage' => fake()->numberBetween(100, 1000),
            'unit' => fake()->randomElement(['mg', 'ml', 'g', 'mcg', 'IU']),
            'frequency' => fake()->randomElement(['Once daily', 'Twice daily', 'Three times daily', 'Every 6 hours', 'As needed']),
            'start_date' => fake()->dateTimeBetween('-6 months', 'now')->format('Y-m-d'),
            'end_date' => fake()->optional(0.3)->dateTimeBetween('now', '+1 year')->format('Y-m-d'),
            'prescribing_doctor' => fake()->optional(0.6)->name(),
            'notes' => fake()->optional(0.4)->sentence(),
            'active' => true,
        ];
    }
}

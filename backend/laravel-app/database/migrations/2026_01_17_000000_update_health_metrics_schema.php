<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Updates health_metrics table to match the Flutter app field requirements:
     * - Adds missing columns: sleep_quality, energy_level, resting_heart_rate,
     *   steps, calories_burned, water_intake_ml, stress_level
     * - These columns were expected by the model/controller but missing from
     *   the original migration
     */
    public function up(): void
    {
        Schema::table('health_metrics', function (Blueprint $table) {
            // Add sleep_quality field (1-10 scale) after sleep_hours
            if (!Schema::hasColumn('health_metrics', 'sleep_quality')) {
                $table->integer('sleep_quality')->nullable()->after('sleep_hours');
            }

            // Add energy_level field (1-10 scale) after sleep_quality
            if (!Schema::hasColumn('health_metrics', 'energy_level')) {
                $table->integer('energy_level')->nullable()->after('sleep_quality');
            }

            // Add resting_heart_rate field (BPM) after energy_level
            // Note: Original schema had heart_rate_bpm but Flutter uses resting_heart_rate
            if (!Schema::hasColumn('health_metrics', 'resting_heart_rate')) {
                $table->integer('resting_heart_rate')->nullable()->after('energy_level');
            }

            // Add steps field after blood_pressure_diastolic
            if (!Schema::hasColumn('health_metrics', 'steps')) {
                $table->integer('steps')->nullable()->after('blood_pressure_diastolic');
            }

            // Add calories_burned field after steps
            if (!Schema::hasColumn('health_metrics', 'calories_burned')) {
                $table->integer('calories_burned')->nullable()->after('steps');
            }

            // Add water_intake_ml field after calories_burned
            if (!Schema::hasColumn('health_metrics', 'water_intake_ml')) {
                $table->integer('water_intake_ml')->nullable()->after('calories_burned');
            }

            // Add stress_level field (1-10 scale) after mood
            if (!Schema::hasColumn('health_metrics', 'stress_level')) {
                $table->integer('stress_level')->nullable()->after('mood');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('health_metrics', function (Blueprint $table) {
            $columns = [
                'sleep_quality',
                'energy_level',
                'resting_heart_rate',
                'steps',
                'calories_burned',
                'water_intake_ml',
                'stress_level',
            ];

            foreach ($columns as $column) {
                if (Schema::hasColumn('health_metrics', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};

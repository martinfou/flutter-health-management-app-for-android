<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Health Metrics Table
        Schema::create('health_metrics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->date('date');
            $table->decimal('weight_kg', 5, 2)->nullable();
            $table->decimal('height_cm', 5, 2)->nullable();
            $table->integer('blood_pressure_systolic')->nullable();
            $table->integer('blood_pressure_diastolic')->nullable();
            $table->integer('heart_rate_bpm')->nullable();
            $table->decimal('blood_glucose_mg_dl', 6, 2)->nullable();
            $table->string('mood')->nullable();
            $table->integer('sleep_hours')->nullable();
            $table->text('notes')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('date');
        });

        // Meals Table
        Schema::create('meals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->date('date');
            $table->enum('meal_type', ['breakfast', 'lunch', 'dinner', 'snack']);
            $table->string('name', 255);
            $table->text('description')->nullable();
            $table->json('ingredients')->nullable();
            $table->json('nutritional_info')->nullable();
            $table->decimal('calories', 7, 2)->nullable();
            $table->decimal('protein_g', 6, 2)->nullable();
            $table->decimal('fats_g', 6, 2)->nullable();
            $table->decimal('carbs_g', 6, 2)->nullable();
            $table->decimal('fiber_g', 6, 2)->nullable();
            $table->decimal('sugar_g', 6, 2)->nullable();
            $table->decimal('sodium_mg', 8, 2)->nullable();
            $table->integer('hunger_before')->nullable();
            $table->integer('hunger_after')->nullable();
            $table->integer('satisfaction')->nullable();
            $table->json('eating_reasons')->nullable();
            $table->text('notes')->nullable();
            $table->boolean('is_template')->default(false);
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('date');
        });

        // Exercises Table
        Schema::create('exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->date('date')->nullable();
            $table->enum('type', ['strength', 'cardio', 'flexibility', 'sports']);
            $table->string('name', 255);
            $table->text('description')->nullable();
            $table->integer('duration_minutes')->nullable();
            $table->decimal('calories_burned', 7, 2)->nullable();
            $table->enum('intensity', ['low', 'medium', 'high'])->nullable();
            $table->decimal('distance_km', 7, 2)->nullable();
            $table->integer('sets')->nullable();
            $table->integer('reps')->nullable();
            $table->decimal('weight_kg', 6, 2)->nullable();
            $table->text('notes')->nullable();
            $table->json('muscle_groups')->nullable();
            $table->json('equipment')->nullable();
            $table->boolean('is_template')->default(false);
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('date');
            $table->index('is_template');
        });

        // Medications Table
        Schema::create('medications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('name', 255);
            $table->string('dosage', 100);
            $table->string('unit', 50);
            $table->string('frequency', 100);
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->string('prescribing_doctor', 255)->nullable();
            $table->text('notes')->nullable();
            $table->boolean('active')->default(true);
            $table->json('reminder_times')->nullable();
            $table->json('side_effects')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('active');
        });

        // Meal Plans Table
        Schema::create('meal_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('name', 255);
            $table->text('description')->nullable();
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->decimal('daily_calorie_target', 7, 2)->nullable();
            $table->decimal('daily_protein_target', 6, 2)->nullable();
            $table->decimal('daily_fats_target', 6, 2)->nullable();
            $table->decimal('daily_carbs_target', 6, 2)->nullable();
            $table->boolean('active')->default(false);
            $table->json('meals')->nullable();
            $table->json('goals')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('active');
        });

        // Sync Status Table
        Schema::create('sync_status', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('device_id', 255);
            $table->timestamp('last_sync')->nullable();
            $table->json('sync_metadata')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->unique(['user_id', 'device_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sync_status');
        Schema::dropIfExists('meal_plans');
        Schema::dropIfExists('medications');
        Schema::dropIfExists('exercises');
        Schema::dropIfExists('meals');
        Schema::dropIfExists('health_metrics');
    }
};

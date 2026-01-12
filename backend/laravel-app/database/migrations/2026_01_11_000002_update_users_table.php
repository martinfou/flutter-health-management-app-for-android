<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Rename password to password_hash for API compatibility
            if (Schema::hasColumn('users', 'password')) {
                $table->renameColumn('password', 'password_hash');
            }

            // Add Google OAuth support
            $table->string('google_id', 255)->nullable()->unique()->after('email_verified_at');

            // Health profile fields
            $table->date('date_of_birth')->nullable()->after('email');
            $table->enum('gender', ['male', 'female', 'other', 'prefer_not_to_say'])->nullable();
            $table->decimal('height_cm', 5, 2)->nullable();
            $table->decimal('weight_kg', 5, 2)->nullable();
            $table->enum('activity_level', [
                'sedentary',
                'lightly_active',
                'moderately_active',
                'very_active',
                'extremely_active'
            ])->nullable();

            // Health preferences
            $table->json('fitness_goals')->nullable();
            $table->string('dietary_approach', 100)->nullable();
            $table->json('dislikes')->nullable();
            $table->json('allergies')->nullable();
            $table->json('health_conditions')->nullable();
            $table->json('preferences')->nullable();

            // Tracking
            $table->timestamp('last_login_at')->nullable();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Rename password_hash back to password if it exists
            if (Schema::hasColumn('users', 'password_hash')) {
                $table->renameColumn('password_hash', 'password');
            }

            // Drop all added columns (SQLite-safe)
            $table->dropColumn([
                'google_id',
                'date_of_birth',
                'gender',
                'height_cm',
                'weight_kg',
                'activity_level',
                'fitness_goals',
                'dietary_approach',
                'dislikes',
                'allergies',
                'health_conditions',
                'preferences',
                'last_login_at',
            ]);
            $table->dropSoftDeletes();
        });
    }
};

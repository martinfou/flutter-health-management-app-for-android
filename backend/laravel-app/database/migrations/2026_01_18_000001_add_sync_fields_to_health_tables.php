<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Meals Table
        Schema::table('meals', function (Blueprint $table) {
            $table->uuid('client_id')->nullable()->after('id');
            $table->softDeletes()->after('updated_at');

            // Add index for sync queries
            $table->index(['user_id', 'updated_at']);
            $table->index('client_id');
        });

        // 2. Exercises Table
        Schema::table('exercises', function (Blueprint $table) {
            $table->uuid('client_id')->nullable()->after('id');
            $table->softDeletes()->after('updated_at');

            $table->index(['user_id', 'updated_at']);
            $table->index('client_id');
        });

        // 3. Medications Table
        Schema::table('medications', function (Blueprint $table) {
            $table->uuid('client_id')->nullable()->after('id');
            $table->softDeletes()->after('updated_at');

            $table->index(['user_id', 'updated_at']);
            $table->index('client_id');
        });

        // 4. Meal Plans (Optional but good for consistency)
        Schema::table('meal_plans', function (Blueprint $table) {
            $table->uuid('client_id')->nullable()->after('id');
            $table->softDeletes()->after('updated_at');

            $table->index(['user_id', 'updated_at']);
            $table->index('client_id');
        });

        // 5. Backfill client_id for existing records (using UUIDs)
        // We do this in PHP to ensure valid UUIDs
        // Note: In production with millions of rows this should be a separate job,
        // but for this scale it's fine in migration.

        // Using raw DB queries for performance and to avoid Model dependencies
        $tables = ['meals', 'exercises', 'medications', 'meal_plans'];

        foreach ($tables as $tableName) {
            $ids = \DB::table($tableName)->pluck('id');
            foreach ($ids as $id) {
                \DB::table($tableName)
                    ->where('id', $id)
                    ->update(['client_id' => Str::uuid()]);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $tables = ['meals', 'exercises', 'medications', 'meal_plans'];

        foreach ($tables as $tableName) {
            Schema::table($tableName, function (Blueprint $table) {
                // Drop indexes first
                $table->dropIndex(['user_id', 'updated_at']);
                $table->dropIndex(['client_id']);

                // Drop columns
                $table->dropSoftDeletes();
                $table->dropColumn('client_id');
            });
        }
    }
};

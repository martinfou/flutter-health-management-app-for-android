<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * BF-003: Change health_metrics.date from DATE to TIMESTAMP to allow multiple entries per day
     * This enables users to log multiple health measurements throughout the day with full timestamps
     */
    public function up(): void
    {
        Schema::table('health_metrics', function (Blueprint $table) {
            // Change date column from DATE to TIMESTAMP to support multiple entries per day
            // This allows users to log morning and evening measurements, etc.
            $table->timestamp('date')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('health_metrics', function (Blueprint $table) {
            // Revert back to DATE column if needed
            $table->date('date')->change();
        });
    }
};
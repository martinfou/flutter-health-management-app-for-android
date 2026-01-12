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
        // Table for tracking rate limit requests
        Schema::create('rate_limit_requests', function (Blueprint $table) {
            $table->id();
            $table->string('client_ip', 45);
            $table->string('route', 255);
            $table->string('method', 10);
            $table->timestamp('created_at')->useCurrent();

            // Index for efficient querying by IP and time
            $table->index(['client_ip', 'created_at']);
        });

        // Table for tracking blocked clients
        Schema::create('rate_limit_blocks', function (Blueprint $table) {
            $table->id();
            $table->string('client_ip', 45)->unique();
            $table->timestamp('blocked_until');
            $table->timestamp('created_at')->useCurrent();

            // Index for checking block expiry
            $table->index('blocked_until');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rate_limit_requests');
        Schema::dropIfExists('rate_limit_blocks');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * التبرع يجب أن يقدر يروح إما لمشروع جمعية (project_id) أو لحالة محتاج (case_request_id).
     * لذلك نضيف case_request_id ونخلي project_id اختياري بدل إجباري.
     */
    public function up(): void
    {
        Schema::table('donations', function (Blueprint $table) {
            $table->foreignId('case_request_id')
                ->nullable()
                ->after('project_id')
                ->constrained('case_requests')
                ->nullOnDelete();
        });

        Schema::table('donations', function (Blueprint $table) {
            $table->foreignId('project_id')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('donations', function (Blueprint $table) {
            $table->dropConstrainedForeignId('case_request_id');
        });

        Schema::table('donations', function (Blueprint $table) {
            $table->foreignId('project_id')->nullable(false)->change();
        });
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * التبرع التلقائي كان بدون أي وجهة (لا مشروع ولا حالة)، فكان المبلغ يُخصم
     * من المحفظة بدون أي أثر فعلي على أي مشروع/حالة. نضيف وجهة إجبارية له.
     */
    public function up(): void
    {
        Schema::table('auto_donations', function (Blueprint $table) {
            $table->foreignId('project_id')->nullable()->after('user_id')->constrained('projects')->nullOnDelete();
            $table->foreignId('case_request_id')->nullable()->after('project_id')->constrained('case_requests')->nullOnDelete();
            $table->timestamp('last_processed_at')->nullable()->after('status'); // بدل الاعتماد على updated_at
        });
    }

    public function down(): void
    {
        Schema::table('auto_donations', function (Blueprint $table) {
            $table->dropConstrainedForeignId('project_id');
            $table->dropConstrainedForeignId('case_request_id');
            $table->dropColumn('last_processed_at');
        });
    }
};

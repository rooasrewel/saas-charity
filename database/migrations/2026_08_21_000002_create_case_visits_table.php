<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * زيارة تحقق ميداني: الأدمن يسند حالة محتاج لمندوب ليتحقق منها ميدانياً
     * قبل اعتمادها، والمندوب يرفع تقرير وصور/مستندات كدليل.
     */
    public function up(): void
    {
        Schema::create('case_visits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_request_id')->constrained('case_requests')->cascadeOnDelete();
            $table->foreignId('agent_id')->constrained('users')->cascadeOnDelete();

            // assigned: تم الإسناد | reported: تم رفع التقرير
            $table->enum('status', ['assigned', 'reported'])->default('assigned');

            $table->text('report_text')->nullable(); // ملاحظات المندوب بعد الزيارة الميدانية
            $table->json('photos')->nullable(); // صور دليل من الزيارة
            $table->json('documents')->nullable(); // مستندات دليل (مثلاً تقرير طبي)
            $table->timestamp('visited_at')->nullable(); // وقت رفع التقرير فعلياً

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('case_visits');
    }
};

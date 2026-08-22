<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * جدول "الحالات" - طلبات المساعدة التي يرفعها المحتاج.
     * هذا هو قلب نظام إدارة الحالات المطلوب.
     */
    public function up(): void
    {
        Schema::create('case_requests', function (Blueprint $table) {
            $table->id();

            // صاحب الحالة (المحتاج)
            $table->foreignId('beneficiary_id')->constrained('users')->cascadeOnDelete();

            // الجمعية المسؤولة عن متابعة/توثيق الحالة (تُسند من الأدمن عند القبول، ويمكن أن تكون فارغة)
            $table->foreignId('organization_id')->nullable()->constrained('users')->nullOnDelete();

            $table->string('title'); // عنوان مختصر للحالة
            $table->text('description'); // شرح تفصيلي للحالة والاحتياج
            $table->string('category')->nullable(); // نوع الاحتياج: علاج، سكن، تعليم، غذاء... إلخ

            $table->decimal('target_amount', 12, 2); // المبلغ المطلوب لسد الحالة
            $table->decimal('collected_amount', 12, 2)->default(0); // المبلغ المجموع حتى الآن

            $table->json('images')->nullable(); // مسارات صور/مستندات إثبات الحالة

            // pending: بانتظار مراجعة الأدمن | approved: ظاهرة للمتبرعين | rejected: مرفوضة | completed: تم سد الاحتياج بالكامل
            $table->enum('status', ['pending', 'approved', 'rejected', 'completed'])->default('pending');

            $table->text('admin_note')->nullable(); // سبب الرفض أو أي ملاحظة إدارية

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('case_requests');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ملاحظة مهمة: هذه الأعمدة (country, city, causes, photo) كانت أُضيفت سابقاً بالتعديل المباشر
     * على ملف migration قديم (بنفس تاريخه الأصلي) بدل عمل migration جديد. هذا خطير لأن لارافيل
     * يتتبع تنفيذ الـ migrations بالاسم فقط وليس بالمحتوى: لو كان هذا الملف قد نُفذ فعلياً على
     * قاعدة بيانات حقيقية قبل ذلك التعديل، فلن يُعاد تشغيله ولن تظهر هذه الأعمدة أبداً بدون هذا
     * الملف الآمن (يتحقق من وجود العمود قبل إضافته حتى لا يسبب خطأ في حال كان موجوداً أصلاً).
     */
    public function up(): void
    {
        Schema::table('donors', function (Blueprint $table) {
            if (!Schema::hasColumn('donors', 'country')) {
                $table->string('country')->nullable();
            }
            if (!Schema::hasColumn('donors', 'city')) {
                $table->string('city')->nullable();
            }
            if (!Schema::hasColumn('donors', 'causes')) {
                $table->json('causes')->nullable();
            }
            if (!Schema::hasColumn('donors', 'photo')) {
                $table->string('photo')->nullable();
            }
        });
    }

    public function down(): void
    {
        // لا نحذف الأعمدة هنا تجنباً لتعارضها مع الملف الأصلي المعدَّل يدوياً
    }
};

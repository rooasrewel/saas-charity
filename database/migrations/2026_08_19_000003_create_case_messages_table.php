<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * رسائل التواصل بخصوص حالة معينة (بين المتبرع/المحتاج والجمعية المسؤولة عن الحالة).
     */
    public function up(): void
    {
        Schema::create('case_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_request_id')->constrained('case_requests')->cascadeOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->text('message');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('case_messages');
    }
};

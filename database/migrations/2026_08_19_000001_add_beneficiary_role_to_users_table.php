<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إضافة "beneficiary" (محتاج) لقائمة الأدوار المسموحة.
     * كانت هذه القيمة ناقصة، مما كان يمنع أي شخص من التسجيل كمحتاج بالنظام أصلاً.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('role', ['donor', 'agent', 'organization', 'admin', 'beneficiary'])
                ->default('donor')
                ->change();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('role', ['donor', 'agent', 'organization', 'admin'])
                ->default('donor')
                ->change();
        });
    }
};

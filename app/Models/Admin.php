<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable; // مهم جداً: نستخدم Authenticatable بدل Model
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // ضروري لإنشاء التوكن

class Admin extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'is_super_admin',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'is_super_admin' => 'boolean', // تحويل القيمة لـ true/false
        ];
    }

    /**
     * موديل Admin ما فيه عمود role بقاعدة البيانات، لكن middleware التحقق من الدور
     * (CheckRole) يعتمد على $user->role للتحقق من الصلاحية. بدون هذا الـ accessor
     * كان أي أدمن مسجل دخول يُرفض دائماً (403) من كل مسارات role:admin.
     */
    public function getRoleAttribute(): string
    {
        return 'admin';
    }
}

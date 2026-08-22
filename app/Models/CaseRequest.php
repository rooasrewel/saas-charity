<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CaseRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'beneficiary_id',
        'organization_id',
        'title',
        'description',
        'category',
        'target_amount',
        'collected_amount',
        'images',
        'status',
        'admin_note',
    ];

    protected function casts(): array
    {
        return [
            'target_amount' => 'decimal:2',
            'collected_amount' => 'decimal:2',
            'images' => 'array',
        ];
    }

    // الحالة تعود لمحتاج (مستخدم) واحد
    public function beneficiary()
    {
        return $this->belongsTo(User::class, 'beneficiary_id');
    }

    // الجمعية المسؤولة عن متابعة الحالة (اختياري)
    public function organization()
    {
        return $this->belongsTo(User::class, 'organization_id');
    }

    // الحالة قد يكون لها عدة تبرعات
    public function donations()
    {
        return $this->hasMany(Donation::class, 'case_request_id');
    }

    // رسائل التواصل الخاصة بالحالة
    public function messages()
    {
        return $this->hasMany(CaseMessage::class);
    }

    // زيارات التحقق الميداني المرتبطة بهذه الحالة
    public function visits()
    {
        return $this->hasMany(CaseVisit::class);
    }

    // هل تم سد الاحتياج بالكامل؟
    public function isFullyFunded(): bool
    {
        return (float) $this->collected_amount >= (float) $this->target_amount;
    }
}

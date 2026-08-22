<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AutoDonation extends Model
{
    use HasFactory;

    // تحديد المفتاح الأساسي بما أننا غيرنا اسمه الافتراضي
    protected $primaryKey = 'auto_donation_id';

    // الحقول المسموح تعبئتها
    protected $fillable = [
        'user_id',
        'project_id',
        'case_request_id',
        'amount',
        'interval',
        'status',
        'last_processed_at',
    ];

    protected function casts(): array
    {
        return [
            'last_processed_at' => 'datetime',
        ];
    }

    /**
     * التبرع التلقائي يعود لمستخدم واحد
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // وجهة التبرع التلقائي: مشروع جمعية
    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    // أو وجهته: حالة محتاج
    public function caseRequest()
    {
        return $this->belongsTo(CaseRequest::class, 'case_request_id');
    }
}

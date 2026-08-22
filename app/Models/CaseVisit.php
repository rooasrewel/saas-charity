<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CaseVisit extends Model
{
    use HasFactory;

    protected $fillable = [
        'case_request_id',
        'agent_id',
        'status',
        'report_text',
        'photos',
        'documents',
        'visited_at',
    ];

    protected function casts(): array
    {
        return [
            'photos' => 'array',
            'documents' => 'array',
            'visited_at' => 'datetime',
        ];
    }

    public function caseRequest()
    {
        return $this->belongsTo(CaseRequest::class, 'case_request_id');
    }

    public function agent()
    {
        return $this->belongsTo(User::class, 'agent_id');
    }
}

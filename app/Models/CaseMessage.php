<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CaseMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'case_request_id',
        'sender_id',
        'message',
    ];

    public function case()
    {
        return $this->belongsTo(CaseRequest::class, 'case_request_id');
    }

    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }
}

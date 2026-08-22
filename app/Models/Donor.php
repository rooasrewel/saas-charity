<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Donor extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'is_anonymous', 'country', 'city', 'causes', 'photo'];

    protected function casts(): array
    {
        return [
            'is_anonymous' => 'boolean',
            'causes' => 'array',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

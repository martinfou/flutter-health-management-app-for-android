<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MealPlan extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<string>
     */
    protected $fillable = [
        'user_id',
        'name',
        'description',
        'start_date',
        'end_date',
        'is_active',
        'target_calories',
        'target_protein_g',
        'target_fats_g',
        'target_carbs_g',
        'meals',
        'notes',
        'metadata',
    ];

    /**
     * The attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'start_date' => 'date',
            'end_date' => 'date',
            'is_active' => 'boolean',
            'target_calories' => 'integer',
            'target_protein_g' => 'decimal:2',
            'target_fats_g' => 'decimal:2',
            'target_carbs_g' => 'decimal:2',
            'meals' => 'array',
            'metadata' => 'array',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    /**
     * Get the user that owns the meal plan.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

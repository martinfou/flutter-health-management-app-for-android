<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Meal extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<string>
     */
    protected $fillable = [
        'user_id',
        'date',
        'meal_type',
        'name',
        'description',
        'ingredients',
        'nutritional_info',
        'calories',
        'protein_g',
        'fats_g',
        'carbs_g',
        'fiber_g',
        'sugar_g',
        'sodium_mg',
        'hunger_before',
        'hunger_after',
        'satisfaction',
        'eating_reasons',
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
            'date' => 'date',
            'ingredients' => 'array',
            'nutritional_info' => 'array',
            'eating_reasons' => 'array',
            'metadata' => 'array',
            'calories' => 'integer',
            'protein_g' => 'decimal:2',
            'fats_g' => 'decimal:2',
            'carbs_g' => 'decimal:2',
            'fiber_g' => 'decimal:2',
            'sugar_g' => 'decimal:2',
            'sodium_mg' => 'integer',
            'hunger_before' => 'integer',
            'hunger_after' => 'integer',
            'satisfaction' => 'integer',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    /**
     * Get the user that owns the meal.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

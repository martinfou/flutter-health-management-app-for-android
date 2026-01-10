<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Exercise extends Model
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
        'type',
        'muscle_groups',
        'equipment',
        'instructions',
        'difficulty',
        'estimated_calories_per_minute',
        'is_template',
        'template_id',
        'date',
        'sets',
        'reps_per_set',
        'weight_kg',
        'duration_minutes',
        'distance_km',
        'calories_burned',
        'heart_rate_avg',
        'heart_rate_max',
        'perceived_effort',
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
            'muscle_groups' => 'array',
            'equipment' => 'array',
            'metadata' => 'array',
            'is_template' => 'boolean',
            'date' => 'date',
            'sets' => 'integer',
            'reps_per_set' => 'integer',
            'weight_kg' => 'decimal:2',
            'duration_minutes' => 'integer',
            'distance_km' => 'decimal:2',
            'calories_burned' => 'integer',
            'heart_rate_avg' => 'integer',
            'heart_rate_max' => 'integer',
            'perceived_effort' => 'integer',
            'estimated_calories_per_minute' => 'decimal:2',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    /**
     * Get the user that owns the exercise.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the template this exercise is based on.
     */
    public function template()
    {
        return $this->belongsTo(Exercise::class, 'template_id');
    }

    /**
     * Get the exercise instances based on this template.
     */
    public function instances()
    {
        return $this->hasMany(Exercise::class, 'template_id');
    }
}

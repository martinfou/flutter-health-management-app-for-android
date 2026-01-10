<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HealthMetric extends Model
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
        'weight_kg',
        'sleep_hours',
        'sleep_quality',
        'energy_level',
        'resting_heart_rate',
        'blood_pressure_systolic',
        'blood_pressure_diastolic',
        'steps',
        'calories_burned',
        'water_intake_ml',
        'mood',
        'stress_level',
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
            'weight_kg' => 'decimal:2',
            'sleep_hours' => 'decimal:2',
            'sleep_quality' => 'integer',
            'energy_level' => 'integer',
            'resting_heart_rate' => 'integer',
            'blood_pressure_systolic' => 'integer',
            'blood_pressure_diastolic' => 'integer',
            'steps' => 'integer',
            'calories_burned' => 'integer',
            'water_intake_ml' => 'integer',
            'stress_level' => 'integer',
            'metadata' => 'array',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    /**
     * Get the user that owns the health metric.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

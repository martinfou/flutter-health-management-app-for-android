<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<string>
     */
    protected $fillable = [
        'email',
        'password_hash',
        'google_id',
        'name',
        'date_of_birth',
        'gender',
        'height_cm',
        'weight_kg',
        'activity_level',
        'fitness_goals',
        'dietary_approach',
        'dislikes',
        'allergies',
        'health_conditions',
        'preferences',
        'email_verified_at',
        'last_login_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<string>
     */
    protected $hidden = [
        'password_hash',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'last_login_at' => 'datetime',
            'date_of_birth' => 'date',
            'height_cm' => 'decimal:2',
            'weight_kg' => 'decimal:2',
            'fitness_goals' => 'array',
            'dislikes' => 'array',
            'allergies' => 'array',
            'health_conditions' => 'array',
            'preferences' => 'array',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
            'deleted_at' => 'datetime',
        ];
    }

    /**
     * Custom accessor for password compatibility with password_hash field
     */
    public function getAuthPassword()
    {
        return $this->password_hash;
    }

    /**
     * Relationships
     */
    public function healthMetrics()
    {
        return $this->hasMany(HealthMetric::class);
    }

    public function meals()
    {
        return $this->hasMany(Meal::class);
    }

    public function exercises()
    {
        return $this->hasMany(Exercise::class);
    }

    public function medications()
    {
        return $this->hasMany(Medication::class);
    }

    public function mealPlans()
    {
        return $this->hasMany(MealPlan::class);
    }
}

-- Health App Database Schema
-- MySQL 8.0+ with utf8mb4 encoding

CREATE DATABASE IF NOT EXISTS health_app
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE health_app;

-- Users table (GDPR compliant with soft deletes)
CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    google_id VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say'),
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    activity_level ENUM('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'),
    fitness_goals JSON,
    dietary_approach VARCHAR(100),
    dislikes JSON,
    allergies JSON,
    health_conditions JSON,
    preferences JSON,
    email_verified_at TIMESTAMP NULL,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_google_id (google_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Health metrics table
CREATE TABLE health_metrics (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    weight_kg DECIMAL(5,2),
    sleep_hours DECIMAL(4,2),
    sleep_quality TINYINT UNSIGNED CHECK (sleep_quality BETWEEN 1 AND 10),
    energy_level TINYINT UNSIGNED CHECK (energy_level BETWEEN 1 AND 10),
    resting_heart_rate SMALLINT UNSIGNED,
    blood_pressure_systolic SMALLINT UNSIGNED,
    blood_pressure_diastolic SMALLINT UNSIGNED,
    steps INT UNSIGNED,
    calories_burned INT UNSIGNED,
    water_intake_ml INT UNSIGNED,
    mood ENUM('excellent', 'good', 'neutral', 'poor', 'terrible'),
    stress_level TINYINT UNSIGNED CHECK (stress_level BETWEEN 1 AND 10),
    notes TEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_date (user_id, date),
    INDEX idx_user_date (user_id, date),
    INDEX idx_user_created (user_id, created_at)
);

-- Medications table
CREATE TABLE medications (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    instructions TEXT,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    reminder_enabled BOOLEAN DEFAULT FALSE,
    reminder_times JSON,
    notes TEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_user_created (user_id, created_at)
);

-- Meals table
CREATE TABLE meals (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack') NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    ingredients JSON,
    nutritional_info JSON,
    calories INT UNSIGNED,
    protein_g DECIMAL(6,2),
    fats_g DECIMAL(6,2),
    carbs_g DECIMAL(6,2),
    fiber_g DECIMAL(6,2),
    sugar_g DECIMAL(6,2),
    sodium_mg INT UNSIGNED,
    hunger_before TINYINT UNSIGNED CHECK (hunger_before BETWEEN 1 AND 10),
    hunger_after TINYINT UNSIGNED CHECK (hunger_after BETWEEN 1 AND 10),
    satisfaction TINYINT UNSIGNED CHECK (satisfaction BETWEEN 1 AND 10),
    eating_reasons JSON,
    notes TEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, date),
    INDEX idx_user_meal_type (user_id, meal_type),
    INDEX idx_user_created (user_id, created_at)
);

-- Exercises table
CREATE TABLE exercises (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    type ENUM('cardio', 'strength', 'flexibility', 'sports', 'other') NOT NULL,
    muscle_groups JSON,
    equipment JSON,
    instructions TEXT,
    difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'intermediate',
    estimated_calories_per_minute SMALLINT UNSIGNED,
    is_template BOOLEAN DEFAULT FALSE,
    template_id INT UNSIGNED,
    date DATE,
    sets TINYINT UNSIGNED,
    reps_per_set TINYINT UNSIGNED,
    weight_kg DECIMAL(6,2),
    duration_minutes SMALLINT UNSIGNED,
    distance_km DECIMAL(6,2),
    calories_burned INT UNSIGNED,
    heart_rate_avg SMALLINT UNSIGNED,
    heart_rate_max SMALLINT UNSIGNED,
    perceived_effort TINYINT UNSIGNED CHECK (perceived_effort BETWEEN 1 AND 10),
    notes TEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES exercises(id) ON DELETE SET NULL,
    INDEX idx_user_date (user_id, date),
    INDEX idx_user_template (user_id, is_template),
    INDEX idx_user_created (user_id, created_at)
);

-- Meal plans table
CREATE TABLE meal_plans (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    target_calories INT UNSIGNED,
    target_protein_g DECIMAL(6,2),
    target_fats_g DECIMAL(6,2),
    target_carbs_g DECIMAL(6,2),
    meals JSON,
    notes TEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_user_created (user_id, created_at)
);

-- Sync status table
CREATE TABLE sync_status (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    entity_type ENUM('health_metrics', 'medications', 'meals', 'exercises', 'meal_plans') NOT NULL,
    last_sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_sync_version BIGINT UNSIGNED DEFAULT 0,
    device_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_entity_device (user_id, entity_type, device_id),
    INDEX idx_user_entity (user_id, entity_type),
    INDEX idx_last_sync (last_sync_timestamp)
);

-- Migrations table (for tracking database schema changes)
CREATE TABLE migrations (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    migration VARCHAR(255) NOT NULL,
    batch INT NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_migration (migration)
);

-- Password resets table
CREATE TABLE password_resets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_token (token),
    INDEX idx_email (email)
);

-- Insert initial migration record
INSERT INTO migrations (migration, batch) VALUES ('001_initial_schema.sql', 1);
INSERT INTO migrations (migration, batch) VALUES ('002_add_password_resets.sql', 2);
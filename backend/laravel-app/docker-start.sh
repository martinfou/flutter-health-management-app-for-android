#!/bin/bash

# Docker Database Startup Script for Health Management App
# This script starts the MySQL database and phpMyAdmin using Docker

set -e

echo "🐳 Starting Docker containers for Health Management App..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo ""
    echo "Please start Docker Desktop:"
    echo "  1. Open Docker Desktop application"
    echo "  2. Wait for Docker to start (you'll see a whale icon in menu bar)"
    echo "  3. Run this script again"
    echo ""
    exit 1
fi

# Start containers
echo "📦 Starting MySQL and phpMyAdmin containers..."
docker compose up -d

# Wait for MySQL to be ready
echo ""
echo "⏳ Waiting for MySQL to be ready..."
sleep 5

# Check if containers are running
if docker compose ps | grep -q "Up"; then
    echo ""
    echo "✅ Docker containers started successfully!"
    echo ""
    echo "📊 Database Information:"
    echo "  Host: 127.0.0.1"
    echo "  Port: 3306"
    echo "  Database: health_app"
    echo "  Username: health_app_user"
    echo "  Password: health_app_password"
    echo ""
    echo "🌐 phpMyAdmin (Web Interface):"
    echo "  URL: http://localhost:8080"
    echo "  Server: mysql"
    echo "  Username: health_app_user"
    echo "  Password: health_app_password"
    echo ""
    echo "📝 Laravel API Server:"
    echo "  URL: http://localhost:9000"
    echo ""
    echo "To stop: docker compose down"
    echo "To view logs: docker compose logs -f"
else
    echo ""
    echo "❌ Failed to start containers"
    echo "Check logs with: docker compose logs"
fi
